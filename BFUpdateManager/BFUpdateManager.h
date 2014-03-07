//
//  BFUpdateManager.h
//  BFUpdateManager
//
//  Created by Balázs Faludi on 06.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFUpdate.h"

typedef NSComparisonResult (^BFVersionComparator)(NSString *, NSString *);
typedef NSString* (^BFVersionDetector)();

@protocol BFUpdateManagerDelegate;

@interface BFUpdateManager : NSObject

+ (NSString *)bundleShortVersionString;

+ (void)setVersionComparator:(BFVersionComparator)comparator;

+ (NSComparisonResult)compareVersion:(NSString *)version1 toVersion:(NSString *)version2;

+ (void)registerUpdateFromVersion:(NSString *)fromVersion toVersion:(NSString *)toVersion updates:(BFUpdateBlock)updateBlock completion:(BFUpdateCompletionBlock)completionBlock;
+ (void)updateToCurrentVersion:(NSString *)currentVersion previousVersionDetector:(BFVersionDetector)detector;

@end


