//
//  AppDelegate.m
//  TEST_URLSession
//
//  Created by cxjwin on 13-10-11.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate () <
NSURLSessionDelegate,
NSURLSessionTaskDelegate, 
NSURLSessionDataDelegate>

@property (strong, nonatomic) NSURLSession *ephemeralSession;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSLog(@"%f", UIApplicationBackgroundFetchIntervalMinimum);
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:60];
    
    NSURLSessionConfiguration *ephemeralConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    ephemeralConfigObject.timeoutIntervalForResource = 30.0f;
    self.ephemeralSession = [NSURLSession sessionWithConfiguration:ephemeralConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Applications using an NSURLSession with a background configuration may be launched or resumed in the background in order to handle the
// completion of tasks in that session, or to handle authentication. This method will be called with the identifier of the session needing
// attention. Once a session has been created from a configuration object with that identifier, the session's delegate will begin receiving
// callbacks. If such a session has already been created (if the app is being resumed, for instance), then the delegate will start receiving
// callbacks without any action by the application. You should call the completionHandler as soon as you're finished handling the callbacks.
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler NS_AVAILABLE_IOS(7_0)
{
    NSLog(@"%s, %@", __func__, identifier);
    self.completionHandler = completionHandler;
}

/// Applications with the "fetch" background mode may be given opportunities to fetch updated content in the background or when it is convenient for the system. This method will be called in these situations. You should call the fetchCompletionHandler as soon as you're finished performing that operation, so the system can accurately estimate its power and data cost.
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler NS_AVAILABLE_IOS(7_0)
{
    NSLog(@"%s", __func__);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kTestImageURLString1]];
    [[self.ephemeralSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"1.......");
            completionHandler(UIBackgroundFetchResultFailed);
        } else {
            if ([data length] > 0) {
                NSLog(@"2.......");
                completionHandler(UIBackgroundFetchResultNewData);

            } else {
                NSLog(@"3.......");
                completionHandler(UIBackgroundFetchResultNoData);

            }
        }
    }] resume];
}

@end
