//
//  NSFileManager+AICategory.m
//  AICategory
//
//  Created by Alienchangon 2017/9/25.
//  Copyright © 2017年 朱思明. All rights reserved.
//

#import "NSFileManager+AICategory.h"

@implementation NSFileManager (AICategory)
//获取程序的Home目录路径
+ (NSString *)homeDirectory
{
    return NSHomeDirectory();
}

//获取Documents目录路径
+ (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

//获取Caches目录路径
+ (NSString *)cachesDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

//获取Library目录路径
+ (NSString *)libraryDirectory
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path=[paths objectAtIndex:0];
    return path;
}

//获取tmp目录路径
+ (NSString *)tmpDirectory
{
    return NSTemporaryDirectory();
}

//[[NSBundle mainBundle] resourcePath]/filename
+ (NSString*)filePathForResource:(NSString *)filename
{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
}

//Documents/filename
+ (NSString*)filePathForDocuments:(NSString *)filename {
    return [[self documentsDirectory] stringByAppendingPathComponent:filename];
}

//Caches/filename
+ (NSString*)filePathForCaches:(NSString *)filename {
    return [[self cachesDirectory] stringByAppendingPathComponent:filename];
}

//Documents/dir/filename
+ (NSString *)filePathForDocuments:(NSString *)filename inDir:(NSString *)dir {
    return [[self directoryForDocuments:dir] stringByAppendingPathComponent:filename];
}

//Caches/dir/filename
+ (NSString *)filePathForCaches:(NSString *)filename inDir:(NSString *)dir {
    return [[self directoryForCaches:dir] stringByAppendingPathComponent:filename];
}

+ (NSString*)filePathForCachesFromResource:(NSString *)name;
{
    BOOL success;
    NSError *error = nil;
    NSString *path = [self filePathForCaches:name];
    success = [self fileExistsAtPath:path];
    if (!success) {
        NSString *resourcePath = [self filePathForResource:name];
        success = [[NSFileManager defaultManager] copyItemAtPath:resourcePath toPath:path error:&error];
        if (!success) {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }
    return path;
}

//返回Documents下的指定文件路径(加创建)
+ (NSString *)directoryForDocuments:(NSString *)dir
{
    NSError* error;
    NSString* path = [[self documentsDirectory] stringByAppendingPathComponent:dir];
    if(![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
    {
        NSLog(@"create dir error: %@",error.debugDescription);
    }
    return path;
}


//返回Caches下的指定文件路径
+ (NSString *)directoryForCaches:(NSString *)dir
{
    NSError* error;
    NSString* path = [[self cachesDirectory] stringByAppendingPathComponent:dir];
    if(![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
    {
        NSLog(@"create dir error: %@",error.debugDescription);
    }
    return path;
}


+ (NSString *)directoryForCachesUserData{
    NSString *cachesDirectory = [self cachesDirectory];
    NSString *userCacheFolder = [cachesDirectory stringByAppendingPathComponent:@"userdata"];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[NSFileManager defaultManager] fileExistsAtPath:userCacheFolder])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:userCacheFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        }
    });
    return userCacheFolder;
}

//Documents/userdata/
+ (NSString *)directoryForDocumentsUserData{
    NSString *directory = [self documentsDirectory];
    NSString *userFolder = [directory stringByAppendingPathComponent:@"userData"];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[NSFileManager defaultManager] fileExistsAtPath:userFolder])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:userFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        }
    });
    return userFolder;
}

//创建文件夹
+ (BOOL)createDirectory:(NSString*)directory;
{
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

//文件是否存在
+ (BOOL)fileExistsAtPath:(NSString *)filepath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filepath];
}

//删除文件
+(BOOL)deleteFile:(NSString *)filePath {
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            return NO;
        }else{
            return YES;
        }
    }
    return YES;
}

//删除所有的子目录
+ (void)deleteSubdirectory:(NSString*)folder;
{
    NSArray* array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil];
    for (NSString* subFolder in array) {
        NSString *path = [folder stringByAppendingPathComponent:subFolder];
        NSError* error = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
            NSLog(@"error=%@",error);
        };
    }
}

//数组写入指定文件
+ (BOOL)writeFileArray:(NSArray *)array specifiedFile:(NSString *)path {
    return [array writeToFile:path atomically:YES];
}

//字典写入指定文件
+ (BOOL)writeFileDictionary:(NSMutableDictionary *)dic specifiedFile:(NSString *)path {
    return [dic writeToFile:path atomically:YES];
}

//从文件读取数组
+ (NSArray *)arrayFromSpecifiedFile:(NSString *)path
{
    return [NSArray arrayWithContentsOfFile:path];
}

//从文件读取字典
+ (NSDictionary *)dictionaryFromSpecifiedFile:(NSString *)path
{
    return [NSDictionary dictionaryWithContentsOfFile:path];
}


//文件大小
+ (float)fileSizeAtPath:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}

//计算磁盘缓存大小
+ (float)directoryTotalSizeAtPath:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    float folderSize = 0.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            folderSize += [[self class] fileSizeAtPath:absolutePath];
        }
        return folderSize;
    }
    return 0;
}

//计算当前路径下的此级文件夹的缓存大小，如果文件夹还有子文件夹 将不会计算
+ (float)directoryTopFilesSizeAtPath:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    float folderSize = 0.0;
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:path];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        folderSize += [attrs fileSize];
    }
    return folderSize/1024.0/1024.0;
}

+ (NSArray <NSString *>*)filePathsWithPath:(NSString *)path {
    NSArray* tempArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *fullPaths = [NSMutableArray new];
    for (NSString* fileName in tempArray) {
        if ([fileName hasSuffix:@"log"]) {
            NSString *fullPath = [path stringByAppendingFormat:@"/%@",fileName];
            [fullPaths addObject:fullPath];
        }
    }
    return fullPaths;
}

@end

