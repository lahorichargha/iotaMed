//
//  Xml2IotaDom.h
//  iotaPad6
//
//  Created by Martin on 2011-03-23.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IotaDOMElement;

@interface Xml2IotaDom : NSObject <NSXMLParserDelegate> {
    
}

- (id)initWithData:(NSData *)data;
- (id)initWithString:(NSString *)xml;
- (id)initWithFile:(NSString *)fileName;
- (void)parse;
- (IotaDOMElement *)document;

@end
