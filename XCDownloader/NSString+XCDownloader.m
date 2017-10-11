//
//  NSString+XCDownloader.m
//  XCDownloaderExample
//
//  Created by 樊小聪 on 2017/9/29.
//  Copyright © 2017年 樊小聪. All rights reserved.
//

#import "NSString+XCDownloader.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (XCDownloader)

- (NSString *)MD5
{
    const char *data = self.UTF8String;
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(data, (CC_LONG)strlen(data), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++)
    {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}


@end
