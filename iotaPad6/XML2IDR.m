//
//  XML2IDR.m
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

#import "XML2IDR.h"
#import "IDRWorksheet.h"
#import "IDRBlock.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRAction.h"
#import "IDRImage.h"
#import "IDRTest.h"
#import "IDRDose.h"
#import "IDRDescription.h"
#import "IotaContext.h"
#import "PatientContext.h"

#import "IDRObsDef.h"
#import "IDRDefScript.h"
#import "IDRDefConstant.h"
#import "IDRPrompt.h"
#import "IDRDefScriptParameter.h"
#import "IDRSelect.h"
#import "IDRDataDictionary.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface XML2IDR ()
@property (nonatomic, retain) IDRWorksheet *worksheet;
@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) NSMutableArray *elementStack;

- (id)topOfStackElement;

@end


// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation XML2IDR

@synthesize worksheet = _worksheet;
@synthesize parser = _parser;
@synthesize elementStack = _elementStack;

- (id)initWithParser:(NSXMLParser *)parser {
    if ((self = [super init])) {
        _worksheet = [[IDRWorksheet alloc] init];
        self.parser = parser;
        _elementStack = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)dealloc {
    self.worksheet = nil;
    self.parser = nil;
    self.elementStack = nil;
    [super dealloc];
}

+ (IDRWorksheet *)worksheetFromFileName:(NSString *)fileName {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"]];
    return [self worksheetFromXML:url];
}


+ (IDRWorksheet *)worksheetFromXML:(NSURL *)xml {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:xml];
    XML2IDR *xml2idr = [[XML2IDR alloc] initWithParser:parser];
    parser.delegate = xml2idr;
    
    [parser parse];
    IDRWorksheet *ws = [xml2idr.worksheet retain];
    
//    [ws dumpWithIndent:4];
    [parser release];
    [xml2idr release];
    IDRDataDictionary *dataDic = [IotaContext getCurrentPatientContext].dataDictionary;
    if (![dataDic verifyAndFix])
        NSLog(@"Could not fix up defective data dictionary");
    [[IotaContext getCurrentPatientContext].dataDictionary dumpWithIndent:0];
    return [ws autorelease];
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

- (void)fatalStackPushError:(NSString *)failedElement {
    id tos = [self topOfStackElement];
    [self fatalError:[NSString stringWithFormat:@"Could not add %@ to top of stack element: %@", failedElement, [tos class]] parser:self.parser];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSString *errMsg = [NSString stringWithFormat:@"Parser error in line %d: %@", [parser lineNumber], [parseError localizedDescription]];
    NSLog(@"%@", errMsg);
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Element stack for worksheet
// -----------------------------------------------------------

- (void)pushElement:(id)theElement {
    [self.elementStack addObject:theElement];
}

- (id)popElement {
    if ([self.elementStack count] < 1)
        [self fatalError:@"Element stack underflow" parser:self.parser];
    id lastObject = [[self.elementStack lastObject] retain];
    [self.elementStack removeLastObject];
    return [lastObject autorelease];
}

- (id)topOfStackElement {
    if ([self.elementStack count] < 1) {
        [self fatalError:@"Stack unexpectedly empty" parser:self.parser];
    }
    return [[[self.elementStack lastObject] retain] autorelease];
}

- (IDRWorksheet *)document {
    if ([self.elementStack count] != 1) {
        NSLog(@"stack should only contain one element, but contains instead:");
        for (id obj in self.elementStack)
            NSLog(@"on stack: %@", [obj class]);
        [self fatalError:@"Elementstack is not equal to one element after end of parsing" parser:self.parser];
        return nil;
    }
    return [self topOfStackElement];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Tag handling
// -----------------------------------------------------------


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    id <IDRAttribs> newElement = nil;
    
    @try {
    
        // note that in the following code, 'takeAttributes' should always be done before 'performSelector',
        // since the selector may rely on attributes for particular actions, such as adding to a data
        // dictionary (yes, I realized this the hard way...)
    
        if ([elementName isEqualToString:@"template"]) {
            self.worksheet = [[[IDRWorksheet alloc] init] autorelease];
            newElement = self.worksheet;
            [newElement takeAttributes:attributeDict];
            [self pushElement:newElement];
        }
        
        else if ([elementName isEqualToString:@"description"]) {
            newElement = [[[IDRDescription alloc] init] autorelease];
            id tos = [self topOfStackElement];
            if ([tos respondsToSelector:@selector(setDescription:)]) {
                [newElement takeAttributes:attributeDict];
                [tos performSelector:@selector(setDescription:) withObject:newElement];
                [self pushElement:newElement];
            }
            else {
                [self fatalStackPushError:@"description"];
            }
        }
        else if ([elementName isEqualToString:@"block"]) {
            newElement = [[[IDRBlock alloc] init] autorelease];
            id tos = [self topOfStackElement];
            if ([tos respondsToSelector:@selector(blockAdd:)]) {
                [newElement takeAttributes:attributeDict];
                [tos performSelector:@selector(blockAdd:) withObject:newElement];
                [self pushElement:newElement];
            }
            else {
                [self fatalStackPushError:@"block"];
            }
            
        }
        else if ([elementName isEqualToString:@"item"]) {
            newElement = [[[IDRItem alloc] init] autorelease];
            id tos = [self topOfStackElement];
            if ([tos respondsToSelector:@selector(itemAdd:)]) {
                [newElement takeAttributes:attributeDict];
                [tos performSelector:@selector(itemAdd:) withObject:newElement];
                [self pushElement:newElement];
            }
            else {
                [self fatalStackPushError:@"item"];
            }
        }
        else if ([elementName isEqualToString:@"observation"]) {
            newElement = [[[IDRObservation alloc] init] autorelease];
            id tos = [self topOfStackElement];
            if ([tos respondsToSelector:@selector(setObservation:)]) {
                [newElement takeAttributes:attributeDict];
                [tos performSelector:@selector(setObservation:) withObject:newElement];
                [self pushElement:newElement];
            }
            else {
                [self fatalStackPushError:@"observation"];
            }
        }
        else if ([elementName isEqualToString:@"action"]) {
            newElement = [[[IDRAction alloc] init] autorelease];
            id tos = [self topOfStackElement];
            if ([tos respondsToSelector:@selector(setAction:)]) {
                [newElement takeAttributes:attributeDict];
                [tos performSelector:@selector(setAction:) withObject:newElement];
                [self pushElement:newElement];
            }
            else {
                [self fatalStackPushError:@"action"];
            }
        }
        
        else if ([elementName isEqualToString:@"image"]) {
            newElement = [[[IDRImage alloc] init] autorelease];
            id tos = [self topOfStackElement];
            if ([tos respondsToSelector:@selector(setIdrImage:)]) {
                [newElement takeAttributes:attributeDict];
                [tos performSelector:@selector(setIdrImage:) withObject:newElement];
                [self pushElement:newElement];
            }
            else {
                [self fatalStackPushError:@"image"];
            }
        }
        
        else if ([elementName isEqualToString:@"test"]) {
            newElement = [[[IDRTest alloc] init] autorelease];
            id tos = [self topOfStackElement];
            if ([tos respondsToSelector:@selector(addTest:)]) {
                [newElement takeAttributes:attributeDict];
                [tos performSelector:@selector(addTest:) withObject:newElement];
                [self pushElement:newElement];
            }
            else {
                [self fatalStackPushError:@"test"];
            }
        }
        
        else if ([elementName isEqualToString:@"dose"]) {
            newElement = [[[IDRDose alloc] init] autorelease];
            id tos = [self topOfStackElement];
            if ([tos respondsToSelector:@selector(addDose:)]) {
                [newElement takeAttributes:attributeDict];
                [tos performSelector:@selector(addDose:) withObject:newElement];
                [self pushElement:newElement];
            }
            else {
                [self fatalStackPushError:@"dose"];
            }
        }
        
        // -----------------------------------------------------------
        // data dictionary elements
        
        else if ([elementName isEqualToString:@"obsdef"]) {
            newElement = [[[IDRObsDef alloc] init] autorelease];
            [newElement takeAttributes:attributeDict];
            [self pushElement:newElement];
//            id tos = [self topOfStackElement];
//            if ([tos respondsToSelector:@selector(addObsDef:)]) {
//                [newElement takeAttributes:attributeDict];
//                [tos performSelector:@selector(addObsDef:) withObject:newElement];
//                [self pushElement:newElement];
//            }
//            else {
//                [self fatalStackPushError:@"obsdef"];
//            }
        }
        
        else if ([elementName isEqualToString:@"constant"]) {
            newElement = [[[IDRDefConstant alloc] init] autorelease];
            [newElement takeAttributes:attributeDict];
            [self pushElement:newElement];
//            id tos = [self topOfStackElement];
//            if ([tos respondsToSelector:@selector(addConstant:)]) {
//                [newElement takeAttributes:attributeDict];
//                [tos performSelector:@selector(addConstant:) withObject:newElement];
//                [self pushElement:newElement];
//            }
//            else {
//                [self fatalStackPushError:@"constant"];
//            }
        }
        
        else if ([elementName isEqualToString:@"script"]) {
            newElement = [[[IDRDefScript alloc] init] autorelease];
            [newElement takeAttributes:attributeDict];
            [self pushElement:newElement];
//            id tos = [self topOfStackElement];
//            if ([tos respondsToSelector:@selector(addScript:)]) {
//                [newElement takeAttributes:attributeDict];
//                [tos performSelector:@selector(addScript:) withObject:newElement];
//                [self pushElement:newElement];
//            }
//            else {
//                [self fatalStackPushError:@"script"];
//            }
        }

        // -----------------------------------------------------------
        // subcomponents of data dic objects
        
        else if ([elementName isEqualToString:@"prompt"]) {
            newElement = [[[IDRPrompt alloc] init] autorelease];
            id tos = [self topOfStackElement]; 
            if ([tos respondsToSelector:@selector(addPrompt:)]) {
                [newElement takeAttributes:attributeDict];
                [tos performSelector:@selector(addPrompt:) withObject:newElement];
                [self pushElement:newElement];
            }
            else {
                [self fatalStackPushError:@"prompt"];
            }
        }
        
        else if ([elementName isEqualToString:@"select"]) {
            newElement = [[[IDRSelect alloc] init] autorelease];
            id tos = [self topOfStackElement];
            if ([tos respondsToSelector:@selector(addSelect:)]) {
                [newElement takeAttributes:attributeDict];
                [tos performSelector:@selector(addSelect:) withObject:newElement];
                [self pushElement:newElement];
            }
            else {
                [self fatalStackPushError:@"select"];
            }
        }
        
        else if ([elementName isEqualToString:@"parameter"]) {
            newElement = [[[IDRDefScriptParameter alloc] init] autorelease];
            id tos = [self topOfStackElement];
            if ([tos respondsToSelector:@selector(addParameter:)]) {
                [newElement takeAttributes:attributeDict];
                [tos performSelector:@selector(addParameter:) withObject:newElement];
                [self pushElement:newElement];
            }
            else {
                [self fatalStackPushError:@"parameter"];
            }
        }
        
        // -----------------------------------------------------------
        // directives
        
        else if ([elementName isEqualToString:@"import"]) {
        }
        
        // -----------------------------------------------------------
        // unknown elements handling
        
        else {
            [self fatalError:[NSString stringWithFormat:@"Unknown tag in document: %@", elementName] parser:self.parser];
        }
    }
    
    @catch (NSException *exc) {
        [self fatalError:[NSString stringWithFormat:@"%@, %@", exc.name, exc.reason] parser:self.parser];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    id popped = [self popElement];
    // data dictionary stuff should only be added once complete
    if ([popped isKindOfClass:[IDRObsDef class]])
        [[IotaContext getCurrentPatientContext].dataDictionary addObsDef:popped];
    else if ([popped isKindOfClass:[IDRDefConstant class]])
        [[IotaContext getCurrentPatientContext].dataDictionary addConstant:popped];
    else if ([popped isKindOfClass:[IDRDefScript class]])
        [[IotaContext getCurrentPatientContext].dataDictionary addScript:popped];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    id tos = [self topOfStackElement];
    if ([tos respondsToSelector:@selector(addCData:)]) {
        // the CDATABlock is always in UTF-8 encoding, according to docs
        NSString *cdata = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
        [tos performSelector:@selector(addCData:) withObject:cdata];
        [cdata release];
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Content handling
// -----------------------------------------------------------

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    id tos = [self topOfStackElement];
    if ([tos respondsToSelector:@selector(addContent:)]) {
//        NSLog(@"adding characters to %@: %@", [tos class], string);
        [tos performSelector:@selector(addContent:) withObject:string];
    }
}


@end
