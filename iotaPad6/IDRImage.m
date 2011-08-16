//
//  IDRImage.m
//  iotaPad6
//
//  Created by Martin on 2011-03-29.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "IDRImage.h"
#import "SVGView.h"

@implementation IDRImage

static NSString *kImageNameKey = @"imageNameKey";


@synthesize imageName = _imageName;
@synthesize imageType = _imageType;

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
    IDRImage *copy = [[self class] allocWithZone:zone];
    copy.imageName = [[self.imageName copyWithZone:zone] autorelease];
    return copy;
}

- (SVGView *)view {
    if ([self.imageType isEqualToString:@"svg"]) {
        return [SVGView viewWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.imageName ofType:@"svg"]];
    }
    else
        return nil;
}

- (UIImage *)image {
    if ([self.imageType isEqualToString:@"svg"]) {
        return nil;
    }
    else {
        return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.imageName ofType:@"png"]];
    }
}

- (void)takeAttributes:(NSDictionary *)attribs {
    self.imageName = [attribs valueForKey:@"imagename"];
    self.imageType = [attribs valueForKey:@"imagetype"];
}

@end
