//
//  XCDownloaderFileTool.h
//  XCDownloaderExample
//
//  Created by 樊小聪 on 2017/9/29.
//  Copyright © 2017年 樊小聪. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef long long XCFileSize;



@interface XCDownloaderFileTool : NSObject


/**
 *  沙盒 cache 路径
 */
+ (NSString *)cachePath;

/**
 *  少盒 temporary 路径
 */
+ (NSString *)temporaryPath;


/**
 *  判断 path 路径下的文件是否存在
 */
+ (BOOL)fileExistsAtPath:(NSString *)path;

/**
 *  返回 path 路径下的文件大小
 */
+ (XCFileSize)fileSizeAtPath:(NSString *)path;

/**
 *  移动文件
 *
 *  @param fromPath     源路径
 *  @param toPath       目标路径
 */
+ (BOOL)moveFileFromPath:(NSString *)fromPath
                  toPath:(NSString *)toPath;

/**
 *  删除 path 路径下的文件
 */
+ (BOOL)removeFileAtPath:(NSString *)path;

@end
