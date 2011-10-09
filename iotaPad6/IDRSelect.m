//
//  IDRSelect.m
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

#import "IDRSelect.h"
#import "IDRPrompt.h"
#import "NSString+iotaAdditions.h"

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

- (void)dealloc {
    self.value = nil;
    self.prompts = nil;
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.value forKey:kValueKey];
    [aCoder encodeObject:self.prompts forKey:kPromptsKey];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    self.value = [attribs valueForKey:@"value"];
}

- (void)addPrompt:(IDRPrompt *)prompt {
    if (_prompts == nil)
        _prompts = [[NSMutableArray alloc] init];
    [_prompts addObject:prompt];
}

- (NSString *)promptForLang:(NSString *)lang {
    for (IDRPrompt *prompt in self.prompts) {
        if ([prompt.lang isEqualToString:lang])
            return prompt.promptString;
    }
    if ([self.prompts count] > 0)
        return ((IDRPrompt *)[self.prompts objectAtIndex:0]).promptString;
    else
        return @"<No prompts found>";
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Merge
// -----------------------------------------------------------

- (IDRPrompt *)promptForLanguage:(NSString *)lang {
    for (IDRPrompt *prompt in self.prompts) {
        if ([prompt.lang isEqualToString:lang])
            return prompt;
    }
    return nil;
}

- (BOOL)canMerge:(IDRSelect *)other {
    for (IDRPrompt *prompt in other.prompts) {
        // we have to make sure that any prompts from other for a certain language either does not exist
        // in our own collection of prompts, or if it does, that it is identical
        IDRPrompt *myPrompt = [self promptForLanguage:prompt.lang];
        if (myPrompt != nil && ![prompt.promptString isEqualToString:myPrompt.promptString])
            return NO;
    }
    return YES;
}

- (void)merge:(IDRSelect *)other {
    for (IDRPrompt *prompt in other.prompts) {
        IDRPrompt *myPrompt = [self promptForLanguage:prompt.lang];
        if (myPrompt == nil)
            [self addPrompt:prompt];
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug
// -----------------------------------------------------------

- (void)dumpWithIndent:(NSUInteger)indent {
    NSLog(@"%@value: %@", [NSString spacesOfLength:indent], self.value);
    for (IDRPrompt *prompt in self.prompts)
        [prompt dumpWithIndent:(indent + 4)];
}

@end
