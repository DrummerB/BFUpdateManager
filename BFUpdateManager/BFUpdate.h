//
//  BFUpdate.h
//  BFVersionManager
//
//  Created by Balázs Faludi on 07.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^BFUpdateBlock)();
typedef void (^BFUpdateCompletionBlock)(BOOL);

@interface BFUpdate : NSObject

@property (nonatomic, copy) NSString *fromVersion;
@property (nonatomic, copy) NSString *toVersion;
@property (nonatomic, copy) BFUpdateBlock updateBlock;
@property (nonatomic, copy) BFUpdateCompletionBlock completionBlock;

@end
