//
//  IDRObservation.h
//  iotaPad6
//
//  Created by Martin on 2011-03-03.
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

#import <Foundation/Foundation.h>
#import "IDRAttribs.h"

@class IDRObsDefinition;
//@class IDRContact;
@class IDRObsDef;

@interface IDRObservation : NSObject <IDRAttribs, NSCoding, NSCopying> {
    
}

// the name and type are redundant, held in IDRObsDefinition, but held here before 
// IDRObsDefinition is created, and then maintained in both places
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *type;

@property (nonatomic, readonly) BOOL isNumeric;       // else it's a string
@property (nonatomic, readonly) BOOL isCheck;

@property (nonatomic, retain) NSString *direction;
@property (nonatomic, retain) IDRObsDefinition *obsDefinition;
@property (nonatomic, retain) IDRObsDef *obsDef;
@property (nonatomic, retain) NSMutableArray *options;      // used for 'select'

- (BOOL)hasGet;
- (BOOL)hasPut;
- (BOOL)hasGetPut;
- (BOOL)isSelect;
- (BOOL)isMultiSelect;

- (void)dumpWithIndent:(NSUInteger)indent;

@end
