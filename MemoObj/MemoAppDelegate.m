//
//  MemoAppDelegate.m
//  MemoObj
//
//  Created by Sanmy on 15-4-17.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import "MemoAppDelegate.h"
#import <ENSDK.h>
@implementation MemoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSString *sandbox_host = ENSessionHostSandbox;
    
    [ENSession setSharedSessionConsumerKey:KconsumerKey consumerSecret:KconsumerSecret optionalHost:sandbox_host];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[ENSession sharedSession] handleOpenURL:url];
}

@end
