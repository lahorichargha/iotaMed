//
//  UndersokningsResultat.m
//  iotaPad6
//
//  Created by Martin on 2011-03-24.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "UndersokningsResultat.h"


@implementation UndersokningsResultat

@synthesize registreringstidpunkt = _registreringstidpunkt;
@synthesize svarsstidpunkt = _svarstidpunkt;
@synthesize svarstyp = _svarstyp;
@synthesize analysTjanster = _analysTjanster;

- (id)init {
    if ((self = [super init])) {
        self.analysTjanster = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    }
    return self;
}

- (void)dealloc {
    self.registreringstidpunkt = nil;
    self.svarsstidpunkt = nil;
    self.svarstyp = nil;
    self.analysTjanster = nil;
    [super dealloc];
}

@end
