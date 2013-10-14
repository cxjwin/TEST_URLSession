//
//  ViewController.m
//  TEST_URLSession
//
//  Created by cxjwin on 13-10-11.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
#define kOneKilobyte 1024lu
#define kOneMegabyte 1048576lu
#define kOneGigaByte 1073741824lu
#else
#define kOneKilobyte 1024u
#define kOneMegabyte 1048576u
#define kOneGigaByte 1073741824u
#endif

#define kDefaultSessionBaseIdentifier 100
#define kEphemeralSessionBaseIdentifier 200

NSString *const kBackgroundSessionIdentifier = @"kBackgroundSessionIdentifier";
NSTimeInterval kDefaultTimeoutIntervalForResource = 60;

NSString *const kTestImageURLString1 = 
@"http://d.hiphotos.baidu.com/album/w%3D1920%3Bcrop%3D0%2C0%2C1920%2C1080/sign=385b11bb0823dd542173a361e33988bd/0d338744ebf81a4ca2478116d62a6059242da6fc.jpg";

NSString *const kTestImageURLString2 = 
@"http://g.hiphotos.baidu.com/album/w%3D1920%3Bcrop%3D0%2C0%2C1920%2C1080/sign=672b402137d3d539c13d0bca08b7d233/1f178a82b9014a9058c22662a8773912b21bee75.jpg";

NSString *const kTestImageURLString3 =
@"http://a.hiphotos.baidu.com/album/w%3D1920%3Bcrop%3D0%2C0%2C1920%2C1080/sign=ac77d8ff00e939015602893749dc6f84/7af40ad162d9f2d387824430a8ec8a136227cc5a.jpg";

NSString *const kTestPdfURLString1 =
@"https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/TransitionGuide.pdf";

NSString *const kTestPdfURLString2 =
@"https://developer.apple.com/library/ios/featuredarticles/iPhoneConfigurationProfileRef/iPhoneConfigurationProfileRef.pdf";

@interface ViewController () 

@property (strong, nonatomic) NSMutableDictionary *tempDataDict;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.tempDataDict = [NSMutableDictionary dictionary];
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    NSString *cachePath = @"TestCacheDirectory";
#ifdef DEBUG
//    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *myPath = [myPathList objectAtIndex:0];
//    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
//    NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathComponent:cachePath];
//    NSLog(@"Cache path: %@\n", fullCachePath);
#endif
    NSURLCache *myCache = 
    [[NSURLCache alloc] initWithMemoryCapacity:20 * kOneMegabyte diskCapacity:100 * kOneMegabyte diskPath:cachePath];
    
    // defaultConfigObject
    // Default sessions behave similarly to other Foundation methods for downloading URLs. 
    // They use a persistent disk-based cache and store credentials in the user’s keychain.
    {
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultConfigObject.timeoutIntervalForResource = kDefaultTimeoutIntervalForResource;
        defaultConfigObject.URLCache = myCache;
        defaultConfigObject.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        self.defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:self.operationQueue];
    }
    
    // ephemeralConfigObject
    // Ephemeral sessions do not store any data to disk; all caches, credential stores, and so on are kept in RAM and tied to the session. 
    // Thus, when your app invalidates the session, they are purged automatically.
    {
        NSURLSessionConfiguration *ephemeralConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        ephemeralConfigObject.timeoutIntervalForResource = kDefaultTimeoutIntervalForResource;
        self.ephemeralSession = [NSURLSession sessionWithConfiguration:ephemeralConfigObject delegate:self delegateQueue:self.operationQueue];
    }
    
    // backgroundConfigObject
    // Background sessions are similar to default sessions, except that a separate process handles all data transfers. 
    // Background sessions have some additional limitations, described in “Background Transfer Considerations.”
    {
        NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfiguration:kBackgroundSessionIdentifier];
        backgroundConfigObject.URLCache = myCache;
        backgroundConfigObject.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigObject delegate:self delegateQueue:self.operationQueue];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self dataTaskWithThreeSessionsWithBlock];
    
//    [self dataTaskWithThreeSessionsWithDelegate];
    
//    [self multiDataTasksWithDefaultSession];
    
//    [self multiDataTasksWithEphemeralSession];
    
//    [self downloadTaskWithThreeSessionsWithBlock];
    
//    [self downloadTaskWithThreeSessionsWithDelegate];
    
    [self changeDataTaskToDownloadTask];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 
#pragma mark - data tasks
// Data tasks send and receive data using NSData objects. Data tasks are intended for short, often interactive requests from your app to a server.
// Data tasks can return data to your app one piece at a time after each piece of data is received, or all at once through a completion handler.
// Because data tasks do not store the data to a file, they are not supported in background sessions.
- (void)dataTaskWithThreeSessionsWithBlock
{
    // data 会被存储在URLCache里面
    // 如果URLCache里面有数据那么会被直接返回
    // 当使用block的时候,delegate不会触发
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:kTestImageURLString1]];
    [[self.defaultSession dataTaskWithRequest:request1 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"defaultSession data length : %lu", (unsigned long)[data length]);
    }] resume];
    
    // data 不会被存储在URLCache里面
    // 每次都是重新下载
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:kTestImageURLString2]];
    [[self.ephemeralSession dataTaskWithRequest:request2 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"ephemeralSession data length : %lu", (unsigned long)[data length]);
    }] resume];
    
    // Because data tasks do not store the data to a file, they are not supported in background sessions.
    // 不支持backgroundSession
}

- (void)dataTaskWithThreeSessionsWithDelegate
{
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:kTestImageURLString1]];
    NSURLSessionDataTask *task1 = [self.defaultSession dataTaskWithRequest:request1];
    NSMutableData *tempData1 = [NSMutableData data];
    NSString *dataKey1 = [[NSNumber numberWithUnsignedInteger:task1.taskIdentifier + kDefaultSessionBaseIdentifier] stringValue];
    [self.tempDataDict setObject:tempData1 forKey:dataKey1];
    [task1 resume];
    
    // 这个不被缓存，完成时缓存delegate不会触发
    // 所以推荐使用block获取数据
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:kTestImageURLString2]];
    NSURLSessionDataTask *task2 = [self.ephemeralSession dataTaskWithRequest:request2];
    NSMutableData *tempData2 = [NSMutableData data];
    NSString *dataKey2 = [[NSNumber numberWithUnsignedInteger:task1.taskIdentifier + kEphemeralSessionBaseIdentifier] stringValue];
    [self.tempDataDict setObject:tempData2 forKey:dataKey2];
    [task2 resume];
    
    // Because data tasks do not store the data to a file, they are not supported in background sessions.
    // 不支持backgroundSession
}

- (void)multiDataTasksWithDefaultSession
{
    [[self.defaultSession dataTaskWithURL:[NSURL URLWithString:kTestImageURLString1] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"defaultSession_1 : %lu", (unsigned long)[data length]);
    }] resume];
    
    [[self.defaultSession dataTaskWithURL:[NSURL URLWithString:kTestImageURLString2] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"defaultSession_2 : %lu", (unsigned long)[data length]);
    }] resume];
    
    [[self.defaultSession dataTaskWithURL:[NSURL URLWithString:kTestImageURLString3] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"defaultSession_3 : %lu", (unsigned long)[data length]);
    }] resume];
}

- (void)multiDataTasksWithEphemeralSession
{
    [[self.ephemeralSession dataTaskWithURL:[NSURL URLWithString:kTestImageURLString1] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"ephemeralSession_1 : %lu", (unsigned long)[data length]);
    }] resume];
    
    [[self.ephemeralSession dataTaskWithURL:[NSURL URLWithString:kTestImageURLString2] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"ephemeralSession_2 : %lu", (unsigned long)[data length]);
    }] resume];
    
    [[self.ephemeralSession dataTaskWithURL:[NSURL URLWithString:kTestImageURLString3] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"ephemeralSession_3 : %lu", (unsigned long)[data length]);
    }] resume];
}

#pragma mark - 
#pragma mark - download tasks

- (void)downloadTaskWithThreeSessionsWithBlock
{
    // tmp目录,这两个都没有被存贮,下完就被删除了,所以自己存一下文件
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:kTestImageURLString1]];
    [[self.defaultSession downloadTaskWithRequest:request1 completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSLog(@"defaultSession : %@, %lu", location, (unsigned long)[[NSData dataWithContentsOfURL:location] length]);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cacheDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
        NSString *fileName = [location lastPathComponent];
        //[[[location lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpeg"];
        NSString *cacheFile = [cacheDir stringByAppendingPathComponent:fileName];
        NSURL *cacheFileURL = [NSURL fileURLWithPath:cacheFile];
        
        NSError *_error = nil;
        if ([fileManager moveItemAtURL:location
                                 toURL:cacheFileURL
                                 error:&_error]) {
            /* Store some reference to the new URL */
        } else {
            /* Handle the error. */
            NSLog(@"error : %@", [_error localizedDescription]);
        }
    }] resume];
    
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:kTestImageURLString2]];
    [[self.ephemeralSession downloadTaskWithRequest:request2 completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSLog(@"ephemeralSession : %@, %lu", location, (unsigned long)[[NSData dataWithContentsOfURL:location] length]);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cacheDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
        NSString *fileName = [location lastPathComponent];
        //[[[location lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpeg"];
        NSString *cacheFile = [cacheDir stringByAppendingPathComponent:fileName];
        NSURL *cacheFileURL = [NSURL fileURLWithPath:cacheFile];
        
        NSError *_error = nil;
        if ([fileManager moveItemAtURL:location
                                 toURL:cacheFileURL
                                 error:&_error]) {
            /* Store some reference to the new URL */
        } else {
            /* Handle the error. */
            NSLog(@"error : %@", [_error localizedDescription]);
        }
    }] resume];
    
    // !!! : Completion handler blocks are not supported in background sessions. Use a delegate instead.
}

- (void)downloadTaskWithThreeSessionsWithDelegate
{
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:kTestImageURLString1]];
    [[self.defaultSession downloadTaskWithRequest:request1] resume];
    
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:kTestImageURLString2]];
    [[self.ephemeralSession downloadTaskWithRequest:request2] resume];
    
    NSURLRequest *request3 = [NSURLRequest requestWithURL:[NSURL URLWithString:kTestImageURLString3]];
    [[self.backgroundSession downloadTaskWithRequest:request3] resume];
}

- (void)downloadTaskWithBackgroundSessionWithDelegate
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kTestPdfURLString2]];
    NSURLSessionDownloadTask *downloadTask = 
    [self.backgroundSession downloadTaskWithRequest:request];
    [downloadTask resume];
}

// 当然如果如果数据比较大,你可以选择将dataTask转为downloadTask
// 这里我先判断类型，时pdf的话就下载
- (void)changeDataTaskToDownloadTask
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kTestPdfURLString2]];
    NSURLSessionDataTask *dataTask = 
    [self.defaultSession dataTaskWithRequest:request];
    [dataTask resume];
}

- (void)multiDownloadTasksWithEphemeralSession
{
    [[self.ephemeralSession downloadTaskWithURL:[NSURL URLWithString:kTestImageURLString1] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSLog(@"1 : %@", location);
    }] resume];
    
    [[self.ephemeralSession downloadTaskWithURL:[NSURL URLWithString:kTestImageURLString2] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSLog(@"2 : %@", location);
    }] resume];
    
    [[self.ephemeralSession downloadTaskWithURL:[NSURL URLWithString:kTestImageURLString3] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSLog(@"3 : %@", location);
    }] resume];
}


#pragma mark - 
#pragma mark - NSURLSessionDelegate
/* If an application has received an
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * message, the session delegate will receive this message to indicate
 * that all messages previously enqueued for this session have been
 * delivered.  At this time it is safe to invoke the previously stored
 * completion handler, or to begin any internal updates that will
 * result in invoking the completion handler.
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"%s, %d", __func__, __LINE__);
    AppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
    BackgroundCompletionHandler handler = appDelegate.completionHandler;
    if (handler) {
        handler();
    }
}

#pragma mark - 
#pragma mark - NSURLSessionDataDelegate
/* The task has received a response and no further messages will be
 * received until the completion block is called. The disposition
 * allows you to cancel a request or to turn a data task into a
 * download task. This delegate message is optional - if you do not
 * implement it, you can get the response as a property of the task.
 */
- (void)URLSession:(NSURLSession *)session 
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"response MIMEType : %@.", response.MIMEType);
    if ([response.MIMEType rangeOfString:@"pdf"].length > 0) {// 如果是pdf的话,文件比较大那么转为下载
        NSLog(@"MIMEType is a pdf, so become download");
        completionHandler(NSURLSessionResponseBecomeDownload);
    } else {
        completionHandler(NSURLSessionResponseAllow);
    }
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)URLSession:(NSURLSession *)session 
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    NSLog(@"MIMEType is a pdf, has become download");
}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use 
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session 
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if (session == self.defaultSession) {
        NSString *dataKey = [[NSNumber numberWithUnsignedInteger:dataTask.taskIdentifier + kDefaultSessionBaseIdentifier] stringValue];
        NSMutableData *tempData = [self.tempDataDict objectForKey:dataKey];
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            [tempData appendBytes:bytes length:byteRange.length];
        }];
    } else if (session == self.ephemeralSession) {
        NSString *dataKey = [[NSNumber numberWithUnsignedInteger:dataTask.taskIdentifier + kEphemeralSessionBaseIdentifier] stringValue];
        NSMutableData *tempData = [self.tempDataDict objectForKey:dataKey];
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            [tempData appendBytes:bytes length:byteRange.length];
        }];
    }
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
- (void)URLSession:(NSURLSession *)session 
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse 
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    NSString *dataKey = nil;
    if (session == self.defaultSession) {
        dataKey = [[NSNumber numberWithUnsignedInteger:dataTask.taskIdentifier + kDefaultSessionBaseIdentifier] stringValue];
    } else if (session == self.ephemeralSession) {
        dataKey = [[NSNumber numberWithUnsignedInteger:dataTask.taskIdentifier + kEphemeralSessionBaseIdentifier] stringValue];
        
    }
    NSMutableData *tempData = [self.tempDataDict objectForKey:dataKey];
    NSLog(@"taskIdentifier : %@, data length : %lu", dataKey, (unsigned long)[tempData length]);
    NSLog(@"proposed response : %@", proposedResponse);
    if (proposedResponse) {
        completionHandler(proposedResponse);
    }
}

#pragma mark - 
#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session 
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    NSString *fileName = [location lastPathComponent];
    //[[[location lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpeg"];
    NSString *cacheFile = [cacheDir stringByAppendingPathComponent:fileName];
    NSURL *cacheFileURL = [NSURL fileURLWithPath:cacheFile];
    
    NSError *error = nil;
    if ([fileManager moveItemAtURL:location
                             toURL:cacheFileURL
                             error:&error]) {
        /* Store some reference to the new URL */
    } else {
        /* Handle the error. */
        NSLog(@"error : %@", [error localizedDescription]);
    }
    
//    NSCachedURLResponse *cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:downloadTask.response data:[NSData dataWithContentsOfURL:location]];
//    [session.configuration.URLCache storeCachedResponse:cachedURLResponse forRequest:downloadTask.currentRequest];

    NSLog(@"Session %@ download task %@ finished downloading to URL %@\n", session, downloadTask, location);
}

- (void)URLSession:(NSURLSession *)session 
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
{
//    double p = (double)totalBytesWritten / totalBytesExpectedToWrite;
//    NSLog(@"downloadTask : %@, %.1f%%", downloadTask, p * 100.0);
}

- (void)URLSession:(NSURLSession *)session 
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
//    NSLog(@"Session %@ download task %@ resumed at offset %lld bytes out of an expected %lld bytes.\n",
//          session, downloadTask, fileOffset, expectedTotalBytes);
}

#pragma mark - 

@end
