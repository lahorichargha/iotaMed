//
//  IDRObsDefScript.m
//  iotaPad6
//
//  Copyright © 2011, MITM AB, Sweden
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1.  Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//  2.  Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//  3.  Neither the name of MITM AB nor the name iotaMed®, nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY MITM AB ‘’AS IS’’ AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MITM AB BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "IDRDefScript.h"
#import "IDRDefScriptParameter.h"
#import "NSString+iotaAdditions.h"

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
    if (_script == nil)
        _script = [[NSMutableString alloc] init];
    [_script appendString:cdata];
}

- (void)addParameter:(IDRDefScriptParameter *)parameter {
    [self.parameters addObject:parameter];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug
// -----------------------------------------------------------

- (void)dumpWithIndent:(NSUInteger)indent {
    NSLog(@"%@script, lang:%@, type:%@, return:%@", [NSString spacesOfLength:indent], self.language, self.scriptType, self.returnType);
    NSLog(@"%@%@", [NSString spacesOfLength:indent], self.script);
    for (IDRDefScriptParameter *param in self.parameters)
        [param dumpWithIndent:(indent + 4)];
}

@end
