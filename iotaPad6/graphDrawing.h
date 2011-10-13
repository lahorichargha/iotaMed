//
//  graphDrawing.h
//  iotaPad6
//
//  Created by Shiva on 10/4/11.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IDRItem.h"

@interface graphDrawing : UIView{
    
}

@property (nonatomic,retain) NSArray *value;
@property (nonatomic,retain) NSDate *date;
@property (nonatomic,readwrite) CGFloat minVal;
@property (nonatomic,readwrite) CGFloat maxVal;
@property (nonatomic,readwrite) CGFloat normalUp;
@property (nonatomic,readwrite) CGFloat normalDown;

@end
