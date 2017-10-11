//
//  XCDownloader.h
//  XCDownloaderExample
//
//  Created by 樊小聪 on 2017/9/29.
//  Copyright © 2017年 樊小聪. All rights reserved.
//


/*
 *  备注：文件下载器 🐾
 */

#import <UIKit/UIKit.h>

#import "XCDownloaderFileTool.h"

typedef NS_ENUM(NSInteger, XCDownloadState)
{
    /// 下载暂停
    XCDownloadStatePause = 0,
    /// 正在下载
    XCDownloadStateDownloading,
    /// 下载取消
    XCDownloadStateCancel,
    /// 下载成功
    XCDownloadStateSuccess,
    //// 下载失败
    XCDownloadStateFailure
};

/// 单位: bytes
typedef void(^XCDownloadProgress)(XCFileSize totalSize, XCFileSize receivedSize);
typedef void(^XCDownloadSuccess)(NSString *filePath);
typedef void(^XCDownloadFailure)(void);
typedef void(^XCDownloadStateDidChange)(XCDownloadState state);


@interface XCDownloader : NSObject

/** 👀 下载状态 👀 */
@property (assign, nonatomic, readonly) XCDownloadState state;

/** 👀 状态发生改变的回调 👀 */
@property (copy, nonatomic) XCDownloadStateDidChange stateChangeBlock;


- (void)downloadWithURL:(NSURL *)url;

/**
 *  下载文件
 *
 *  @param url      文件的下载地址
 *  @param progress 下载进度
 *  @param success  成功
 *  @param failure  失败
 */
- (void)downloadWithURL:(NSURL *)url
               progress:(XCDownloadProgress)progress
                success:(XCDownloadSuccess)success
                failure:(XCDownloadFailure)failure;

/**
 *  暂停下载任务
 */
- (void)pause;

/**
 *  恢复下载
 */
- (void)resume;

/**
 *  取消下载任务
 */
- (void)cancel;

/**
 *  取消下载任务，并清理资源
 */
- (void)cancelAndClean;

@end
