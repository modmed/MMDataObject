//
//  TestLogWithFormatters.m
//  MMDataObject
//
//  Created by Ben Rigas on 2/19/13.
//  Copyright (c) 2013 Ben Rigas. All rights reserved.
//

#import "TestLogWithFormatters.h"
#import "TestThing.h"

@implementation TestLogWithFormatters

- (id)init
{
    self = [super init];
    if (self) {
        [self registerClass:[TestThing class] forCollectionName:@"things"]; // can this be guessed?
        [self addFormatterForPropertyName:@"name" input:[TestThing lolify] output:[TestThing unlolify]];
    }
    return self;
}

@end
