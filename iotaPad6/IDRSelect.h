//
//  IDRSelect.h
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/18/11.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDRAttribs.h"

@interface IDRSelect : NSObject <IDRAttribs, NSCoding>

@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSMutableString *content;

@end
