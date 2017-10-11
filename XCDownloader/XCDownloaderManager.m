//
//  XCDownloaderManager.m
//  XCDownloaderExample
//
//  Created by 樊小聪 on 2017/10/10.
//  Copyright © 2017年 樊小聪. All rights reserved.
//


/*
 *  备注：下载器管理类 🐾
 */

#import "XCDownloaderManager.h"

#import "NSString+XCDownloader.h"


@interface XCDownloaderManager ()

@property (strong, nonatomic) NSMutableDictionary *downloaderInfo;

@end


@implementation XCDownloaderManager

#pragma mark - 💤 👀 LazyLoad Method 👀

- (NSMutableDictionary *)downloaderInfo
{
    if (!_downloaderInfo)
    {
        _downloaderInfo = [NSMutableDictionary dictionary];
    }
    return _downloaderInfo;
}

#pragma mark - 🔓 👀 Public Method 👀

static id _instance = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

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
                failure:(XCDownloadFailure)failure
{
    /// 1､获取 URL 对应的 MD5 字符串
    NSString *urlMD5 = [url.absoluteString MD5];
    
    /// 2､根据 urlMD5 获取对应的下载器
    XCDownloader *downloader = self.downloaderInfo[urlMD5];
    
    if (!downloader)
    {
        downloader = [[XCDownloader alloc] init];
        self.downloaderInfo[urlMD5] = downloader;
    }
    
    downloader.stateChangeBlock = stateDidChange;
    
    __weak typeof(self) weakSelf = self;
    [downloader downloadWithURL:url progress:progress success:^(NSString *filePath) {
        
        /// 3､下载成功之后，移除对应的下载器
        [weakSelf.downloaderInfo removeObjectForKey:urlMD5];
        
    } failure:failure];
}

/**
 *  暂停某个下载操作
 */
- (void)pauseWithURL:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString MD5];
    XCDownloader *downloader = self.downloaderInfo[urlMD5];
    [downloader pause];
}

/**
 *  恢复某个下载操作
 */
- (void)resumeWithURL:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString MD5];
    XCDownloader *downloader = self.downloaderInfo[urlMD5];
    [downloader resume];
}

/**
 *  取消某个下载操作
 */
- (void)cancelWithURL:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString MD5];
    XCDownloader *downloader = self.downloaderInfo[urlMD5];
    [downloader cancel];
}

/**
 *  暂停所有下载操作
 */
- (void)pauseAll
{
    [self.downloaderInfo.allValues makeObjectsPerformSelector:@selector(parse)];
}
/**
 *  恢复所有下载操作
 */
- (void)resumeAll
{
    [self.downloaderInfo.allValues makeObjectsPerformSelector:@selector(resume)];
}
/**
 *  取消所有下载操作
 */
- (void)cancelAll
{
    [self.downloaderInfo.allValues makeObjectsPerformSelector:@selector(cancel)];
}

@end
