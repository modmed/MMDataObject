//
//  TestLogWithAliases.h
//  MMDataObject
//
//  Created by Ben Rigas on 2/18/13.
//  Copyright (c) 2013 Ben Rigas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDataObject.h"

@interface TestLogWithAliases : MMDataObject

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSDate* createdAt;
@property (nonatomic, retain) NSArray* things;

@end
