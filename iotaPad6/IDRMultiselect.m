//
//  IDRMultiselect.m
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/23/11.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IDRMultiselect.h"

@implementation IDRMultiselect

@synthesize value = _value;
@synthesize content = _content;
@synthesize selected = _selected;

static NSString *kValueKey = @"valueKey";
static NSString *kContentKey = @"contentKey";
static NSString *kSelectedKey = @"selectedKey";

- (void)dealloc {
    self.value = nil;
    self.content = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.value = [aDecoder decodeObjectForKey:kValueKey];
        self.content = [aDecoder decodeObjectForKey:kContentKey];
        self.selected = [aDecoder decodeBoolForKey:kSelectedKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.value forKey:kValueKey];
    [aCoder encodeObject:self.content forKey:kContentKey];
    [aCoder encodeBool:self.selected forKey:kSelectedKey];
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
