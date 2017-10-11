//
//  XCDownloader.m
//  XCDownloaderExample
//
//  Created by 樊小聪 on 2017/9/29.
//  Copyright © 2017年 樊小聪. All rights reserved.
//


/*
 *  备注：文件下载器 🐾
 */


#import "XCDownloader.h"

#import "NSString+XCDownloader.h"


@interface XCDownloader ()<NSURLSessionDataDelegate>

/** 👀 文件正在下载的路径：时间路径 👀 */
@property (copy, nonatomic) NSString *downloadingPath;
/** 👀 文件下载完毕的路径：缓存路 👀 */
@property (copy, nonatomic) NSString *downloadedPath;


/** 👀 下载会话 👀 */
@property (nonatomic, strong) NSURLSession *session;
/** 👀 当前下载任务 👀 */
@property (weak, nonatomic) NSURLSessionDataTask *dataTask;
/** 👀 文件输出流 👀 */
@property (strong, nonatomic) NSOutputStream *outputStream;


@property (copy, nonatomic) XCDownloadSuccess success;
@property (copy, nonatomic) XCDownloadFailure failure;
@property (copy, nonatomic) XCDownloadProgress progress;

@end


@implementation XCDownloader
{
    XCFileSize _tempFileSize;       // 临时文件大小
    XCFileSize _totalFileSize;      // 文件总大小
    XCFileSize _receiveFileSize;    // 已经接收到的文件的大小
}


#pragma mark - 🛠 👀 Setter Method 👀

- (void)setState:(XCDownloadState)state
{
    if (state == _state)    return;
    
    _state = state;
    
    /// 状态改变
    if (self.stateChangeBlock)
    {
        self.stateChangeBlock(self.state);
    }
    
    /// 成功
    if (self.state == XCDownloadStateSuccess  &&   self.success)
    {
        self.success(self.downloadedPath);
    }
    
    /// 失败
    if (self.state == XCDownloadStateFailure  &&   self.failure)
    {
        self.failure();
    }
}

#pragma mark - 🔓 👀 Public Method 👀

- (void)downloadWithURL:(NSURL *)url
{
    /// 如果当前的下载任务已经存在，则继续下载
    if ([url isEqual:self.dataTask.originalRequest.URL])
    {
        [self resume];
        return;
    }
    
    NSString *fileName = url.lastPathComponent;
    
    self.downloadingPath = [[XCDownloaderFileTool temporaryPath] stringByAppendingPathComponent:fileName];
    self.downloadedPath  = [[XCDownloaderFileTool cachePath] stringByAppendingPathComponent:fileName];
    
    /// 判断 downloadedPath 路径下的文件是否存在，如果存在，则表示文件已经下载完毕，不需要重复下载
    if ([XCDownloaderFileTool fileExistsAtPath:self.downloadedPath])
    {
        self.state = XCDownloadStateSuccess;
        return;
    }
    
    /// 文件还没有下载完毕，继续下载
    _tempFileSize = [XCDownloaderFileTool fileSizeAtPath:self.downloadingPath];
    _receiveFileSize = _tempFileSize;
    
    [self downloadWithURL:url startOffset:_tempFileSize];
}

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
                failure:(XCDownloadFailure)failure
{
    self.progress = progress;
    self.success  = success;
    self.failure  = failure;
    
    /// 开始下载
    [self downloadWithURL:url];
}

/**
 *  暂停下载任务
 */
- (void)pause
{
    if (self.state == XCDownloadStateDownloading)
    {
        self.state = XCDownloadStatePause;
        [self.dataTask suspend];
    }
}

/**
 *  恢复下载
 */
- (void)resume
{
    if (self.dataTask && self.state == XCDownloadStatePause)
    {
        [self.dataTask resume];
        self.state = XCDownloadStateDownloading;
    }
}

/**
 *  取消下载任务
 */
- (void)cancel
{
    self.state = XCDownloadStateCancel;
    /// 取消所有下载任务
    [self.session invalidateAndCancel];
    self.session = nil;
}

/**
 *  取消下载任务，并清理资源
 */
- (void)cancelAndClean
{
    [self cancel];
    [XCDownloaderFileTool removeFileAtPath:self.downloadingPath];
    [XCDownloaderFileTool removeFileAtPath:self.downloadedPath];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  根据文件 URL 和 文件下载的起始位置下载
 *
 *  @param url      文件URL地址
 *  @param offset   起始位置的偏移量
 */
- (void)downloadWithURL:(NSURL *)url startOffset:(XCFileSize)offset
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    
    /// 开始下载
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self.dataTask resume];
}

#pragma mark - 💤 👀 LazyLoad Method 👀

- (NSURLSession *)session
{
    if (!_session)
    {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return _session;
}

#pragma mark - 💉 👀 NSURLSessionDataDelegate 👀

/**
 *  第一次接受到相应的时候调用(响应头, 并没有具体的资源内容)
 *  通过这个方法, 里面, 系统提供的回调代码块, 可以控制, 是继续请求, 还是取消本次请求
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    /// 通过 response 来获取文件大小
    
    // 资源总大小
    // 1. 从  Content-Length 取出来
    // 2. 如果 Content-Range 有, 应该从Content-Range里面获取
    _totalFileSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    
    NSString *contentRange = response.allHeaderFields[@"Content-Range"];
    
    if (contentRange && contentRange.length)
    {
        _totalFileSize = [[contentRange componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    /// 比对 本地已经下载的文件大小(_tempFileSize) 和 文件总大小(_totalFileSize)，判断是否需要下载
    
    // 1、当 _tempFileSize == _totalFileSize，表示文件已经下载完毕
    if (_tempFileSize == _totalFileSize)
    {
        // 将文件从 下载中的文件夹 移动到 下载完成的文件夹中
        [XCDownloaderFileTool moveFileFromPath:self.downloadingPath toPath:self.downloadedPath];
        self.state = XCDownloadStateSuccess;

        return;
    }
    
    
    // 2、当 _tempFileSize > _totalFileSize，表示文件下载出错
    if (_tempFileSize > _totalFileSize)
    {
        // 删除已经下载的文件（错误文件）
        [XCDownloaderFileTool removeFileAtPath:self.downloadingPath];
        
        // 取消本次下载请求
        completionHandler(NSURLSessionResponseCancel);
        
        // 重新开始下载
        [self downloadWithURL:response.URL];
        
        return;
    }
    
    
    // 3、文件正常下载
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downloadingPath append:YES];
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
    self.state = XCDownloadStateDownloading;
}

/**
 *  当用户确定, 继续接受数据的时候调用
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    /// 将接收到的数据存入 临时文件
    // 注：这个地方需要考虑峰值问题，可以通过 NSOutputStream 这个类来解决这个问题
    [self.outputStream write:data.bytes maxLength:data.length];
    
    _receiveFileSize += data.length;
    
    /// 当前下载进度
    if (self.progress)
    {
        self.progress(_totalFileSize, _receiveFileSize);
    }
}

/**
 *  当下载请求完成的时候调用(成功/失败/取消)
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    /// 清空下载操作
    self.dataTask = nil;
    
    /// 取消下载
    if (error && error.code == -999)
    {
        self.state = XCDownloadStateCancel;
        return;
    }

    /// 下载失败
    if (error || (_totalFileSize != _receiveFileSize))
    {
        self.state = XCDownloadStateFailure;
        return;
    }
    
    self.state = XCDownloadStateSuccess;
    
    // 将文件从 下载中的文件夹 移动到 下载完成的文件夹中
    [XCDownloaderFileTool moveFileFromPath:self.downloadingPath toPath:self.downloadedPath];
    
    // 关闭文件输出流
    [self.outputStream close];
}

@end
