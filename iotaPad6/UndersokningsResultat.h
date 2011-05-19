//
//  UndersokningsResultat.h
//  iotaPad6
//
//  Created by Martin on 2011-03-24.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UndersokningsResultat : NSObject {
    
}

@property (nonatomic, retain) NSDate *registreringstidpunkt;
@property (nonatomic, retain) NSDate *svarsstidpunkt;   // sic!
@property (nonatomic, retain) NSString *svarstyp;
@property (nonatomic, retain) NSMutableArray *analysTjanster;

- (id)init;

@end
