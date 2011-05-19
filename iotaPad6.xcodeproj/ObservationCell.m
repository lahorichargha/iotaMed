//
//  ObservationCell.m
//  iotaPad6
//
//  Created by Martin on 2011-03-14.
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

#import "ObservationCell.h"
#import "IDRObservation.h"
#import "IDRObsDefinition.h"
#import "IDRContact.h"
#import "IDRValue.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation ObservationCell

@synthesize observation = _observation;
@synthesize prompt = _prompt;
@synthesize textField = _textField;
@synthesize contact = _contact;

#define kOffsetFromTop              5
#define kPromptOffsetFromLeft       5
#define kPromptWidth                100
#define kPromptHeight               20
#define kValueOffsetFromLeft        150
#define kValueWidth                 400
#define kValueHeight                28


- (void)dealloc {
    self.observation = nil;
    self.prompt = nil;
    self.textField = nil;
    self.contact = nil;
    [super dealloc];
}

+ (ObservationCell *)cellForTableView:(UITableView *)tableView idrObservation:(IDRObservation *)observation contact:(IDRContact *)contact {
    static NSString *cellID = @"cellID";
    
    ObservationCell *cell = (ObservationCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[ObservationCell alloc] init] autorelease];
        cell.prompt = [[[UILabel alloc] initWithFrame:CGRectMake(kPromptOffsetFromLeft, kOffsetFromTop, 
                                                                kPromptWidth, kPromptHeight)] autorelease];
        [cell addSubview:cell.prompt];
        
        cell.textField = [[[UITextField alloc] initWithFrame:CGRectMake(kValueOffsetFromLeft, kOffsetFromTop, 
                                                                        kValueWidth, kValueHeight)] autorelease];
        cell.textField.borderStyle = UITextBorderStyleRoundedRect;
        cell.textField.delegate = cell;
        
        [cell addSubview:cell.textField];
    }
    cell.observation = observation;
    cell.contact = contact;
    cell.prompt.text = observation.obsDefinition.name;

    IDRValue *value = [observation.obsDefinition valueForContact:contact];
    if (value == nil) {
        value = [[[IDRValue alloc] init] autorelease];
    }
    cell.textField.text = value.value;
    return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"TextFieldDidEndEditing: %@", textField.text);
    IDRObsDefinition *obsDef = self.observation.obsDefinition;
    [obsDef setValue:textField.text forContact:self.contact];
}

@end
