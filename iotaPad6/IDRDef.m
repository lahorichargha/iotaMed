//
//  IDRObsDef.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-09-17.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IDRDef.h"

@implementation IDRDef

@synthesize name = _name;

static NSString *kNameKey = @"nameKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.name = [aDecoder decodeObjectForKey:kNameKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:kNameKey];
}

- (void)dealloc {
    self.name = nil;
    [super dealloc];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    self.name = [attribs valueForKey:@"name"];
}

@end
