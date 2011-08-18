//
//  IDRSelect.m
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/18/11.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "IDRSelect.h"

@implementation IDRSelect

@synthesize value = _value;
@synthesize content = _content;

static NSString *kValueKey = @"valueKey";
static NSString *kContentKey = @"contentKey";

- (void)dealloc {
    self.value = nil;
    self.content = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.value = [aDecoder decodeObjectForKey:kValueKey];
        self.content = [aDecoder decodeObjectForKey:kContentKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.value forKey:kValueKey];
    [aCoder encodeObject:self.content forKey:kContentKey];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    self.value = [attribs valueForKey:@"value"];
}

- (void)addContent:(NSString *)chars {
    if (_content == nil) {
        _content = [[NSMutableString alloc] initWithCapacity:20];
    }
    [_content appendString:chars];
}

@end
