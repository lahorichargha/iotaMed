//
//  StUndersokningsresultat.h
//  iotaPad6
//
//  Created by Martin on 2011-03-23.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StBase.h"

@interface StUndersokningsresultat : StBase {
    
}

@property (nonatomic, retain) NSString *atgardskodText;
@property (nonatomic, retain) NSString *atgardstid;
@property (nonatomic, retain) NSString *varde;
@property (nonatomic, retain) NSString *vardeEnhet;
@property (nonatomic, assign) BOOL patologiskmarkerad;
@property (nonatomic, retain) NSString *referensintervall;

@end
