//
//  IDRDataDictionary.m
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

#import "IDRDataDictionary.h"
#import "IDRObsDef.h"
#import "IDRDefScript.h"
#import "IDRDefConstant.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface  IDRDataDictionary ()

@property (nonatomic, retain) NSMutableArray *obsDefs;
@property (nonatomic, retain) NSMutableArray *constants;
@property (nonatomic, retain) NSMutableArray *scripts;

@end


@implementation IDRDataDictionary

@synthesize obsDefs = _obsDefs;
@synthesize constants = _constants;
@synthesize scripts = _scripts;

static NSString *kObsDefsKey = @"obsDefsKey";
static NSString *kConstantsKey = @"constantsKey";
static NSString *kScriptsKey = @"scriptsKey";

- (id)init {
    NSLog(@"Data dictionary init");
    if ((self = [super init])) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSLog(@"Data dictionary initWithCoder");
    if ((self = [super init])) {
        self.obsDefs = [aDecoder decodeObjectForKey:kObsDefsKey];
        self.constants = [aDecoder decodeObjectForKey:kConstantsKey];
        self.scripts = [aDecoder decodeObjectForKey:kScriptsKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSLog(@"Data Dictionary encodeWithCoder");
    [aCoder encodeObject:self.obsDefs forKey:kObsDefsKey];
    [aCoder encodeObject:self.constants forKey:kConstantsKey];
    [aCoder encodeObject:self.scripts forKey:kScriptsKey];
}

- (void)dealloc {
    self.obsDefs = nil;
    self.constants = nil;
    self.scripts = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------

- (NSMutableArray *)obsDefs {
    if (_obsDefs == nil) {
        _obsDefs = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return [[_obsDefs retain] autorelease];
}

- (NSMutableArray *)constants {
    if (_constants == nil) {
        _constants = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return [[_constants retain] autorelease];
}

- (NSMutableArray *)scripts {
    if (_scripts == nil) {
        _scripts = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return [[_scripts retain] autorelease];
}

- (IDRObsDef *)getObsDef:(NSString *)name {
    NSLog(@"getObsDef: %@, there are %d obsDefs to search", name, [self.obsDefs count]);
    for (IDRObsDef *od in self.obsDefs) {
        if ([od.name isEqualToString:name]) {
            NSLog(@"   found it: %@", od);
            return od;
        }
    }
    NSLog(@"   found nothing");
    return nil;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Functions
// -----------------------------------------------------------

- (void)addObsDef:(IDRObsDef *)obsDef {
    NSLog(@"adding obsdef to dictionary: %@", obsDef.name);
    [self.obsDefs addObject:obsDef];
}

- (void)addConstant:(IDRDefConstant *)constant {
    [self.constants addObject:constant];
}

- (void)addScript:(IDRDefScript *)script {
    [self.scripts addObject:script];
}


@end
