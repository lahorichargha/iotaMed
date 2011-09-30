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
@synthesize colorArray=_colorArray;


@synthesize color1,color2,color3,color4,color5,color6,color7,color8,color9,color10,color;


- (void)setupArray {
    self.color1 = [[[UIColor alloc] initWithRed:0.6 green:0.6 blue:0.7 alpha:1.0]autorelease];
    self.color2 = [[[UIColor alloc] initWithRed:0.55 green:0.55 blue:0.65 alpha:1.]autorelease];
    self.color3 = [[[UIColor alloc] initWithRed:0.5 green:0.5 blue:0.6 alpha:1.]autorelease];
    self.color4= [[[UIColor alloc] initWithRed:0.45 green:0.45 blue:0.55 alpha:1.]autorelease];
    self.color5= [[[UIColor alloc] initWithRed:0.4 green:0.4 blue:.5 alpha:1.]autorelease];
    self.color6= [[[UIColor alloc] initWithRed:0.35 green:0.35 blue:0.45 alpha:1.]autorelease];
    self.color7= [[[UIColor alloc]initWithRed:0.3 green:.3 blue:0.4 alpha:1.]autorelease];
    self.color8= [[[UIColor alloc]initWithRed:0.2 green:0.2 blue:0.3 alpha:1.]autorelease];
    self.color9= [[[UIColor alloc]initWithRed:0.1 green:0.1 blue:0.3 alpha:1.]autorelease];
    self.color10=[[[UIColor alloc]initWithRed:0. green:0 blue:0.1 alpha:1.]autorelease];
    self.colorArray =[NSArray arrayWithObjects:self.color1, self.color2,self.color3, self.color4,self.color5,self.color6,self.color7,self.color8, self.color9,self.color10, nil];
}

-(id)init{
    if ((self = [super init])) {
        [self setupArray];
    }           
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupArray];
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect{
    
    
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0.45, 0.45, 0.45, 1.);
    
    CGContextFillRect(ctx, rect);
    CGContextSetLineWidth(ctx, 5.0);
    
    //    
    //    
    //    
    //    CGRect volRect = CGRectMake(0, 0, self.volume * 100.0, 20);
    //    CGContextSetFillColorWithColor(ctx, [[UIColor redColor] CGColor]);
    //    CGContextSetStrokeColorWithColor(ctx, [[UIColor blueColor] CGColor]);
    //    CGContextFillRect(ctx, volRect);
    //    CGContextStrokePath(ctx);
    //    NSLog(@"drawRect in MyVUMeter: %@", NSStringFromCGRect(volRect));
    //    return;
    
	
    
    
    //    [self init];
    
    int i;
    CGFloat currentTop = 0.;
    
    
    
    for (i=0; i<10; i++) {
        CGFloat val = MIN(_volume, (0.1+(0.1*i)));
        CGRect rectV = CGRectMake((rect.size.width) * (currentTop), (rect.size.height)*(currentTop), (rect.size.width)* (val-currentTop), (rect.size.height));
        UIColor *colorSetting=[self.colorArray objectAtIndex:i];
        [colorSetting set];
        CGContextFillRect(ctx, rectV);
        
        if (_volume < (0.1+(0.1*i))) break;
        
        currentTop = val;
    }
    CGContextStrokePath(ctx);
}


- (void)dealloc {
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
    self.colorArray=nil;
    [super dealloc];
}


@end
