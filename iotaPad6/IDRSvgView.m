//
//  IDRSvgImage.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IDRSvgView.h"

@implementation IDRSvgView

static NSString *kImageNameKey = @"imageNameKey";

@synthesize imageName = _imageName;

- (void)dealloc {
    self.imageName = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.imageName = [aDecoder decodeObjectForKey:kImageNameKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.imageName forKey:kImageNameKey];
}

- (id)copyWithZone:(NSZone *)zone {
    IDRSvgView *copy = [[self class] allocWithZone:zone];
    copy.imageName = [[self.imageName copyWithZone:zone] autorelease];
    return copy;            // retain = +1 at return
}

- (SVGView *)svgView {
    return [SVGView viewWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.imageName ofType:@"svg"]];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    self.imageName = [attribs valueForKey:@"imagename"];
}


@end
