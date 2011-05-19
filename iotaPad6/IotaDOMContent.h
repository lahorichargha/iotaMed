//
//  IotaDOMContent.h
//  iotaPad6
//
//  Created by Martin on 2011-03-23.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IotaDOMNode.h"

@interface IotaDOMContent : IotaDOMNode {
    
}

@property (nonatomic, retain) NSMutableString *content;

- (void)dumpNodeWithIndent:(int)indent;

@end
