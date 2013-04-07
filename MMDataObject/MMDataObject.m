//
//  MMDataObject.m
//  MMDataObject
//
//  Created by Ben Rigas on 2/16/13.
//  Copyright (c) 2013 Ben Rigas. All rights reserved.
//

#import "MMDataObject.h"
#import <objc/runtime.h>

#import "LaunchPadIdentity.h"

#pragma mark - Object Property

@interface MMDataObjectProperty : NSObject

@property BOOL isReadOnly;
@property BOOL isCopy;
@property BOOL isRetained;
@property BOOL isNonatomic;
@property BOOL isDynamic;
@property BOOL isWeak;
@property BOOL isEligibleForGarbageCollection;
@property (nonatomic, strong) NSString* customGetterName;
@property (nonatomic, strong) NSString* customSetterName;
@property (nonatomic, strong) NSString* typeOldStyle;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* ivarName;

@end

@implementation MMDataObjectProperty

// see https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html

- (id)initWithPropertyDescription:(NSString*)propertyDescription
{
    self = [super init];
    if (self) {
        NSArray* elements = [propertyDescription componentsSeparatedByString:@","];
        if ([elements count] > 2) {
            // example: T@"NSString",&,N,V_name
            self.type = [[elements objectAtIndex:0] substringFromIndex:1];
            if ([self.type characterAtIndex:0] == '@') {
                self.type = [self.type substringWithRange:NSMakeRange(2, self.type.length-3)];
            }
            
            // V<ivar_name>, strip out the V
            self.ivarName = [[elements lastObject] substringFromIndex:1];
            
            for (int x = 1; x < elements.count; x++) {
                NSString* element = [elements objectAtIndex:x];
                if ([element isEqualToString:@"R"]) {
                    self.isReadOnly = YES;
                }
                else if ([element isEqualToString:@"C"]) {
                    self.isCopy = YES;
                }
                else if ([element isEqualToString:@"&"]) {
                    self.isRetained = YES;
                }
                else if ([element isEqualToString:@"N"]) {
                    self.isNonatomic = YES;
                }
                else if ([element isEqualToString:@"D"]) {
                    self.isDynamic = YES;
                }
                else if ([element isEqualToString:@"W"]) {
                    self.isWeak = YES;
                }
                else if ([element isEqualToString:@"P"]) {
                    self.isEligibleForGarbageCollection = YES;
                }
                else if ([element characterAtIndex:0] == 'G') {
                    self.customGetterName = [element substringFromIndex:1];
                }
                else if ([element characterAtIndex:0] == 'S') {
                    self.customSetterName = [element substringFromIndex:1];
                }
                else if ([element characterAtIndex:0] == 't') {
                    self.typeOldStyle = [element substringFromIndex:1];
                }
            }
        }
    }
    return self;
}

@end

#pragma mark - MMDataObject

@implementation MMDataObject

- (id)init
{
    self = [super init];
    if (self) {
        propertyAliases = [[NSMutableDictionary alloc] init];
        inputPropertyFormatters = [[NSMutableDictionary alloc] init];
        outputPropertyFormatters = [[NSMutableDictionary alloc] init];
        collectionNameClasses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Input

- (id) initWithAttributes:(NSDictionary*)attributes {
    self = [self init];
    if (self) {
        NSUInteger propertyCount;
        objc_property_t* propertyList = class_copyPropertyList([self class], &propertyCount);
        
        for (int i = 0; i < propertyCount; i++) {
            objc_property_t property = propertyList[i];
            
            NSString* propertyName = [NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
            NSString* propertyAlias = [self aliasForPropertyName:propertyName];
            NSString* propertyDescription = [NSString stringWithCString:property_getAttributes(property) encoding:NSASCIIStringEncoding];
            
            if (propertyName) {
                MMDataObjectProperty* propertyAttributes = [[MMDataObjectProperty alloc] initWithPropertyDescription:propertyDescription];
                
                id attribute = nil;
                if (propertyAlias) {
                    attribute = [attributes objectForKey:propertyAlias];
                }
                else {
                    attribute = [attributes objectForKey:propertyName];
                }
                
                if (attribute != nil) {
                    // apply formatter, if any
                    FormatBlock format = [self inputFormatterForPropertyName:propertyName];
                    if (format) {
                        attribute = format(attribute);
                    }
                    else {
                        // if there's no formatter, then do default mappings
                        // FIXME to not use blocks here, smells funny
                        if ([propertyAttributes.type isEqualToString:@"NSDate"]) {
			    FormatBlock stringToDate = [MMDataObject stringToDateWithFormat:@"yyyy-mm-dd HH:mm:ss"];
                            attribute = stringToDate(attribute);
                        }
                        else if ([propertyAttributes.type isEqualToString:@"NSArray"]
                                 || [propertyAttributes.type isEqualToString:@"NSMutableArray"]) {
                            NSMutableArray* objects = [[NSMutableArray alloc] init];
                            Class objectClass = [self classForCollectionName:propertyName];
                            
                            if (objectClass) {
                                for (NSDictionary* attributes in attribute) {
                                    [objects addObject:[[objectClass alloc] initWithAttributes:attributes]];
                                }
                                attribute = objects;
                            }
                        }
                        else if ([NSClassFromString(propertyAttributes.type) instancesRespondToSelector:@selector(initWithAttributes:)]) {
                            attribute = [[NSClassFromString(propertyAttributes.type) alloc] initWithAttributes:attribute];
                        }
                        
                        // TODO
                        // NSNumber
                        // NSDecimalNumber
                        // ??
                    }
                    [self setValue:attribute forKey:propertyName];
                }
            }
        }
        
        free(propertyList);
    }
    
    return self;
}

#pragma mark - Output

- (NSMutableDictionary*) attributes {
    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
    
    NSUInteger propertyCount;
    objc_property_t* propertyList = class_copyPropertyList([self class], &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = propertyList[i];
        
        NSString* propertyName = [NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
        NSString* propertyAlias = [self aliasForPropertyName:propertyName];
        NSString* propertyDescription = [NSString stringWithCString:property_getAttributes(property) encoding:NSASCIIStringEncoding];
        
        if (propertyName) {
            id attribute = [self valueForKey:propertyName];
            MMDataObjectProperty* propertyAttributes = [[MMDataObjectProperty alloc] initWithPropertyDescription:propertyDescription];
            
            if (attribute != nil) {
                
                FormatBlock format = [self outputFormatterForPropertyName:propertyName];
                if (format) {
                    attribute = format(attribute);
                }
                else {
                    // if there's no formatter, then do default mappings
                    // FIXME to not use blocks here, smells funny
                    if ([propertyAttributes.type isEqualToString:@"NSDate"]) {
                        FormatBlock dateToString = [MMDataObject dateToStringWithFormat:@"yyyy-mm-dd HH:mm:ss"];
                        attribute = dateToString(attribute);
                    }
                    else if ([propertyAttributes.type isEqualToString:@"NSArray"]
                             || [propertyAttributes.type isEqualToString:@"NSMutableArray"]) {
                        NSMutableArray* objects = [[NSMutableArray alloc] init];
                        
                        for (id object in attribute) {
                            if ([object respondsToSelector:@selector(attributes)]) {
                                [objects addObject:[object attributes]];
                            }
                        }
                        
                        if ([objects count] > 0) {
                            attribute = objects;
                        }
                    }
                }
                
                if (propertyAlias) {
                    [attributes setValue:attribute forKey:propertyAlias];
                }
                else {
                    [attributes setValue:attribute forKey:propertyName];
                }
            }
        }
    }
    
    free(propertyList);
    
    return attributes;
}

#pragma mark - Aliases

- (void) setAlias:(NSString*)alias forPropertyName:(NSString*)propertyName {
    if (alias && propertyName) {
        [propertyAliases setValue:alias forKey:propertyName];
    }
}

- (NSString*) aliasForPropertyName:(NSString*)propertyName {
    NSString* alias = nil;
    
    if (propertyName) {
        alias = [propertyAliases objectForKey:propertyName];
    }
    
    return alias;
}

#pragma mark - Formatters

- (void) addFormatterForPropertyName:(NSString *)name
                               input:(FormatBlock)inputFormat
                              output:(FormatBlock)outputFormat {
    if (name && inputFormat) {
        [inputPropertyFormatters setValue:inputFormat forKey:name];
    }
    
    if (name && outputFormat) {
        [outputPropertyFormatters setValue:outputFormat forKey:name];
    }
}

- (FormatBlock) inputFormatterForPropertyName:(NSString*)propertyName {
    FormatBlock inputFormat = [inputPropertyFormatters valueForKey:propertyName];
    
    return inputFormat;
}

- (FormatBlock) outputFormatterForPropertyName:(NSString*)propertyName {
    FormatBlock outputFormat = [outputPropertyFormatters valueForKey:propertyName];
    
    return outputFormat;
}

#pragma mark - Class for collection

- (void) registerClass:(Class)className forCollectionName:(NSString *)collectionName {
    if (className && collectionName) {
        [collectionNameClasses setValue:className forKey:collectionName];
    }
}

- (Class) classForCollectionName:(NSString *)collectionName {
    Class collectionClass = [collectionNameClasses valueForKey:collectionName];
    
    return collectionClass;
}

#pragma mark - Built in formatter blocks

+ (FormatBlock)lolify {
    FormatBlock lolify = ^(NSString* value) {
        return [NSString stringWithFormat:@"LOL!!!! %@", value];
    };
    
    return [lolify copy];
}

+ (FormatBlock)unlolify {
    FormatBlock unlolify = ^(NSString* value) {
        return [value substringFromIndex:8];
    };
    
    return [unlolify copy];
}

+ (FormatBlock)stringToDateWithFormat:(NSString*)dateFormat {
    FormatBlock stringToDate = ^(NSString* value) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormat];
        
        return [dateFormatter dateFromString:value];
    };
    
    return [stringToDate copy];
}

+ (FormatBlock)dateToStringWithFormat:(NSString*)dateFormat {
    FormatBlock dateToString = ^(NSDate* date) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormat];
        
        return [dateFormatter stringFromDate:date];
    };
    
    return [dateToString copy];
}

@end

