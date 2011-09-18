//
//  IDRObsDefScript.h
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-09-17.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDRDef.h"

@interface IDRDefScript : IDRDef

@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSMutableString *script;
@property (nonatomic, retain) NSString *scriptType; // expression, statement
@property (nonatomic, retain) NSString *returnType;
@property (nonatomic, retain) NSMutableArray *parameters;


@end
