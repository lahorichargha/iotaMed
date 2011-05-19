//
//  AnalysTjanst.h
//  iotaPad6
//
//  Created by Martin on 2011-03-24.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnalysTjanst : NSObject {
    
}

@property (nonatomic, retain) NSString *atgardskodText;
@property (nonatomic, retain) NSString *varde;
@property (nonatomic, retain) NSString *vardeEnhet;
@property (nonatomic, assign) BOOL patologiskmarkerad;
@property (nonatomic, retain) NSString *referensintervall;

@end
