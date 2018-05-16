//
//  URLPuller.h
//  URLPullerLab
//
//  Created by aarthur on 5/16/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLPuller : NSObject

- (void)downloadUrlsAsync:(NSArray*)urls;
- (void)waitUntilAllDownloadsFinish;
- (NSString*)downloadedPathForURL:(NSURL*)url;

@end
