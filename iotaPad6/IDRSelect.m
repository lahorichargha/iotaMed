//
//  IDRSelect.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-09-17.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IDRSelect.h"
#import "IDRPrompt.h"

@implementation IDRSelect

@synthesize value = _value;
@synthesize prompts = _prompts;

static NSString *kValueKey = @"valueKey";
static NSString *kPromptsKey = @"promptsKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.value = [aDecoder decodeObjectForKey:kValueKey];
        self.prompts = [aDecoder decodeObjectForKey:kPromptsKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.value forKey:kValueKey];
    [aCoder encodeObject:self.prompts forKey:kPromptsKey];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    self.value = [attribs valueForKey:@"value"];
}

- (void)addPrompt:(IDRPrompt *)prompt {
    [self.prompts addObject:prompt];
}

@end
