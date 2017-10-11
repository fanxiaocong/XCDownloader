//
//  XCDownloaderFileTool.m
//  XCDownloaderExample
//
//  Created by 樊小聪 on 2017/9/29.
//  Copyright © 2017年 樊小聪. All rights reserved.
//

#import "XCDownloaderFileTool.h"

@implementation XCDownloaderFileTool


/**
 *  沙盒 cache 路径
 */
+ (NSString *)cachePath
{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
}

/**
 *  少盒 temporary 路径
 */
+ (NSString *)temporaryPath
{
    return NSTemporaryDirectory();
}


/**
 *  判断 path 路径下的文件是否存在
 */
+ (BOOL)fileExistsAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

/**
 *  返回 path 路径下的文件大小
 */
+ (XCFileSize)fileSizeAtPath:(NSString *)path
{
    if (![self fileExistsAtPath:path])      return 0;
    
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];

    return [fileInfo[NSFileSize] longLongValue];
}

/**
 *  移动文件
 *
 *  @param fromPath     源路径
 *  @param toPath       目标路径
 */
+ (BOOL)moveFileFromPath:(NSString *)fromPath
                  toPath:(NSString *)toPath
{
    return [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}

/**
 *  删除 path 路径下的文件
 */
+ (BOOL)removeFileAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
