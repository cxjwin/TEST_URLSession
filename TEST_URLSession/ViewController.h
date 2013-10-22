//
//  ViewController.h
//  TEST_URLSession
//
//  Created by cxjwin on 13-10-11.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kBackgroundSessionIdentifier;
extern NSString *const kTestImageURLString1;

@interface ViewController : UIViewController <
    NSURLSessionDelegate,
    NSURLSessionTaskDelegate, 
    NSURLSessionDataDelegate,
    NSURLSessionDownloadDelegate,
    NSURLConnectionDelegate>

@property (strong, nonatomic) NSURLSession *defaultSession;
@property (strong, nonatomic) NSURLSession *backgroundSession;
@property (strong, nonatomic) NSURLSession *ephemeralSession;

@end
