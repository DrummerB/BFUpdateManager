//
//  BFUpdateManager.m
//  BFUpdateManager
//
//  Created by Balázs Faludi on 06.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "BFUpdateManager.h"
#import "BFUpdate.h"

#define kBFBundleVersionKey		@"CFBundleShortVersionString"
#define kBFUpdatedToVersionKey	@"BFUpdateManagerUpdatedToVersion"

@interface BFUpdateManager ()
@property (nonatomic, copy) NSArray *updates;
@property (nonatomic, copy) BFVersionComparator versionComparator;
@end

@implementation BFUpdateManager

+ (instancetype)sharedManager
{
    static id sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[self alloc] init];
        /* Do any other initialisation stuff here */
    });
    return sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) {
		_updates = @[];
		
    }
    return self;
}

+ (NSString *)bundleShortVersionString {
	return [[NSBundle mainBundle] infoDictionary][kBFBundleVersionKey];
}

+ (void)setVersionComparator:(BFVersionComparator)comparator {
	[BFUpdateManager sharedManager].versionComparator = comparator;
}

// Remove any trailing ".0" components for comparison.
// I.e. "1.2.000" becomes "1.2" and "1.0.0" becomes "1".
// As a result "1.0.0" is considered the same version as "1.0" and "1".
// You can override this behavior by implementing the appropriate delegate methods.
+ (NSString *)trimVersion:(NSString *)version {
	NSArray *components = [version componentsSeparatedByString:@"."];
	NSString *lastComponent = components.lastObject;
	NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:lastComponent];
	NSCharacterSet *zeroSet = [NSCharacterSet characterSetWithCharactersInString:@"0"];
	if (components.count > 1 && [zeroSet isSupersetOfSet:charSet]) {
		// Last version component only contains zeros and can be trimmed for comparison.
		NSString *trimmedVersion = [version substringToIndex:version.length - lastComponent.length - 1];
		return [self trimVersion:trimmedVersion];
	}
	return version;
}

+ (NSComparisonResult)compareVersion:(NSString *)version1 toVersion:(NSString *)version2 {
	if ([BFUpdateManager sharedManager].versionComparator) {
		return [BFUpdateManager sharedManager].versionComparator(version1, version2);
	}
//	if (version1 == nil && version2 == nil) {
//		return NSOrderedSame;
//	}
//	if (version1 == nil) {
//		return NSOrderedAscending;
//	}
//	if (version2 == nil) {
//		return NSOrderedDescending;
//	}
	NSString *trimmed1 = [self trimVersion:version1];
	NSString *trimmed2 = [self trimVersion:version2];
	return [trimmed1 compare:trimmed2 options:NSNumericSearch];
}

+ (void)registerUpdateFromVersion:(NSString *)fromVersion toVersion:(NSString *)toVersion updates:(BFUpdateBlock)updateBlock completion:(BFUpdateCompletionBlock)completionBlock {
	NSAssert(fromVersion, @"Can't register nil as fromVersion");
	NSAssert(toVersion, @"Can't register nil as toVersion");
	NSAssert([self compareVersion:fromVersion toVersion:toVersion] == NSOrderedAscending, @"fromVersion has to be smaller than toVersion");
	
	BFUpdate *update = [[BFUpdate alloc] init];
	update.fromVersion = fromVersion;
	update.toVersion = toVersion;
	update.updateBlock = updateBlock;
	update.completionBlock = completionBlock;
	[BFUpdateManager sharedManager].updates = [[BFUpdateManager sharedManager].updates arrayByAddingObject:update];
}

+ (void)updateToCurrentVersion:(NSString *)currentVersion previousVersionDetector:(BFVersionDetector)detector {
	
	// Determine the version we should start looking for updates.
	NSString *fromVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kBFUpdatedToVersionKey];
	if (!fromVersion) {
		// No version has been saved yet to NSUserDefaults. This means this is the first launch of this version of the app.
		// It could be either the first launch of a freshly installed copy, or the first launch after updating from a
		// version that did not use BFUpdateManager yet. BFUpdateManager can't differentiate between these two possiblities
		// automatically (there is no reliable way that I know of). To figure this out, we use the heuristic provided.
		if (detector) {
			fromVersion = detector();
		}
		if (!fromVersion) {
			// If there was no previous version detector passed, that means the developer assumes it won't be necessary,
			// because all versions contain BFUpdateManager and in that case the only reason why we shouldn't have a
			// saved version in NSUserDefaults is a freshly installed app.
			// If the previous version detector found no indication that this was an update from an old version, we
			// can assume that is is a fresh install. In that case we can just set this version and not update anything.
			[[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kBFUpdatedToVersionKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
			return;
		}
		// Otherwise, if the previous version detector found evidence that this is an update of an old version (such as existing
		// documents or preferences), we should try to apply the registered updates from the returned version on.
	}
	
	// Sort updates.
	NSArray *updates = [BFUpdateManager sharedManager].updates;
	NSArray *sortedUpdates = [updates sortedArrayUsingComparator:^NSComparisonResult(BFUpdate *update1, BFUpdate *update2) {
		NSComparisonResult fromComparison = [self compareVersion:update1.fromVersion toVersion:update2.fromVersion];
		if (fromComparison == NSOrderedSame) {
			NSComparisonResult toComparison = [self compareVersion:update1.toVersion toVersion:update2.toVersion];
			if (toComparison == NSOrderedAscending) return NSOrderedDescending;
			if (toComparison == NSOrderedDescending) return NSOrderedAscending;
			return NSOrderedSame;
		}
		return fromComparison;
	}];
	
	// Find the next update to apply.
	NSInteger index = [sortedUpdates indexOfObjectWithOptions:0 passingTest:^BOOL(BFUpdate *update, NSUInteger idx, BOOL *stop) {
		NSComparisonResult fromComparison = [self compareVersion:fromVersion toVersion:update.fromVersion];
		NSComparisonResult toComparison = [self compareVersion:currentVersion toVersion:update.toVersion];
		BOOL fromPreviousOrLater = (fromComparison == NSOrderedSame || fromComparison == NSOrderedAscending);
		BOOL toCurrentOrEarlier = (toComparison == NSOrderedSame || toComparison == NSOrderedDescending);
		return  fromPreviousOrLater && toCurrentOrEarlier;
	}];
	if (index == NSNotFound) {
		return;
	}
	BFUpdate *update = sortedUpdates[index];
	
	// Start the next update's update block in the background.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		BOOL finished = update.updateBlock();
		
		// Once the update block is done, run the completion block on the main thread,
		// write the latest version to NSUserDefaults and continue with the next update.
		dispatch_async(dispatch_get_main_queue(), ^{
			update.completionBlock(finished);
			
			[[NSUserDefaults standardUserDefaults] setObject:update.toVersion forKey:kBFUpdatedToVersionKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[self updateToCurrentVersion:currentVersion previousVersionDetector:detector];
		});
	});
	
}

@end
