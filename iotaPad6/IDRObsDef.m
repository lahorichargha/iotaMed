//
//  IDRObsDefVariable.m
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

#import "IDRObsDef.h"
#import "IDRPrompt.h"
#import "IDRSelect.h"
#import "IDRValue.h"
#import "Funcs.h"

@implementation IDRObsDef

@synthesize type = _type;
@synthesize dimension = _dimension;
@synthesize format = _format;
@synthesize defaultSelect = _defaultPrompt;
@synthesize prompts = _prompts;
@synthesize selects = _selects;
@synthesize values = _values;

static NSString *kTypeKey = @"typeKey";
static NSString *kDimensionKey = @"dimensionKey";
static NSString *kFormatKey = @"formatKey";
static NSString *kDefaultSelectKey = @"defaultSelectKey";
static NSString *kPromptsKey = @"promptsKey";
static NSString *kSelectsKey = @"selectsKey";
static NSString *kValuesKey = @"valuesKey";

static NSString *typeAttrib[] = {@"numeric", @"string", @"formattedstring", nil};

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.type = [aDecoder decodeObjectForKey:kTypeKey];
        self.dimension = [aDecoder decodeObjectForKey:kDimensionKey];
        self.format = [aDecoder decodeObjectForKey:kFormatKey];
        self.defaultSelect = [aDecoder decodeObjectForKey:kDefaultSelectKey];
        self.prompts = [aDecoder decodeObjectForKey:kPromptsKey];
        self.selects = [aDecoder decodeObjectForKey:kSelectsKey];
        self.values = [aDecoder decodeObjectForKey:kValuesKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.type forKey:kTypeKey];
    [aCoder encodeObject:self.dimension forKey:kDimensionKey];
    [aCoder encodeObject:self.format forKey:kFormatKey];
    [aCoder encodeObject:self.defaultSelect forKey:kDefaultSelectKey];
    [aCoder encodeObject:self.prompts forKey:kPromptsKey];
    [aCoder encodeObject:self.selects forKey:kSelectsKey];
    [aCoder encodeObject:self.values forKey:kValuesKey];
}

- (void)dealloc {
    self.type = nil;
    self.dimension = nil;
    self.format = nil;
    self.defaultSelect = nil;
    self.prompts = nil;
    self.selects = nil;
    self.values = nil;
    [super dealloc];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    [super takeAttributes:attribs];
    self.type = [attribs valueForKey:@"type"];
    if (!isValidChoice(self.type, typeAttrib))
        [NSException raise:@"bad type in obsdef element" format:@"found illegal type attribute: %@", self.type];
    self.dimension = [attribs valueForKey:@"dimension"];
    self.format = [attribs valueForKey:@"format"];
    self.defaultSelect = [attribs valueForKey:@"default"];
}

- (void)addPrompt:(IDRPrompt *)prompt {
    [self.prompts addObject:prompt];
}

- (void)addSelect:(IDRSelect *)selection {
    [self.selects addObject:selection];
}

- (IDRSelect *)getSelectWithValue:(NSString *)value {
    for (IDRSelect *select in self.selects) {
        if ([select.value isEqualToString:value])
            return select;
    }
    return nil;
}

- (IDRSelect *)getDefaultSelect {
    return [self getSelectWithValue:self.defaultSelect];
}

@end
