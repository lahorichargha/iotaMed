//
//  IotaXMLParser.m
//  iotaPad6
//
//  Created by Martin on 2011-03-13.
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

#import "IotaXMLParser.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface IotaXMLParser ()

@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) NSMutableArray *elementStack;
@property (nonatomic, retain) NSMutableArray *currentPath;

@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation IotaXMLParser

@synthesize parser = _parser;
@synthesize elementStack = _elementStack;
@synthesize charBuffer = _charBuffer;
@synthesize currentPath = _currentPath;

- (id)initWithData:(NSData *)data {
    if ((self = [super init])) {
        _parser = [[NSXMLParser alloc] initWithData:data];
        _elementStack = [[NSMutableArray alloc] initWithCapacity:10];
        _charBuffer = [[NSMutableString alloc] initWithCapacity:20];
        _currentPath = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (id)initWithString:(NSString *)xml {
    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
    return [self initWithData:data];
}

- (id)initWithXmlFile:(NSString *)fileName {
    if ((self = [super init])) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"]];
        _parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        _elementStack = [[NSMutableArray alloc] initWithCapacity:10];
        _charBuffer = [[NSMutableString alloc] initWithCapacity:20];
        _currentPath = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)dealloc {
    self.parser = nil;
    self.elementStack = nil;
    self.charBuffer = nil;
    self.currentPath = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Current path handling
// -----------------------------------------------------------

- (void)addPathComponent:(NSString *)component {
    [self.currentPath addObject:component];
}

- (void)subtractComponent:(NSString *)component {
    NSString *lastComponent = [self.currentPath lastObject];
    if (![lastComponent isEqualToString:component]) {
        [NSException raise:@"component mismatch while subtracting" format:@"Got: %@, expected: %@", component, lastComponent];
    }
    [self.currentPath removeLastObject];
}

- (NSString *)currentPathAsString {
    return [self.currentPath componentsJoinedByString:@"/"];
}



// -----------------------------------------------------------
#pragma mark -
#pragma mark Error handling
// -----------------------------------------------------------

- (void)fatalError:(NSString *)errorMsg {
	NSString *msg = [NSString stringWithFormat:@"Line %d: %@", [self.parser lineNumber], errorMsg];
    NSLog(@"!!! Fatal error: %@", errorMsg);
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	[self.parser abortParsing];
    self.parser = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSString *errMsg = [NSString stringWithFormat:@"Parser error in line %d: %@", [parser lineNumber], [parseError localizedDescription]];
    NSLog(@"%@", errMsg);
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Element stack
// -----------------------------------------------------------

- (BOOL)addToTos:(id)element usingSelector:(SEL)selector {
    id tos = [self topOfStackElement];
    if ([tos respondsToSelector:selector]) {
        [tos performSelector:selector withObject:element];
        return YES;
    }
    else {
        [self fatalError:[NSString stringWithFormat:@"Could not add %@ to top of stack element of class: %@", [element class], [tos class]]];
        return NO;
    }
}

- (void)pushElement:(id)theElement {
    [self.elementStack addObject:theElement];
}

- (id)popElement {
    if ([self.elementStack count] < 1)
        [self fatalError:@"Element stack underflow"];
    id lastObject = [[self.elementStack lastObject] retain];
    [self.elementStack removeLastObject];
    return [lastObject autorelease];
}

- (id)topOfStackElement {
    if ([self.elementStack count] < 1) {
        [self fatalError:@"Stack unexpectedly empty"];
    }
    return [[[self.elementStack lastObject] retain] autorelease];
}

- (id)rootElement {
    if ([self.elementStack count] != 1) {
        NSLog(@"stack should only contain one element, but contains instead:");
        for (id obj in self.elementStack)
            NSLog(@"on stack: %@", [obj class]);
        [self fatalError:@"Elementstack is not equal to one element after end of parsing"];
        return nil;
    }
    return [self topOfStackElement];
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Content handling
// -----------------------------------------------------------

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    id tos = [self topOfStackElement];
    if ([tos respondsToSelector:@selector(addContent:)]) {
        [tos performSelector:@selector(addContent:) withObject:string];
    }
    else {
        [_charBuffer appendString:string];
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Exec
// -----------------------------------------------------------

- (void)parse {
    self.parser.delegate = self;
    [self.parser parse];
    self.parser.delegate = nil;
}


@end
