//
//  IDRMultiselect.h
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/23/11.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDRAttribs.h"

@interface IDRMultiselect : NSObject <IDRAttribs, NSCoding>

@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSMutableString *content;
@property (nonatomic, assign) BOOL selected;

@end
