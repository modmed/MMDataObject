//
//  MMDataObject.h
//  MMDataObject
//
//  Created by Ben Rigas on 2/16/13.
//  Copyright (c) 2013 Ben Rigas. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^FormatBlock)(id);

@interface MMDataObject : NSObject
{

@private
    NSDictionary* propertyAliases;
    NSDictionary* inputPropertyFormatters;
    NSDictionary* outputPropertyFormatters;
    NSDictionary* collectionNameClasses; // weird name?
}

- (id) initWithAttributes:(NSDictionary*)attributes;
- (NSMutableDictionary*) attributes;

- (void) addFormatterForPropertyName:(NSString*)name input:(FormatBlock)inputFormat output:(FormatBlock)outputFormat;
- (FormatBlock) inputFormatterForPropertyName:(NSString*)propertyName;
- (FormatBlock) outputFormatterForPropertyName:(NSString*)propertyName;

- (void) setAlias:(NSString*)alias forPropertyName:(NSString*)propertyName;
- (NSString*) aliasForPropertyName:(NSString*)propertyName;

- (void) registerClass:(Class)className forCollectionName:(NSString *)collectionName;
- (Class) classForCollectionName:(NSString*)collectionName;

+ (FormatBlock)lolify;
+ (FormatBlock)unlolify;
+ (FormatBlock)stringToDateWithFormat:(NSString*)dateFormat;
+ (FormatBlock)dateToStringWithFormat:(NSString*)dateFormat;

@end
