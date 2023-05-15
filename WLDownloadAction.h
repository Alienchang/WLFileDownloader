//
//  WLDownloadAction.h
//  Pomelo
//
//  Created by zz on 2023/3/30.
//  Copyright © 2023 Pomelo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLDownloadItem.h"

typedef enum : NSUInteger {
    WLFileDownloadStatusWait = 0,
    WLFileDownloadStatusIn,             // 下载中
    WLFileDownloadStatusSuccess,
    WLFileDownloadStatusFailed,
    WLFileDownloadStatusCanceled
} WLFileDownloadStatus;

typedef enum : NSUInteger {
    WLFileDownloadPriorityLow,
    WLFileDownloadPriorityHigh,
} WLFileDownloadPriority;

NS_ASSUME_NONNULL_BEGIN

@interface WLDownloadAction : NSObject
- (instancetype)initWithDownloadItem:(WLDownloadItem *)downloadItem;
@property (nonatomic ,copy) void(^downloadCallBack)(WLDownloadItem *downloadItem,WLFileDownloadStatus downloadStatus,float progress);
@property (nonatomic ,strong) WLDownloadItem *downloadItem;
@property (nonatomic ,assign) WLFileDownloadStatus downloadStatus;
@property (nonatomic ,assign) float progress;
@property (nonatomic ,assign) WLFileDownloadPriority priority; // 默认high

@end

NS_ASSUME_NONNULL_END
