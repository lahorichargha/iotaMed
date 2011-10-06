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

@implementation IDRSelect

@synthesize value = _value;
@synthesize content = _content;
@synthesize prompts = _prompts;

static NSString *kValueKey = @"valueKey";
static NSString *kContentKey = @"contentKey";
static NSString *kPromptsKey = @"promptsKey";

- (void)dealloc {
    self.value = nil;
    self.content = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.value = [aDecoder decodeObjectForKey:kValueKey];
        self.content = [aDecoder decodeObjectForKey:kContentKey];
        self.prompts = [aDecoder decodeObjectForKey:kPromptsKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.value forKey:kValueKey];
    [aCoder encodeObject:self.content forKey:kContentKey];
    [aCoder encodeObject:self.prompts forKey:kPromptsKey];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    self.value = [attribs valueForKey:@"value"];
}

- (void)addContent:(NSString *)chars {
    if (_content == nil) {
        _content = [[NSMutableString alloc] initWithCapacity:20];
    }
    [_content appendString:chars];
}

- (void)addPrompt:(IDRPrompt *)prompt {
    [self.prompts addObject:prompt];
}

@end
