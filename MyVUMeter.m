//
//  MyVUMeter.m
//  Audio
//
//  Created by Shiva on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyVUMeter.h"




@implementation MyVUMeter

@synthesize volume = _volume;
@synthesize peakVolume = _peakVolume;

@synthesize color1,color2,color3,color4,color5,color6,color7,color8,color9,color10,color;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
  
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    
    CGContextSetLineWidth(ctx, 5.0);
    
   
	
	    
       
    color1 = [[UIColor alloc] initWithRed:0. green:1.0 blue:0.0 alpha:1.0];
   
    color2 = [[UIColor alloc] initWithRed:1. green:1. blue:0. alpha:1.];
    
    color3 = [[UIColor alloc] initWithRed:1. green:0. blue:0. alpha:1.];
  
    color4=[[UIColor alloc] initWithRed:0. green:0. blue:1. alpha:1.];
    
     color5=[[UIColor alloc] initWithRed:1. green:0. blue:1. alpha:1.];
    
    color6=[[UIColor alloc] initWithRed:0.8 green:0.9 blue:0.2 alpha:1.];
    
    color7=[[UIColor alloc]initWithRed:0 green:1. blue:1. alpha:1.];

    color8=[[UIColor alloc]initWithRed:0.5 green:0.5 blue:0.1 alpha:1.];
    
    color9=[[UIColor alloc]initWithRed:0 green:0.4 blue:0.1 alpha:1.];
    
    color10=[[UIColor alloc]initWithRed:0.3 green:0 blue:0.3 alpha:1.];
    
    
   
    
    
     NSArray *colorArray=[NSArray arrayWithObjects:color1,color2,color3,color4,color5,color6,color7,color8,color9,color10, nil];
    
  
          
    int i;
    CGFloat currentTop = 0.;
    
    
    
    for (i=0; i<10; i++)
    {
        
        
       CGFloat val = MIN(_volume, (0.1+(0.1*i)));
        
               
              
        CGRect rectV = CGRectMake((rect.size.width) * (currentTop), (rect.size.height) * (currentTop), (rect.size.width)* (val-currentTop), (rect.size.height));
        
        
        
        UIColor *colorSetting=[colorArray objectAtIndex:i];
        [colorSetting set];
        
        CGContextFillRect(ctx, rectV);
        
    if (_volume < (0.1+(0.1*i))) break;
        
        currentTop = val;
    }
    
       
                          
        
       CGContextStrokePath(ctx);
}


-(void)  dealloc {
    self.color=nil;
    self.color1=nil;
    self.color2=nil;
    self.color3=nil;
    self.color4=nil;
    self.color5=nil;
    self.color6=nil;
    self.color7=nil;
    self.color8=nil;
    self.color9=nil;
    self.color10=nil;
       
    [super dealloc];
    
}


@end
