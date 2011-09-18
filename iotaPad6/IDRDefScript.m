//
//  IDRObsDefScript.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-09-17.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IDRDefScript.h"
#import "IDRDefScriptParameter.h"

@implementation IDRDefScript

@synthesize language = _language;
@synthesize script = _script;
@synthesize scriptType = _scriptType;
@synthesize returnType = _returnType;
@synthesize parameters = _parameters;

static NSString *kLanguageKey = @"languageKey";
static NSString *kScriptKey = @"scriptKey";
static NSString *kScriptTypeKey = @"scriptTypeKey";
static NSString *kReturnTypeKey = @"returnTypeKey";
static NSString *kParametersKey = @"parametersKey";

- (void)dealloc {
    self.language = nil;
    self.script = nil;
    self.scriptType = nil;
    self.returnType = nil;
    self.parameters = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.language = [aDecoder decodeObjectForKey:kLanguageKey];
        self.script = [aDecoder decodeObjectForKey:kScriptKey];
        self.scriptType = [aDecoder decodeObjectForKey:kScriptTypeKey];
        self.returnType = [aDecoder decodeObjectForKey:kReturnTypeKey];
        self.parameters = [aDecoder decodeObjectForKey:kParametersKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.language forKey:kLanguageKey];
    [aCoder encodeObject:self.script forKey:kScriptKey];
    [aCoder encodeObject:self.scriptType forKey:kScriptTypeKey];
    [aCoder encodeObject:self.returnType forKey:kReturnTypeKey];
    [aCoder encodeObject:self.parameters forKey:kParametersKey];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    [super takeAttributes:attribs];
    self.language = [attribs valueForKey:@"language"];
    self.scriptType = [attribs valueForKey:@"type"];
    self.returnType = [attribs valueForKey:@"value"];
}

- (void)addCData:(NSString *)cdata {
    [self.script appendString:cdata];
}

- (void)addParameter:(IDRDefScriptParameter *)parameter {
    [self.parameters addObject:parameter];
}

@end
