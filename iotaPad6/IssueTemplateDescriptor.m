//
//  IssueTemplateDescriptor.m
//  iotaPad6
//
//  Created by Martin on 2011-02-18.
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

#import "IssueTemplateDescriptor.h"
#import "IDRWorksheet.h"
#import "XML2IDR.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface IssueTemplateDescriptor ()
@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation IssueTemplateDescriptor

@synthesize title = _title;
@synthesize fromICD10 = _fromICD10;
@synthesize toICD10 = _toICD10;
@synthesize uuid = _uuid;
@synthesize resourceName = _resourceName;
@synthesize resourceType = _resourceType;
@synthesize worksheet = _worksheet;

- (void)dealloc {
    self.title = nil;
    self.fromICD10 = nil;
    self.toICD10 = nil;
    self.uuid = nil;
    self.resourceName = nil;
    self.resourceType = nil;
    self.worksheet = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------

- (NSString *)toICD10 {
    return self.worksheet.toICD10;
}

- (NSString *)fromICD10 {
    return self.worksheet.fromICD10;
}

- (NSString *)displayString {
    return [NSString stringWithFormat:@"%@ %@ - %@", self.title, self.fromICD10, self.toICD10];
}

+ (IssueTemplateDescriptor *)descriptorWithTitle:(NSString *)title resourceName:(NSString *)resourceName resourceType:(NSString *)resourceType {
    IssueTemplateDescriptor *newItd = [[IssueTemplateDescriptor alloc] init];
    newItd.title = title;
    newItd.resourceName = resourceName;
    newItd.resourceType = resourceType;
    return [newItd autorelease];
}

- (void)loadWorksheet {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:self.resourceName ofType:self.resourceType]];
    self.worksheet = [XML2IDR worksheetFromXML:url];
//    [self.worksheet dumpWithIndent:4];
}

- (IDRWorksheet *)worksheet {
    if (_worksheet == nil) {
        [self loadWorksheet];
    }
    return [[_worksheet retain] autorelease];
}

@end
