//
//  WLFileDownloader.m
//  Pomelo
//
//  Created by zz on 2023/3/30.
//  Copyright © 2023 Pomelo. All rights reserved.
//

#import "WLFileDownloader.h"
#import <VComponents/NSFileManager+AICategory.h>

@interface WLFileDownloader()
@property (nonatomic ,strong) NSMutableArray <WLDownloadAction *>*waitActions;
@property (nonatomic ,strong) NSMutableArray <WLDownloadAction *>*inActions;

@property (nonatomic ,strong) NSLock *appendLock;
@property (nonatomic ,strong) NSLock *removeLock;
@property (nonatomic ,strong) NSLock *lock;

@property (nonatomic ,strong) NSCache *cache;
@property (nonatomic ,strong) dispatch_queue_t downloadOperationQueue;
@end

@implementation WLFileDownloader

#pragma mark -- public func
+ (WLFileDownloader *)shareInstance {
    static WLFileDownloader *downloader = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        downloader = [[WLFileDownloader alloc] init];
        downloader.maxTaskLimit = 3;
        downloader.downloadOperationQueue = dispatch_queue_create("com.wl.downloader", DISPATCH_QUEUE_SERIAL);
//        DISPATCH_QUEUE_SERIAL
//        DISPATCH_QUEUE_CONCURRENT
    });
    return downloader;
}

- (void)appendAction:(WLDownloadAction *)action {
    dispatch_async(self.downloadOperationQueue, ^{
        [self.waitActions addObject:action];
    });
}

- (void)cancelAction:(WLDownloadAction *)action {
    dispatch_async(self.downloadOperationQueue, ^{
        [self.waitActions removeObject:action];
    });
}

- (void)finishAction:(WLDownloadAction *)action {
    dispatch_async(self.downloadOperationQueue, ^{
        [self actionCallBack:action];
        [self.inActions removeObject:action];
    });
}

- (void)beginDownload {
    dispatch_async(self.downloadOperationQueue, ^{
        
        if (!self.waitActions.count) {
            return;
        }
        
        NSInteger i = self.inActions.count;
        NSInteger count = 0;
        for (WLDownloadAction *action in self.waitActions) {
            action.downloadStatus = WLFileDownloadStatusIn;
            [self.inActions addObject:action];
            ++i;
            ++count;
            if (i >= self.maxTaskLimit) {
                break;
            }
        }
        [self.waitActions removeObjectsInRange:NSMakeRange(0, count)];
        
        for (WLDownloadAction *action in self.inActions) {
            if (action.downloadItem.url.length) {
                [self actionCallBack:action];
                
                NSURL *url = [NSURL URLWithString:action.downloadItem.url];
                NSString *fileName = [url lastPathComponent];
                NSString *filePath = [self.downloadPath stringByAppendingFormat:@"/%@",fileName];
                NSData *animationMemoryData = [self.cache objectForKey:action.downloadItem.url];
                if (animationMemoryData) {
                    action.downloadStatus = WLFileDownloadStatusSuccess;
                    action.downloadItem.data = animationMemoryData;
                    [self finishAction:action];
                    [self beginDownload];
                } else if ([NSFileManager fileExistsAtPath:filePath]) {
                    action.downloadStatus = WLFileDownloadStatusSuccess;
                    action.downloadItem.localUrl = filePath;
                    if (action.downloadItem.useCache) {
                        NSData *data = [NSData dataWithContentsOfFile:filePath];
                        [self.cache setObject:data forKey:action.downloadItem.url];
                        action.downloadItem.data = data;
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

#pragma mark -- private func
- (void)actionCallBack:(WLDownloadAction *)action {
    if (action.downloadCallBack) {
        action.downloadCallBack(action.downloadItem, action.downloadStatus, 0.);
    }
}

#pragma mark -- getter
- (NSMutableArray <WLDownloadAction *>*)inActions {
    if (!_inActions) {
        _inActions = [NSMutableArray new];
    }
    return _inActions;
}

- (NSMutableArray <WLDownloadAction *>*)waitActions {
    if (!_waitActions) {
        _waitActions = [NSMutableArray new];
    }
    return _waitActions;
}

- (NSLock *)appendLock {
    if (!_appendLock) {
        _appendLock = [NSLock new];
    }
    return _appendLock;
}

- (NSLock *)removeLock {
    if (!_removeLock) {
        _removeLock = [NSLock new];
    }
    return _removeLock;
}

- (NSLock *)lock {
    if (!_lock) {
        _lock = [NSLock new];
    }
    return _lock;
}

- (NSString *)downloadPath {
    if (!_downloadPath) {
        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *downloadPath = [document stringByAppendingString:@"/download"];
        _downloadPath = downloadPath;
        [NSFileManager createDirectory:downloadPath];
    }
    return _downloadPath;
}

- (NSCache *)cache {
    if (!_cache) {
        _cache = [NSCache new];
        _cache.countLimit = 10;
    }
    return _cache;
}
@end
