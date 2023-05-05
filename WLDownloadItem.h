//
//  WLDownloadItem.h
//  Pomelo
//
//  Created by zz on 2023/3/30.
//  Copyright © 2023 Pomelo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLDownloadItem : NSObject
@property (nonatomic ,copy) NSString *fileName;
@property (nonatomic ,copy) NSString *url;
// 下载之后会赋值，下载的路径
@property (nonatomic ,copy) NSString *localUrl;
@property (nonatomic ,strong) NSData *data;
// 是否使用内存缓存，不赋值默认不缓存
@property (nonatomic ,assign) BOOL useCache;
@end

NS_ASSUME_NONNULL_END
