//
//  IotaDOMElement.h
//  iotaPad6
//
//  Created by Martin on 2011-03-23.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IotaDOMNode.h"

@interface IotaDOMElement : IotaDOMNode {
    
}

@property (nonatomic, retain) NSString *tagName;
@property (nonatomic, retain) NSMutableDictionary *attributes;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, readonly) NSString *content;

// get the first element satisfying the path
- (IotaDOMElement *)elementInPathString:(NSString *)pathString;
- (IotaDOMElement *)elementInPath:(NSArray *)path;

// get every element satisfying the path
- (NSArray *)elementsInPathString:(NSString *)pathString;
- (NSArray *)elementsInPath:(NSArray *)path;

@end
