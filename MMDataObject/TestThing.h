//
//  TestThing.h
//  MMDataObject
//
//  Created by Ben Rigas on 2/17/13.
//  Copyright (c) 2013 Ben Rigas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDataObject.h"

@interface TestThing : MMDataObject

@property (nonatomic, strong) NSString* time;
@property (nonatomic, strong) NSString* money;
@property (nonatomic, strong) NSString* fingers;

@end
