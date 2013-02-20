//
//  MMDataObjectTests.m
//  MMDataObjectTests
//
//  Created by Ben Rigas on 2/19/13.
//  Copyright (c) 2013 Ben Rigas. All rights reserved.
//

#import "MMDataObjectTests.h"
#import "TestLog.h"
#import "TestThing.h"
#import "TestLogWithAliases.h"
#import "TestLogWithNestedObjects.h"
#import "TestLogWithFormatters.h"

@implementation MMDataObjectTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testBasic
{
    NSDictionary* attributes = @{
                                 @"name": @"Bob Bobberson",
                                 @"title": @"Software Engineer",
                                 @"createdAt": @"2013-02-16 12:12:12",
                                 };
    
    TestLog* log = [[TestLog alloc] initWithAttributes:attributes];
    
    STAssertTrue([log.name isEqualToString:[attributes objectForKey:@"name"]], @"Testing name property");
    STAssertTrue([log.title isEqualToString:[attributes objectForKey:@"title"] ], @"Testing title property");
    STAssertTrue([log.createdAt.description isEqualToString:@"2013-01-16 17:12:12 +0000"], @"createdAt");
}

- (void) testAliases {
    NSDictionary* attributes = @{
                                 @"first_name": @"Bob Bobberson",
                                 @"title": @"Software Engineer",
                                 @"created_at": @"2013-02-16 12:12:12",
                                 @"things" : @[
                                         @{
                                             @"time": @"5",
                                             @"money": @"42",
                                             @"fingers": @"10"
                                             },
                                         @{
                                             @"time": @"5",
                                             @"money": @"42",
                                             @"fingers": @"10"
                                             },
                                         @{
                                             @"time": @"5",
                                             @"money": @"42",
                                             @"fingers": @"10"
                                             }
                                         ]
                                 };
    
    TestLogWithAliases* log = [[TestLogWithAliases alloc] initWithAttributes:attributes];
    
    STAssertTrue([log.name isEqualToString:[attributes objectForKey:@"first_name"]], @"Testing name property");
    STAssertTrue([log.title isEqualToString:[attributes objectForKey:@"title"] ], @"Testing title property");
    STAssertTrue([log.createdAt.description isEqualToString:@"2013-01-16 17:12:12 +0000"], @"created_at");
    
    STAssertTrue(log.things.count == 3, @"Test nested objects");
    
    for (id object in log.things) {
        STAssertTrue([object isKindOfClass:[NSDictionary class]], @"Without registering, nested classes are NSDictionary");
    }
}

- (void) testNestedObjects {
    NSDictionary* attributes = @{
                                 @"name": @"Bob Bobberson",
                                 @"title": @"Software Engineer",
                                 @"createdAt": @"2013-02-16 12:12:12",
                                 @"things" : @[
                                         @{
                                             @"time": @"5",
                                             @"money": @"42",
                                             @"fingers": @"10"
                                             },
                                         @{
                                             @"time": @"5",
                                             @"money": @"42",
                                             @"fingers": @"10"
                                             },
                                         @{
                                             @"time": @"5",
                                             @"money": @"42",
                                             @"fingers": @"10"
                                             }
                                         ]
                                 };
    
    TestLogWithNestedObjects* log = [[TestLogWithNestedObjects alloc] initWithAttributes:attributes];
    
    STAssertTrue([log.name isEqualToString:[attributes objectForKey:@"name"]], @"Testing name property");
    STAssertTrue([log.title isEqualToString:[attributes objectForKey:@"title"] ], @"Testing title property");
    STAssertTrue([log.createdAt.description isEqualToString:@"2013-01-16 17:12:12 +0000"], @"createdAt");
    
    STAssertTrue(log.things.count == 3, @"Test nested objects");
    
    for (id object in log.things) {
        STAssertTrue([object isKindOfClass:[TestThing class]], @"With registering, class should be TestThing");
    }
}

- (void) testFormatters {
    NSDictionary* attributes = @{
                                 @"name": @"Bob Bobberson",
                                 @"title": @"Software Engineer",
                                 @"createdAt": @"2013-02-16 12:12:12",
                                 @"things" : @[
                                         @{
                                             @"time": @"5",
                                             @"money": @"42",
                                             @"fingers": @"10"
                                             },
                                         @{
                                             @"time": @"5",
                                             @"money": @"42",
                                             @"fingers": @"10"
                                             },
                                         @{
                                             @"time": @"5",
                                             @"money": @"42",
                                             @"fingers": @"10"
                                             }
                                         ]
                                 };
    
    TestLogWithFormatters* log = [[TestLogWithFormatters alloc] initWithAttributes:attributes];
    
    STAssertTrue([log.name isEqualToString:@"LOL!!!! Bob Bobberson"], @"Testing name property");
    STAssertTrue([log.title isEqualToString:[attributes objectForKey:@"title"] ], @"Testing title property");
    STAssertTrue([log.createdAt.description isEqualToString:@"2013-01-16 17:12:12 +0000"], @"createdAt");
    
    STAssertTrue(log.things.count == 3, @"Test nested objects");
    
    for (id object in log.things) {
        STAssertTrue([object isKindOfClass:[TestThing class]], @"With registering, class should be TestThing");
    }
}

@end
