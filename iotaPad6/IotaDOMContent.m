//
//  IotaDOMContent.m
//  iotaPad6
//
//  Created by Martin on 2011-03-23.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "IotaDOMContent.h"
#import "NSString+iotaAdditions.h"

@implementation IotaDOMContent

@synthesize content = _content;

- (void)dealloc {
    self.content = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug stuff
// -----------------------------------------------------------

- (void)dumpNodeWithIndent:(int)indent {
    NSLog(@"%@<%@>", [NSString spacesOfLength:indent], self.content);
}

@end
