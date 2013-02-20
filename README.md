MMDataObject
============

Early Release
-------------

This early release is just a little bit more than a proof of concept, but it should still be useful. Next we will be adding support for more foundation classes to be automatically mapped, as well as doing some more in depth testing. If you have feedback, email me at ben.rigas@modmed.com.

Usage
-----

Copy MMDataObject.m and MMDataObject.h into your project and make MMDataObject be the base class that your data objects use.

Overview
--------

It is a common thing to have an iOS application talk to a REST API, where the API format is JSON based. You might be using AFNetworking or something else for making your HTTP calls, but it's still up to you to parse the response and map it to your data objects. If your data object has properties that match what the API sends and receives, then this is a really tedious thing to have to do.

MMDataObject takes advantage of the objective-c runtime methods to automatically do this mapping for you. Just use MMDataObject as the base class of your data objects and you'll get an "initWithAttributes:" and "attributes" method for free. MMDataObject will also try to automatically map properties to the correct classes, so when the API sends you a string for a date you automatically get an NSDate instead.

Customization
-------------

All the customization your need to do takes place in the init method of your data object classes. See the following section for examples.

Aliases
-------

If your API properties don't exactly match names, you can provide an alias for your property so that it gets mapped correctly.

```
- (id)init
{
    self = [super init];
    if (self) {
        [self setAlias:@"first_name" forPropertyName:@"name"];
        [self setAlias:@"created_at" forPropertyName:@"createdAt"];
    }
    return self;
}
```

Formatters
----------

If you would like to do some reformatting of a parameter value as it comes in (and goes back out), you can provide a formatter block for both input and outputs.

```
- (id)init
{
    self = [super init];
    if (self) {
        [self addFormatterForPropertyName:@"name" input:[TestThing lolify] output:[TestThing unlolify]];
    }
    return self;
}
```

Nested collections of other objects
-----------------------------------

If your API returns a nested array of other objects, you can automatically create those as well. You'll have to register the class associated with the collection like this.

```
- (id)init
{
    self = [super init];
    if (self) {
        [self registerClass:[TestThing class] forCollectionName:@"things"];
    }
    return self;
}
```

TODO
----

+ Add more automatic type matching
+ Provide some validation
+ Test with more complex objects
+ Test with Core Data/NSManagedObject and other data classes
+ More sample code that actually consumes an API
