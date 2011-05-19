//
//  IssueTemplateDB.m
//  iotaPad6
//
//  Created by Martin on 2011-02-18.
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
//  Storage for all available issue templates

#import "IssueTemplateDB.h"
#import "IssueTemplateDescriptor.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface  IssueTemplateDB ()
@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) NSMutableArray *templates;

- (void)parse;

@end


@implementation IssueTemplateDB

@synthesize parser = _parser;
@synthesize templates = _templates;

+ (NSArray *)allTemplateDescriptors {
    IssueTemplateDB *itdb = [[self alloc] init];
    [itdb parse];
    NSArray *templates = [itdb.templates retain];
    [itdb release];
    return [templates autorelease];
}

- (id)init {
    if ((self = [super init])) {
        _parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"templates" ofType:@"xml"]]];
        _templates = [[NSMutableArray alloc] initWithCapacity:50];
    }
    return self;
}

- (void)dealloc {
    self.parser = nil;
    self.templates = nil;
    [super dealloc];
}

- (void)parse {
    self.parser.delegate = self;
    [self.parser parse];
    self.parser.delegate = nil;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Error handling
// -----------------------------------------------------------

- (void)fatalError:(NSString *)errorMsg parser:(NSXMLParser *)parser {
	NSString *msg = [NSString stringWithFormat:@"Line %d: %@", [parser lineNumber], errorMsg];
    NSLog(@"!!! Fatal error: %@", errorMsg);
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	[parser abortParsing];
    self.parser = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSString *errMsg = [NSString stringWithFormat:@"Parser error in line %d: %@", [parser lineNumber], [parseError localizedDescription]];
    NSLog(@"%@", errMsg);
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Tag handling
// -----------------------------------------------------------

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"template"]) {
        NSString *title = [attributeDict valueForKey:@"title"];
        NSString *resourceName = [attributeDict valueForKey:@"resourceName"];
        NSString *resourceType = [attributeDict valueForKey:@"resourceType"];
        IssueTemplateDescriptor *itd = [IssueTemplateDescriptor descriptorWithTitle:title resourceName:resourceName resourceType:resourceType];
        [self.templates addObject:itd];
//        NSLog(@"%@, %@, %@", title, resourceName, resourceType);
    }
}



@end
