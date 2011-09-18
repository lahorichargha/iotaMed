//
//  IDRObsDefConstant.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-09-17.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IDRDefConstant.h"

@implementation IDRDefConstant

@synthesize constantValue = _constantValue;

static NSString *kConstantValueKey = @"constantValueKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.constantValue = [aDecoder decodeObjectForKey:kConstantValueKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.constantValue forKey:kConstantValueKey];
}

- (void)dealloc {
    self.constantValue = nil;
    [super dealloc];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    [super takeAttributes:attribs];
}

@end
