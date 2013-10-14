//
//  AppDelegate.h
//  TEST_URLSession
//
//  Created by cxjwin on 13-10-11.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BackgroundCompletionHandler)();

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (copy, nonatomic) BackgroundCompletionHandler completionHandler;

@end
