//
//  IDRSvgImage.h
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDRAttribs.h"
#import "SVGView.h"

@interface IDRSvgView : NSObject <IDRAttribs, NSCoding, NSCopying> {
    
}

@property (nonatomic, retain) NSString *imageName;

- (SVGView *)svgView;

@end
