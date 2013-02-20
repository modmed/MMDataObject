//
//  TestLogWithNestedObjects.m
//  MMDataObject
//
//  Created by Ben Rigas on 2/18/13.
//  Copyright (c) 2013 Ben Rigas. All rights reserved.
//

#import "TestLogWithNestedObjects.h"
#import "TestThing.h"

@implementation TestLogWithNestedObjects

- (id)init
{
    self = [super init];
    if (self) {
        [self registerClass:[TestThing class] forCollectionName:@"things"]; // can this be guessed?
    }
    return self;
}

@end
