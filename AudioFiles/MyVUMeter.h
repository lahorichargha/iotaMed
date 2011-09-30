//
//  MyVUMeter.h
//  Audio
//
//  Created by Shiva on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyVUMeter : UIView {
}

@property (assign) CGFloat volume; // value 0-1
@property (assign) CGFloat peakVolume;

@property (retain) UIColor *color1,*color2,*color3,*color4,*color5,*color6,*color7,*color8,*color9,*color10,*color;

@property (nonatomic,retain) NSArray *colorArray;



@end
