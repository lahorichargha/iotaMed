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
#import "NSString+iotaAdditions.h"

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

// the following two must be equal and synched, since the obsGetType function relies on it,
static NSString *typeAttrib[] = {@"none", @"numeric", @"string", @"formattedstring", @"check", @"select", @"multiselect", nil};

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

- (IDRPrompt *)idrPromptForLanguage:(NSString *)language {
    for (IDRPrompt *prompt in self.prompts)
        if ([prompt.lang isEqualToString:language])
            return prompt;
    return nil;
}

- (NSString *)promptForLanguage:(NSString *)language {
    IDRPrompt *prompt = [self idrPromptForLanguage:language];
    if (prompt)
        return prompt.promptString;
    else
        return nil;
}

- (IDRSelect *)selectForValue:(NSString *)value {
    for (IDRSelect *select in self.selects)
        if ([select.value isEqualToString:value])
            return select;
    return nil;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------

- (enum eObsDefType)obsDefType {
    for (enum eObsDefType i = eObsDefTypeNone; i < eObsDefTypeCount ; i++) {
        if ([typeAttrib[i] isEqualToString:self.type])
            return i;
    }
    return eObsDefTypeNone;
}

- (NSMutableArray *)prompts {
    if (_prompts == nil) {
        _prompts = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return [[_prompts retain] autorelease];
}

- (NSMutableArray *)selects {
    if (_selects == nil) {
        _selects = [[NSMutableArray alloc] initWithCapacity:5]; 
    }
    return [[_selects retain] autorelease];
}

- (NSMutableArray *)values {
    if (_values == nil) {
        _values = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return [[_values retain] autorelease];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Merge
// -----------------------------------------------------------

- (BOOL)canMergePrompts:(IDRObsDef *)other {
    for (IDRPrompt *prompt in other.prompts) {
        // we have to make sure that any prompts from other for a certain language either does not exist
        // in our own collection of prompts, or if it does, that it is identical
        NSString *myPrompt = [self promptForLanguage:prompt.lang];
        if (myPrompt != nil && ![prompt.promptString isEqualToString:myPrompt])
            return NO;
    }
    return YES;
}

- (BOOL)canMergeSelects:(IDRObsDef *)other {
    for (IDRSelect *select in other.selects) {
        // same principle: any select in other either needs to be new, or needs to be identical
        // to an existing select
        IDRSelect *old = [self selectForValue:select.value];
        if (old != nil && ![old canMerge:select])
            return NO;
    }
    return YES;
}

- (BOOL)canMergeValues:(IDRObsDef *)other {
    //TODO:
    // !!!:
    // needs fleshing out
    return YES;
}

- (BOOL)canMerge:(NSString *)left right:(NSString *)right {
    return left == nil || ![left iotaIsNonEmpty] || right == nil || ![right iotaIsNonEmpty] || [left isEqualToString:right];
}

- (NSString *)mergeStrings:(NSString *)left right:(NSString *)right {
    // assumes you already know they can be merged
    return (left != nil && [left iotaIsNonEmpty]) ? left : right;
}

- (void)mergePrompts:(IDRObsDef *)other {
    for (IDRPrompt *prompt in other.prompts) {
        IDRPrompt *myPrompt = [self idrPromptForLanguage:prompt.lang];
        if (!myPrompt && prompt.lang != nil)
            [self addPrompt:prompt];
    }
    [self cleanup];
}

- (void)mergeSelects:(IDRObsDef *)other {
    for (IDRSelect *select in other.selects) {
        IDRSelect *mySelect = [self selectForValue:select.value];
        if (mySelect != nil)
            [mySelect merge:select];
        else
            [self.selects addObject:other];
    }
}

- (void)cleanup {
    // clean out prompts with no language
    NSMutableArray *objectsToRemove = [NSMutableArray array];
    for (IDRPrompt *p in self.prompts) 
        if (p.lang == nil || ![p.lang iotaIsNonEmpty])
            [objectsToRemove addObject:p];
    [_prompts removeObjectsInArray:objectsToRemove];
}

- (void)mergeValues:(IDRObsDef *)other {
    
}

- (BOOL)merge:(IDRObsDef *)other {
    if ([self canMerge:self.type right:other.type] &&
        [self canMerge:self.dimension right:other.dimension] &&
        [self canMerge:self.format right:other.format] &&
        [self canMerge:self.defaultSelect right:other.defaultSelect] &&
        [self canMergePrompts:other] &&
        [self canMergeSelects:other] &&
        [self canMergeValues:other]) {
        
        NSLog(@"merging obsdef: %@", self.name);
        self.type = [self mergeStrings:self.type right:other.type];
        self.dimension = [self mergeStrings:self.dimension right:other.dimension];
        self.format = [self mergeStrings:self.format right:other.format];
        self.defaultSelect = [self mergeStrings:self.defaultSelect right:other.defaultSelect];
        [self mergePrompts:other];
        [self mergeSelects:other];
        [self mergeValues:other];
        return YES;
    }
    else {
        return NO;
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug
// -----------------------------------------------------------

- (void)dumpWithIndent:(NSUInteger)indent {
    NSLog(@"%@name:%@, type:%@, dim:%@, format:%@, default:%@", 
          [NSString spacesOfLength:indent],
          self.name, self.type, self.dimension, self.format, self.defaultSelect);
    for (IDRPrompt *prompt in self.prompts)
        [prompt dumpWithIndent:(indent + 4)];
    for (IDRSelect *select in self.selects)
        [select dumpWithIndent:(indent + 4)];
    for (IDRValue *value in self.values)
        [value dumpWithIndent:(indent + 4)];
}

@end
