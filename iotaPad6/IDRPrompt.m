//
//  IDRPrompt.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-09-17.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IDRPrompt.h"

@implementation IDRPrompt

@synthesize lang = _lang;
@synthesize promptString = _promptString;

static NSString *kLangKey = @"langKey";
static NSString *kPromptStringKey = @"promptStringKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.lang = [aDecoder decodeObjectForKey:kLangKey];
        self.promptString = [aDecoder decodeObjectForKey:kPromptStringKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.lang forKey:kLangKey];
    [aCoder encodeObject:self.promptString forKey:kPromptStringKey];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    self.lang = [attribs valueForKey:@"lang"];
}

- (void)addContent:(NSString *)str {
    [self.promptString appendString:str];
}

- (void)dealloc {
    self.lang = nil;
    self.promptString = nil;
    [super dealloc];
}

@end
