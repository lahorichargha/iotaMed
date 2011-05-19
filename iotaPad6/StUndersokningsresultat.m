//
//  StUndersokningsresultat.m
//  iotaPad6
//
//  Created by Martin on 2011-03-23.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "StUndersokningsresultat.h"


@implementation StUndersokningsresultat

@synthesize atgardskodText = _atgardskodText;
@synthesize atgardstid = _atgardstid;
@synthesize varde = _varde;
@synthesize vardeEnhet = _vardeEnhet;
@synthesize patologiskmarkerad = _patologiskmarkerad;
@synthesize referensintervall = _referensintervall;

- (void)dealloc {
    self.atgardskodText = nil;
    self.atgardstid = nil;
    self.varde = nil;
    self.vardeEnhet = nil;
    self.referensintervall = nil;
    [super dealloc];
}



@end
