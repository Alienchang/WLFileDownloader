//
//  WLDownloadAction.m
//  Pomelo
//
//  Created by zz on 2023/3/30.
//  Copyright © 2023 Pomelo. All rights reserved.
//

#import "WLDownloadAction.h"

@implementation WLDownloadAction
- (instancetype)initWithDownloadItem:(WLDownloadItem *)downloadItem {
    if (self = [super init]) {
        self.downloadItem = downloadItem;
        self.priority = WLFileDownloadPriorityHigh;
    }
    return self;
}

- (BOOL)isEqual:(WLDownloadAction *)object {
    if ([self.downloadItem.url isEqualToString:object.downloadItem.url] &&
        object.downloadCallBack == self.downloadCallBack) {
        return YES;
    } else {
        return NO;
    }
}
@end
