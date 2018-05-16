//
//  URLPuller.m
//  URLPullerLab
//
//  Created by aarthur on 5/16/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "URLPuller.h"

@interface URLPuller() <NSURLSessionDelegate>
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSURLSession *urlSession;
@end

@implementation URLPuller

- (void)processURL:(NSURL*)URL strongSelf:(URLPuller*)strongSelf
{
    if (self.urlSession == nil) {
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    NSURLRequest *request;
    __weak __typeof(self)weakSelf = self;
    
    request = [NSURLRequest requestWithURL:URL];
    [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *asString;
        NSString *filename;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSError *saveError = nil;
        
        if (error) {
            NSLog(@"Download Error Ocurred: %@",[error localizedDescription]);
        }else{
        
            asString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            filename = [strongSelf downloadedPathForURL:URL];
            [asString writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&saveError];
            
            if (saveError) {
                NSLog(@"Save Error Ocurred: %@",[saveError localizedDescription]);
            }
            
        }
    }];
}

- (void)downloadUrlsAsync:(NSArray*)urls
{
    __weak __typeof(self)weakSelf = self;
    
    self.operationQueue = [NSOperationQueue new];
    for (NSURL *nextURL in urls) {
        NSBlockOperation *blockOp;
        
        blockOp = [NSBlockOperation blockOperationWithBlock:^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            [strongSelf processURL:nextURL strongSelf:strongSelf];
        }];
        [self.operationQueue addOperation:blockOp];
    }
}

- (void)waitUntilAllDownloadsFinish
{
    if (self.operationQueue == nil) return;
    [self.operationQueue waitUntilAllOperationsAreFinished];
    self.operationQueue = nil;
    self.urlSession = nil;
}

- (NSString*)downloadedPathForURL:(NSURL*)url
{
    NSString *lastComp = [url lastPathComponent];
    return [NSString stringWithFormat:@"%@.download",lastComp];
}

#pragma mark NSURLSessionDelegate
    
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    self.urlSession = nil;
}

@end
