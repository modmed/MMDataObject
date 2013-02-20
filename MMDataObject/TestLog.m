//
//  TestLog.m
//  MMDataObject
//
//  Created by Ben Rigas on 2/12/13.
//  Copyright (c) 2013 Ben Rigas. All rights reserved.
//

#import "TestLog.h"
#import "TestThing.h"

@implementation TestLog

- (id) init {
    self = [super init];
    if (self) {
        //[self addFormatterForPropertyName:@"name" input:[TestLog lolify] output:[TestLog unlolify]];

    }
    
    return self;
}

@end



















//        [self setAlias:@"first_name" forPropertyName:@"name"];
//        [self setAlias:@"created_at" forPropertyName:@"createdAt"];

//        [self addFormatterForPropertyName:@"name" input:[TestLog lolify] output:[TestLog unlolify]];

//        [self registerClass:[TestThing class] forCollectionName:@"things"]; // can this be guessed?

//        FormatBlock what = ^(NSString* value) {
//            return [NSString stringWithFormat:@"WHAT: %@", value];
//        };