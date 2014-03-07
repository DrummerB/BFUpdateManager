//
//  BFUpdate.m
//  BFVersionManager
//
//  Created by Balázs Faludi on 07.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "BFUpdate.h"

@implementation BFUpdate

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; %@ -> %@>", NSStringFromClass([self class]), self, _fromVersion, _toVersion];
}

@end
