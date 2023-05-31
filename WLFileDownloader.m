//
//  WLFileDownloader.m
//  Pomelo
//
//  Created by zz on 2023/3/30.
//  Copyright © 2023 Pomelo. All rights reserved.
//

#import "WLFileDownloader.h"

static NSString *cachePath = nil;

@interface WLFileDownloader()
@property (nonatomic ,strong) NSMutableArray <WLDownloadAction *>*waitActions;
@property (nonatomic ,strong) NSCache *cache;
@property (nonatomic ,strong) dispatch_queue_t downloadOperationQueue;
@property (nonatomic ,assign) NSInteger currentTaskCount;
@end

@implementation WLFileDownloader

#pragma mark -- public func
+ (WLFileDownloader *)shareInstance {
    static WLFileDownloader *downloader = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        downloader = [[WLFileDownloader alloc] init];
        downloader.maxTaskLimit = 8;
        downloader.downloadOperationQueue = dispatch_queue_create("com.wl.downloader", DISPATCH_QUEUE_SERIAL);
//        DISPATCH_QUEUE_SERIAL
//        DISPATCH_QUEUE_CONCURRENT
    });
    return downloader;
}

- (void)appendAction:(WLDownloadAction *)action {
    dispatch_async(self.downloadOperationQueue, ^{
        if ([self.waitActions containsObject:action]) {
            return;
        }
        if (!action.downloadCallBack) {
            NSURL *url = [NSURL URLWithString:action.downloadItem.url];
            NSString *fileName = [url lastPathComponent];
            NSString *filePath = [self.class.downloadPath stringByAppendingFormat:@"/%@",fileName];
            if ([self.class fileExistsAtPath:filePath]) {
                return;
            }
        }
        
        if ([self.waitActions containsObject:action]) {
            return;
        }
        
        if (action.priority == WLFileDownloadPriorityLow) {
            [self.waitActions addObject:action];
        } else {
            [self.waitActions insertObject:action atIndex:0];
        }
    });
}

- (void)cancelAction:(WLDownloadAction *)action {
    dispatch_async(self.downloadOperationQueue, ^{
        [self.waitActions removeObject:action];
    });
}

- (void)finishAction:(WLDownloadAction *)action {
    self.currentTaskCount --;
    [self actionCallBack:action];
}

- (void)beginDownload {
    dispatch_async(self.downloadOperationQueue, ^{
        if (!self.waitActions.count) {
            return;
        }
        
        NSMutableArray *inAction = [NSMutableArray new];
        NSInteger needActionCount = self.maxTaskLimit - self.currentTaskCount;
        if (needActionCount == 0) {
            return;
        }
        if (self.waitActions.count <= needActionCount) {
            [inAction addObjectsFromArray:self.waitActions];
        } else {
            [inAction addObjectsFromArray:[self.waitActions subarrayWithRange:NSMakeRange(0, needActionCount - 1)]];
        }
        NSLog(@"当前下载数量 = %@",@(self.waitActions.count));
        for (WLDownloadAction *action in inAction) {
            self.currentTaskCount ++;
            WLDownloadAction *action = self.waitActions.firstObject;
            [self.waitActions removeObjectAtIndex:0];
            
            if (action.downloadItem.url.length) {
                [self actionCallBack:action];
                
                NSURL *url = [NSURL URLWithString:action.downloadItem.url];
                NSString *fileName = [url lastPathComponent];
                NSString *filePath = [self.class.downloadPath stringByAppendingFormat:@"/%@",fileName];
                NSData *animationMemoryData = [self.cache objectForKey:action.downloadItem.url];
                if (animationMemoryData) {
                    action.downloadStatus = WLFileDownloadStatusSuccess;
                    action.downloadItem.data = animationMemoryData;
                    [self finishAction:action];
                    [self beginDownload];
                } else if ([self.class fileExistsAtPath:filePath]) {
                    action.downloadStatus = WLFileDownloadStatusSuccess;
                    action.downloadItem.localUrl = filePath;
                    if (action.downloadItem.useCache) {
                        NSData *data = [NSData dataWithContentsOfFile:filePath];
                        if (data) {
                            [self.cache setObject:data forKey:action.downloadItem.url];
                            action.downloadItem.data = data;
                        }
                    }
                    [self finishAction:action];
                    [self beginDownload];
                } else {
                    __weak typeof(self) weakSelf = self;
                    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
                    urlRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
                    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest
                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                        if (error == nil && data != nil) {
                            if ([data writeToFile:filePath atomically:YES]) {
                                action.downloadStatus = WLFileDownloadStatusSuccess;
                                action.downloadItem.localUrl = filePath;
                                if (action.downloadItem.useCache) {
                                    [strongSelf.cache setObject:data forKey:action.downloadItem.url];
                                    action.downloadItem.data = data;
                                }
                                
                                [strongSelf finishAction:action];
                                [strongSelf beginDownload];
                            } else {
                                action.downloadStatus = WLFileDownloadStatusFailed;
                                [strongSelf finishAction:action];
                                [strongSelf beginDownload];
                            }
                        } else {
                            action.downloadStatus = WLFileDownloadStatusFailed;
                            [strongSelf finishAction:action];
                            [strongSelf beginDownload];
                        }
                    }] resume];
                }
            } else {
                action.downloadStatus = WLFileDownloadStatusFailed;
                [self finishAction:action];
                [self beginDownload];
            }
        }
    });
}

+ (NSString *)localPathWithUrl:(NSString *)remoteUrl {
    NSURL *url = [NSURL URLWithString:remoteUrl];
    NSString *fileName = [url lastPathComponent];
    NSString *filePath = [self.downloadPath stringByAppendingFormat:@"/%@",fileName];
    if ([self fileExistsAtPath:filePath]) {
        return filePath;
    } else {
        return nil;
    }
}

#pragma mark -- private func
- (void)actionCallBack:(WLDownloadAction *)action {
    if (action.downloadCallBack) {
        action.downloadCallBack(action.downloadItem, action.downloadStatus, 0.);
    }
}

#pragma mark -- getter
- (NSMutableArray <WLDownloadAction *>*)waitActions {
    if (!_waitActions) {
        _waitActions = [NSMutableArray new];
    }
    return _waitActions;
}

+ (NSString *)downloadPath {
    if (!cachePath) {
        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [document stringByAppendingString:@"/download"];
        [self createDirectory:path];
        cachePath = path;
    }
    return cachePath;
}

- (NSCache *)cache {
    if (!_cache) {
        _cache = [NSCache new];
        _cache.countLimit = 10;
    }
    return _cache;
}

#pragma mark -- FileManager
+ (BOOL)fileExistsAtPath:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}
+ (BOOL)createDirectory:(NSString*)directory {
    BOOL success = NO;
    NSFileManager *fileMgr = [NSFileManager defaultManager];    //
    BOOL isDirectory = NO;
    if([fileMgr fileExistsAtPath:directory isDirectory:&isDirectory]) {
        success = YES;
    } else {
        NSError *error = nil;
        success = [fileMgr createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
        if(success) {
            //NSLog(@"==== (%@) create succeed ====",folder);
        } else {
            //NSLog(@"==== (%@) create failed %@ ====",folder,error);
        }
    }
    return success;
}
@end
