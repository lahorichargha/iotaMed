//
//  Xml2IotaDom.m
//  iotaPad6
//
//  Created by Martin on 2011-03-23.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "Xml2IotaDom.h"
#import "IotaDOMElement.h"
#import "IotaDOMContent.h"


// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface Xml2IotaDom ()
@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) NSMutableArray *elementStack;
@property (nonatomic, retain) NSMutableString *charBuffer;


@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation Xml2IotaDom

@synthesize parser = _parser;
@synthesize elementStack = _elementStack;
@synthesize charBuffer = _charBuffer;

- (void)setupLocalProperties {
    _elementStack = [[NSMutableArray alloc] initWithCapacity:10];
    _charBuffer = [[NSMutableString alloc] initWithCapacity:20];
}

- (id)initWithData:(NSData *)data {
    if ((self = [super init])) {
        [self setupLocalProperties];
        _parser = [[NSXMLParser alloc] initWithData:data];
        _parser.delegate = self;
    }
    return self;
}

- (id)initWithString:(NSString *)xml {
    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
    return [self initWithData:data];
}

- (id)initWithFile:(NSString *)fileName {
    if ((self = [super init])) {
        [self setupLocalProperties];
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"]];
        _parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        _parser.delegate = self;
    }
    return self;
}

- (void)dealloc {
    self.parser = nil;
    self.elementStack = nil;
    self.charBuffer = nil;
    [super dealloc];
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

- (void)pushElement:(id)element {
    [self.elementStack addObject:element];
}

- (id)popElement {
    if ([self.elementStack count] < 1) 
        [self fatalError:@"Element stack underflow"];
    id lastObject = [[self.elementStack lastObject] retain];
    [self.elementStack removeLastObject];
    return [lastObject autorelease];
}

- (id)topOfStackElement {
    if ([self.elementStack count] < 1) 
        [self fatalError:@"Stack unexpectedly empty"];
    return [[[self.elementStack lastObject] retain] autorelease];
}

- (IotaDOMElement *)document {
    return [[[self.elementStack objectAtIndex:0] retain] autorelease];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Exec
// -----------------------------------------------------------

- (void)parse {
    IotaDOMElement *document = [[IotaDOMElement alloc] init];
    document.tagName = @"root";
    [self pushElement:document];
    [self.parser parse];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Parser delegate
// -----------------------------------------------------------

- (void)addContentTo:(IotaDOMElement *)element {
    if ([self.charBuffer length] > 0) {
        IotaDOMContent *domContent = [[IotaDOMContent alloc] init];
        domContent.content = [self.charBuffer copy];
        [self.charBuffer setString:@""];
        [element.children addObject:domContent];
        [domContent release];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    IotaDOMElement *element = [[IotaDOMElement alloc] init];
    element.tagName = elementName;
    IotaDOMElement *tos = [self topOfStackElement];
    [self addContentTo:tos];
    [[tos children] addObject:element];
    [self pushElement:element];
    [element release];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    [self addContentTo:[self topOfStackElement]];
    [self popElement];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.charBuffer appendString:string];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug stuff
// -----------------------------------------------------------



@end
