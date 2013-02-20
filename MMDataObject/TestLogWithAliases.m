//
//  TestLogWithAliases.m
//  MMDataObject
//
//  Created by Ben Rigas on 2/18/13.
//  Copyright (c) 2013 Ben Rigas. All rights reserved.
//

#import "TestLogWithAliases.h"

@implementation TestLogWithAliases

- (id)init
{
    self = [super init];
    if (self) {
        [self setAlias:@"first_name" forPropertyName:@"name"];
        [self setAlias:@"created_at" forPropertyName:@"createdAt"];
    }
    return self;
}

@end
