//
//  IDRWorksheets.m
//  iotaPad6
//
//  Created by Martin on 2011-03-08.
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

#import "IDRWorksheets.h"
#import "IDRWorksheet.h"
#import "IDRBlock.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface IDRWorksheets ()
@property (nonatomic, retain) NSMutableArray *worksheets;
@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation IDRWorksheets

@synthesize worksheets = _worksheets;

- (id)init {
    if ((self = [super init])) {
        _worksheets = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

- (void)dealloc {
    self.worksheets = nil;
    [super dealloc];
}

static NSString *kWorksheetsKey = @"worksheetsKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.worksheets = [aDecoder decodeObjectForKey:kWorksheetsKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.worksheets forKey:kWorksheetsKey];
}

- (NSArray *)worksheetsAsArray {
    return self.worksheets;
}

- (IDRWorksheet *)getWorksheetByUuid:(NSString *)uuid {
    for (IDRWorksheet *ws in self.worksheets)
        if ([ws.templateUuid isEqualToString:uuid])
            return ws;
    return nil;
}

- (IDRWorksheet *)addWorksheetIfNotPresent:(IDRWorksheet *)worksheet {
    IDRWorksheet *ws = [self getWorksheetByUuid:worksheet.templateUuid];
    if (ws != nil)
        return ws;
    else {
        [self.worksheets addObject:worksheet];
        return worksheet;
    }
}

- (void)addBlock:(IDRBlock *)block forWorksheet:(IDRWorksheet *)worksheet {
    IDRWorksheet *ws = [self addWorksheetIfNotPresent:worksheet];
    [ws blockAdd:block];
}

- (BOOL)removeWorksheet:(IDRWorksheet *)worksheet {
    NSUInteger worksheetIndex = [self.worksheets indexOfObject:worksheet];
    if (worksheetIndex == NSNotFound)
        return NO;
    [self.worksheets removeObjectAtIndex:worksheetIndex];
    return YES;
}

- (BOOL)removeBlock:(IDRBlock *)block forWorksheet:(IDRWorksheet *)worksheet {
    NSUInteger worksheetIndex = [self.worksheets indexOfObject:worksheet];
    if (worksheetIndex == NSNotFound)
        return NO;
    IDRWorksheet *wsInArray = [self.worksheets objectAtIndex:worksheetIndex];
    NSUInteger blockIndex = [wsInArray indexOfBlock:block];
    if (blockIndex == NSNotFound)
        return NO;
    [wsInArray removeBlockAtIndex:blockIndex];
    return YES;
}

@end
