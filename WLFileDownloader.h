//
//  WLFileDownloader.h
//  Pomelo
//
//  Created by zz on 2023/3/30.
//  Copyright © 2023 Pomelo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLDownloadAction.h"
NS_ASSUME_NONNULL_BEGIN

@interface WLFileDownloader : NSObject
// 默认3
@property (nonatomic ,assign) NSInteger maxTaskLimit;
// 默认document/download
@property (nonatomic ,copy)   NSString *downloadPath;
+ (WLFileDownloader *)shareInstance;
- (void)appendAction:(WLDownloadAction *)action;
- (void)cancelAction:(WLDownloadAction *)action;
- (void)beginDownload;

+ (NSString *)localPathWithUrl:(NSString *)remoteUrl;
@end

NS_ASSUME_NONNULL_END
