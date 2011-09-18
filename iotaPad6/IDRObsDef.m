//
//  IDRObsDefVariable.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-09-17.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IDRObsDef.h"
#import "IDRPrompt.h"
#import "IDRSelect.h"

@implementation IDRObsDef

@synthesize type = _type;
@synthesize dimension = _dimension;
@synthesize format = _format;
@synthesize defaultPrompt = _defaultPrompt;
@synthesize prompts = _prompts;
@synthesize selects = _selects;

static NSString *kTypeKey = @"typeKey";
static NSString *kDimensionKey = @"dimensionKey";
static NSString *kFormatKey = @"formatKey";
static NSString *kDefaultPromptKey = @"defaultPromptKey";
static NSString *kPromptsKey = @"promptsKey";
static NSString *kSelectsKey = @"selectsKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.type = [aDecoder decodeObjectForKey:kTypeKey];
        self.dimension = [aDecoder decodeObjectForKey:kDimensionKey];
        self.format = [aDecoder decodeObjectForKey:kFormatKey];
        self.defaultPrompt = [aDecoder decodeObjectForKey:kDefaultPromptKey];
        self.prompts = [aDecoder decodeObjectForKey:kPromptsKey];
        self.selects = [aDecoder decodeObjectForKey:kSelectsKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.type forKey:kTypeKey];
    [aCoder encodeObject:self.dimension forKey:kDimensionKey];
    [aCoder encodeObject:self.format forKey:kFormatKey];
    [aCoder encodeObject:self.defaultPrompt forKey:kDefaultPromptKey];
    [aCoder encodeObject:self.prompts forKey:kPromptsKey];
    [aCoder encodeObject:self.selects forKey:kSelectsKey];
}


- (void)dealloc {
    self.type = nil;
    self.dimension = nil;
    self.format = nil;
    self.defaultPrompt = nil;
    self.prompts = nil;
    self.selects = nil;
    [super dealloc];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    [super takeAttributes:attribs];
    self.type = [attribs valueForKey:@"type"];
    self.dimension = [attribs valueForKey:@"dimension"];
    self.format = [attribs valueForKey:@"format"];
    self.defaultPrompt = [attribs valueForKey:@"default"];
}

- (void)addPrompt:(IDRPrompt *)prompt {
    [self.prompts addObject:prompt];
}

- (void)addSelect:(IDRSelect *)selection {
    [self.selects addObject:selection];
}


@end
