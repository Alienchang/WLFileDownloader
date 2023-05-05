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
    }
    return self;
}
@end
