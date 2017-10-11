//
//  ViewController.m
//  XCDownloaderExample
//
//  Created by 樊小聪 on 2017/9/29.
//  Copyright © 2017年 樊小聪. All rights reserved.
//

#import "ViewController.h"

#import "XCDownloader.h"


@interface ViewController ()

@property (strong, nonatomic) XCDownloader *download;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.download = [[XCDownloader alloc] init];
 
    self.download.stateChangeBlock = ^(XCDownloadState state){
        NSLog(@"当前状态：%zi", state);
    };
}


#pragma mark - 🎬 👀 Action Method 👀

- (IBAction)download:(id)sender
{
    [self.download downloadWithURL:[NSURL URLWithString:@"http://pcdl.itools.cn/itools4/itoolssetup_4.2.6.1.exe"]];
}

- (IBAction)pause:(id)sender {
    
    [self.download pause];
}

- (IBAction)cancel:(id)sender {
    
    [self.download cancel];
}

- (IBAction)clear:(id)sender {
    
    [self.download cancelAndClean];
}

@end
