//
//  XCDownloaderManager.h
//  XCDownloaderExample
//
//  Created by 樊小聪 on 2017/10/10.
//  Copyright © 2017年 樊小聪. All rights reserved.
//


/*
 *  备注：下载器管理类 🐾
 */

#import <Foundation/Foundation.h>
#import "XCDownloader.h"

@interface XCDownloaderManager : NSObject

+ (instancetype)shareInstance;

/**
 *  下载文件
 *
 *  @param url              文件的下载地址
 *  @param stateDidChange   下载状态发生改变的回调
 *  @param progress         下载进度
 *  @param success          成功
 *  @param failure          失败
 */
- (void)downloadWithURL:(NSURL *)url
         stateDidChange:(XCDownloadStateDidChange)stateDidChange
               progress:(XCDownloadProgress)progress
                success:(XCDownloadSuccess)success
                failure:(XCDownloadFailure)failure;

/**
 *  暂停某个下载操作
 */
- (void)pauseWithURL:(NSURL *)url;

/**
 *  恢复某个下载操作
 */
- (void)resumeWithURL:(NSURL *)url;

/**
 *  取消某个下载操作
 */
- (void)cancelWithURL:(NSURL *)url;

/**
 *  暂停所有下载操作
 */
- (void)pauseAll;
/**
 *  恢复所有下载操作
 */
- (void)resumeAll;
/**
 *  取消所有下载操作
 */
- (void)cancelAll;

@end
