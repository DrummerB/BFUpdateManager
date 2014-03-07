//
//  AppDelegate.m
//  Demo
//
//  Created by Balázs Faludi on 07.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "AppDelegate.h"
#import "BFUpdateManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

	BFUpdateBlock updates = ^BOOL {
		for (int i = 0; i < 10; i++) {
			NSLog(@"%d", i);
			[NSThread sleepForTimeInterval:0.1];
		}
		return YES;
	};
	
//	[BFUpdateManager setCurrentVersion:[BFUpdateManager bundleShortVersionString]];
	
	[BFUpdateManager registerUpdateFromVersion:@"1.0" toVersion:@"1.1" updates:updates completion:^(BOOL finished) {
		NSLog(@"Updated to 1.1");
	}];
	
//	[BFUpdateManager registerUpdateFromVersion:@"1.1" toVersion:@"1.2" updates:updates completion:^(BOOL finished) {
//		NSLog(@"Updated to 1.2");
//	}];
//	
//	[BFUpdateManager registerUpdateFromVersion:@"1.1" toVersion:@"1.0" updates:updates completion:^(BOOL finished) {
//		NSLog(@"Updated to 1.3");
//	}];
	
//	[BFUpdateManager registerUpdateFromVersion:@"1.2" toVersion:@"1.3" updates:updates completion:^(BOOL finished) {
//		NSLog(@"Updated to 1.3");
//	}];
//	
//	[BFUpdateManager registerUpdateFromVersion:@"1.5" toVersion:@"1.6" updates:updates completion:^(BOOL finished) {
//		NSLog(@"Updated to 1.6");
//	}];
//	
//	[BFUpdateManager registerUpdateFromVersion:@"1.6" toVersion:@"1.7" updates:updates completion:^(BOOL finished) {
//		NSLog(@"Updated to 1.7");
//	}];
//	
//	[BFUpdateManager registerUpdateFromVersion:@"1.6" toVersion:@"1.8" updates:updates completion:^(BOOL finished) {
//		NSLog(@"Updated to 1.8");
//	}];
	
	[BFUpdateManager updateToCurrentVersion:[BFUpdateManager bundleShortVersionString] previousVersionDetector:^NSString *{
		return @"1.0";
	}];
	
	
	
//	[BFUpdateManager registerUpdateFromVersion:nil toVersion:@"1.0" updates:updates completion:^(BOOL finished) {
//		NSLog(@"Updated to 1.0");
//	}];
//	
//	[BFUpdateManager registerUpdateFromVersion:@"1.0" toVersion:@"1.1" updates:updates completion:^(BOOL finished) {
//		NSLog(@"Updated to 1.1");
//	}];
//	
//	[BFUpdateManager registerUpdateFromVersion:@"1.1" toVersion:@"1.2" updates:updates completion:^(BOOL finished) {
//		NSLog(@"Updated to 1.2");
//	}];
//	
//	[BFUpdateManager registerUpdateFromVersion:@"1.2.5" toVersion:@"1.3" updates:updates completion:^(BOOL finished) {
//		NSLog(@"Updated to 1.3");
//	}];
//	
//	
//	
//	[BFUpdateManager applyRequiredUpdatesWithPreviousVersionDetector:^NSString *{
//		if (/*some document exists*/) return @"1.0";
//		return nil;
//	}];

	
	
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

@end
