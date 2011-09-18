//
//  IDRObsDefVariable.h
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-09-17.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDRDef.h"

@interface IDRObsDef : IDRDef

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *dimension;
@property (nonatomic, retain) NSString *format;
@property (nonatomic, retain) NSString *defaultPrompt;
@property (nonatomic, retain) NSMutableArray *prompts;
@property (nonatomic, retain) NSMutableArray *selects;

@end
