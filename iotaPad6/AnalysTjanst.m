//
//  AnalysTjanst.m
//  iotaPad6
//
//  Created by Martin on 2011-03-24.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "AnalysTjanst.h"


@implementation AnalysTjanst

@synthesize atgardskodText = _atgardskodText;
@synthesize varde = _varde;
@synthesize vardeEnhet = _vardeEnhet;
@synthesize patologiskmarkerad = _patologiskmarkerad;
@synthesize referensintervall = _referensintervall;

- (void)dealloc {
    self.atgardskodText = nil;
    self.varde = nil;
    self.vardeEnhet = nil;
    self.referensintervall = nil;
    [super dealloc];
}


@end
