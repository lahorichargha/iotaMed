//
//  StBase.m
//  iotaPad6
//
//  Created by Martin on 2011-03-23.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "StBase.h"


@implementation StBase

@synthesize elementName = _elementName;

- (void)dealloc {
    self.elementName = nil;
    [super dealloc];
}

@end
