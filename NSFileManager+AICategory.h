//
//  NSFileManager+AICategory.h
//  AICategory
//
//  Created by Alienchangon 2017/9/25.
//  Copyright © 2017年 朱思明. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface NSFileManager (AICategory)

///获取程序的Home目录路径
+ (NSString *)homeDirectory;

///获取document目录路径
+ (NSString *)documentsDirectory;

///获取Cache目录路径
+ (NSString *)cachesDirectory;

///获取Library目录路径
+ (NSString *)libraryDirectory;

///获取Temp目录路径
+ (NSString *)tmpDirectory;

///Documents/${dir}
+ (NSString *)directoryForDocuments:(NSString *)dir;

///Library/Caches/${dir}
+ (NSString *)directoryForCaches:(NSString *)dir;

///Library/Caches/userdata
+ (NSString *)directoryForCachesUserData;

///Documents/userdata/
+ (NSString *)directoryForDocumentsUserData;

///创建文件
+ (BOOL)createDirectory:(NSString*)directory;

///[[NSBundle mainBundle] resourcePath]/filename
+ (NSString*)filePathForResource:(NSString *)filename;

///Caches/dir/filename
+ (NSString*)filePathForCaches:(NSString *)filename inDir:(NSString*)dir;

///Caches/filename
+ (NSString*)filePathForCaches:(NSString *)filename;

///Documents/dir/filename
+ (NSString*)filePathForDocuments:(NSString *)filename inDir:(NSString*)dir;

///Documents/filename
+ (NSString*)filePathForDocuments:(NSString *)filename;

///从工程里copy文件到缓存目录下
+ (NSString*)filePathForCachesFromResource:(NSString *)name;

///文件是否存在
+ (BOOL)fileExistsAtPath:(NSString *)filepath;

///删除文件
+(BOOL)deleteFile:(NSString *)filePath;

///删除所有的子目录
+ (void)deleteSubdirectory:(NSString*)folder;

///数组写入指定文件
+ (BOOL)writeFileArray:(NSArray *)array specifiedFile:(NSString *)path;

///字典写入指定文件
+ (BOOL)writeFileDictionary:(NSMutableDictionary *)dic specifiedFile:(NSString *)path;

///从文件读取数组
+ (NSArray *)arrayFromSpecifiedFile:(NSString *)path;

///从文件读取字典
+ (NSDictionary *)dictionaryFromSpecifiedFile:(NSString *)path;

///文件size
+ (float)fileSizeAtPath:(NSString *)path;

///文件夹size
+ (float)directoryTotalSizeAtPath:(NSString *)path;

///计算当前路径下的此级文件夹的缓存大小，如果文件夹还有子文件夹 将不会计算
+ (float)directoryTopFilesSizeAtPath:(NSString *)path;

/// 获取文件夹中所有文件路径
+ (NSArray <NSString *>*)filePathsWithPath:(NSString *)path;
@end
NS_ASSUME_NONNULL_END





