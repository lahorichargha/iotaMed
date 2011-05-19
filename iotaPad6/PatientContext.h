//
//  PatientContext.h
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

#import <Foundation/Foundation.h>
#import "PatientContextDB.h"

@class IDRContact;
@class IDRBlock;
@class IDRObsDefinition;
@class IDRWorksheet;
@class IDRValue;
@class Patient;

@interface PatientContext : NSObject <NSCoding> {
    
}

@property (nonatomic, assign, getter = isDirty) BOOL dirty;
@property (nonatomic, retain) NSMutableArray *contacts;
@property (nonatomic, retain) IDRContact *currentContact;
@property (nonatomic, retain) NSMutableArray *obsDefinitions;
@property (nonatomic, retain) Patient *patient;

- (id)init;
- (IDRBlock *)blockWithTemplateUuid:(NSString *)blockTemplateUuid inWorksheetWithTemplateUuid:(NSString *)worksheetTemplateUuid;
- (NSArray *)worksheetsWithTemplateUuid:(NSString *)templateUuid;
- (void)addContactAndMakeCurrent:(IDRContact *)contact;
- (IDRObsDefinition *)getOrAddObsDefinitionForName:(NSString *)name type:(NSString *)type;
- (void)addBlock:(IDRBlock *)block toExistingWorksheet:(IDRWorksheet *)worksheet customTitle:(NSString *)customTitle;
- (IDRValue *)getCurrentValueForObsName:(NSString *)name;
- (NSArray *)getAllValuesForObsName:(NSString *)name;
- (NSString *)replaceObsNamesInString:(NSString *)inputStr;

@end
