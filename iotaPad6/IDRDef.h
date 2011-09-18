//
//  IDRObsDef.h
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-09-17.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDRAttribs.h"

@interface IDRDef : NSObject <IDRAttribs, NSCoding>

@property (nonatomic, retain) NSString *name;

@end
