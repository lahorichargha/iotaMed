//
//  IotaDOMElement.m
//  iotaPad6
//
//  Created by Martin on 2011-03-23.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "IotaDOMElement.h"
#import "NSString+iotaAdditions.h"
#import "IotaDOMContent.h"

@implementation IotaDOMElement

@synthesize tagName = _tagName;
@synthesize attributes = _attributes;
@synthesize children = _children;

- (id)init {
    if ((self = [super init])) {
        _children = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

- (void)dealloc {
    self.tagName = nil;
    self.attributes = nil;
    self.children = nil;
    [super dealloc];
}

- (NSString *)content {
    NSMutableString *temp = [[[NSMutableString alloc] initWithCapacity:20] autorelease];
    for (IotaDOMNode *node in self.children) {
        if ([node isKindOfClass:[IotaDOMContent class]]) {
            [temp appendString:((IotaDOMContent *)node).content];
        }
    }
    return [[temp copy] autorelease];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Recursively search for element in a path
// -----------------------------------------------------------

// the path first object is the root end of the path,
// the last object the leaf end
// an asterix matches any element tag name

// there are these cases when it comes to processing the current path:
//  there is just one component and it is an '*'
//          add self and return success
//  there is just one component and it is the same name as self.tagName
//          add self and return success
//  there is more than one component, the first matches self.tagName
//          strip first component
//          process children
//  there is more than one component, the first is '*', the second matches self
//          strip first and second component
//          if any left, process children, else add self and return success
//  there is more than one component, the first is '*', the second does not match self
//          process children


// pseudocode:
//
//      if first component matches self.tagname or there is only one component and it is '*'
//          strip first component
//          if no more component
//              add self to results
//          else
//              process children
//      else if first component matches '*' and second component matches self.tagName
//          strip two components
//          if no more components
//              add self to results
//          else
//              process children
//      return

- (BOOL)matchAndStrip:(NSMutableArray *)path currentTag:(NSString *)tag{
    NSString *component0 = [path objectAtIndex:0];
    if ([component0 isEqualToString:tag] || ([component0 isEqualToString:@"*"] && [path count] == 1)) {
        [path removeObjectAtIndex:0];
        return YES;
    }
    if ([path count] > 1) {
        if ([component0 isEqualToString:@"*"]) {
            NSString *component1 = [path objectAtIndex:1];
            if ([component1 isEqualToString:tag]) {
                [path removeObjectAtIndex:0];
                [path removeObjectAtIndex:0];
            }
            return YES;
        }
    }
    return NO;
}

- (NSArray *)processChildrenOf:(IotaDOMElement *)element withPath:(NSMutableArray *)path {
    NSMutableArray *elements = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
    for (IotaDOMNode *node in element.children) {
        if ([node isKindOfClass:[IotaDOMElement class]]) {
            NSArray *resolvedElements = [((IotaDOMElement *)node) elementsInPath:path];
            [elements addObjectsFromArray:resolvedElements];
        }
    }
    return elements;
}

- (IotaDOMElement *)elementInPathString:(NSString *)pathString {
    NSArray *path = [pathString componentsSeparatedByString:@"/"];
    return [self elementInPath:path];
}

- (IotaDOMElement *)elementInPath:(NSArray *)path {
//    NSLog(@"elementInPath: %@, <%@>", self.tagName, [path componentsJoinedByString:@"/"]);
    NSMutableArray *mutablePath = [[path mutableCopy] autorelease];
    if ([self matchAndStrip:mutablePath currentTag:self.tagName]) {
        if ([mutablePath count] == 0) {
            return self;
        }
        else {
            for (IotaDOMNode *node in self.children) {
                if ([node isKindOfClass:[IotaDOMElement class]]) {
                    IotaDOMElement *element = (IotaDOMElement *)node;
                    IotaDOMElement *selected = [element elementInPath:mutablePath];
                    if (selected != nil)
                        return [[selected retain] autorelease];
                }
            }
        }
    }
    return nil;
}

- (NSArray *)elementsInPathString:(NSString *)pathString {
    NSArray *path = [pathString componentsSeparatedByString:@"/"];
    return [self elementsInPath:path];
}

- (NSArray *)elementsInPath:(NSArray *)path {
//    NSLog(@"elementsInPath: %@, <%@>", self.tagName, [path componentsJoinedByString:@"/"]);
    NSMutableArray *results = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
    NSMutableArray *mutablePath = [[path mutableCopy] autorelease];
    if ([self matchAndStrip:mutablePath currentTag:self.tagName]) {
        if ([mutablePath count] == 0) {
            [results addObject:self];
        }
        else {
            NSArray *foundElements = [self processChildrenOf:self withPath:mutablePath];
            [results addObjectsFromArray:foundElements];
        }
    }
    return [[results copy] autorelease];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug stuff
// -----------------------------------------------------------

- (void)dumpNodeWithIndent:(int)indent {
    NSLog(@"%@%@", [NSString spacesOfLength:indent], self.tagName);
    for (IotaDOMNode *childNode in self.children) {
        [childNode dumpNodeWithIndent:indent + 2];
    }
}

@end
