//
//  graphDrawing.m
//  iotaPad6
//
//  Created by Shiva on 10/4/11.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "graphDrawing.h"
#import "IDRObservation.h"
#import "IDRItem.h"
#import "IDRValue.h"

#define kMargin 70.0
#define kMinDiff        0.5
#define kTickLines     2.0
#define kTickWidth      4.0

@implementation graphDrawing

@synthesize value=_value;
@synthesize date=_date;
@synthesize minVal=_minVal;
@synthesize maxVal=_maxVal;
@synthesize normalUp=_normalUp;
@synthesize normalDown=_normalDown;


-(void)findMinMax{
    int i;
    int j=[self.value count];
    IDRValue *valM=[self.value objectAtIndex:0];
    NSString *sM=valM.value;
    CGFloat fM=[sM floatValue];
    self.minVal=fM;
    self.maxVal=fM;
    
    for (i=0; i<j; i++) {
        
        IDRValue *vali=[self.value objectAtIndex:i];
        NSString *si=vali.value;
        CGFloat fi=[si floatValue];
        if (fi<self.minVal) {
            self.minVal=fi;
        }
        if (fi>self.maxVal) {
            self.maxVal=fi;
        }        
        
    }    
    
    
}

-(id)init{
    if ((self = [super init])) {
        [self findMinMax];
    }           
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
    
        [self findMinMax]; 
    }
    return self;
}


-(void)drawRect:(CGRect)rect{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.95, 1.0);
    
    CGContextFillRect(ctx, rect);
    CGContextTranslateCTM(ctx, 0, (rect.size.height));
    
    int i;
    int j=[self.value count];
    
    NSLog(@"j %i", j);
    IDRValue *valM=[self.value objectAtIndex:0];
    NSString *sM=valM.value;
    CGFloat fM=[sM floatValue];
    self.minVal=fM;
    self.maxVal=fM;
    
    for (i=0; i<j; i++) {
        
        IDRValue *vali=[self.value objectAtIndex:i];
        NSString *si=vali.value;
        CGFloat fi=[si floatValue];
        if (fi<self.minVal) {
            self.minVal=fi;
        }
        if (fi>self.maxVal) {
            self.maxVal=fi;
        }        
    }    
    NSLog(@"max %f", self.maxVal);
    NSLog(@"min %f", self.minVal);

               
    if (j>1){
        
        if (self.minVal==0) {
            j=j-1;
            IDRValue *valM=[self.value objectAtIndex:0];
            NSString *sM=valM.value;
            CGFloat fM=[sM floatValue];
            self.minVal=fM;
            self.maxVal=fM;
            for (i=0; i<j; i++) {
                
                IDRValue *vali=[self.value objectAtIndex:i];
                NSString *si=vali.value;
                CGFloat fi=[si floatValue];
                if (fi<self.minVal) {
                    self.minVal=fi;
                }
                if (fi>self.maxVal) {
                    self.maxVal=fi;
                }        
            }    
            NSLog(@"max %f", self.maxVal);
            NSLog(@"min %f", self.minVal);
        }

        
        self.normalDown=14;
        self.normalUp=20;
        
        CGFloat x= kMargin;
        CGFloat y= kMargin;
        
        CGFloat xAxis  =(rect.size.width)-(2*kMargin);
        CGFloat yAxis = (rect.size.height)-(2*kMargin);
        CGFloat xStep = xAxis / (j);
        CGFloat yStep = yAxis / (self.maxVal-self.minVal);
        
        CGRect rec= CGRectMake(x, -((y+(self.normalDown-self.minVal)*yStep)),xAxis , -(((self.normalUp-self.normalDown)*yStep)));
        CGContextSetRGBFillColor(ctx, 0.5, 0, 0, 0.5);
        CGContextFillRect(ctx, rec);
        CGContextStrokePath(ctx);
        
        
        for (i=0; i < j-1; i++) {
            IDRValue *kidr=[self.value objectAtIndex:i];
            NSString *k=kidr.value;
            CGFloat fi=[k floatValue];
            NSLog(@"k %f", fi);
            NSString *iStr = [NSString stringWithFormat:@"%f",fi ];
            NSLog(@"str %@",iStr);
            // CGContextShowTextAtPoint(ctx, 40, -40, [iStr UTF8String], [iStr length]);  
            CGContextSelectFont(ctx, "Arial", 14, kCGEncodingMacRoman);
            CGContextSetRGBFillColor (ctx, 0, 0, 0, 1.0);
            CGContextSetTextMatrix(ctx, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0));
            CGContextShowTextAtPoint (ctx, x-(0.4*kMargin), -y-((fi-self.minVal)*(yStep))+2, [iStr UTF8String], 2);
        }
        
        NSString *norUp = [NSString stringWithFormat:@"%f",_normalUp ];
        NSLog(@"norUP %@",norUp);
        // CGContextShowTextAtPoint(ctx, 40, -40, [iStr UTF8String], [iStr length]);  
        CGContextSelectFont(ctx, "Arial", 8, kCGEncodingMacRoman);
        CGContextSetRGBFillColor (ctx, 0, 0, 0, 1.0);
        CGContextSetTextMatrix(ctx, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0));
        CGContextShowTextAtPoint (ctx, xAxis+(kMargin)+2, -((y+(self.normalUp-self.minVal)*yStep))+3, [norUp UTF8String], 2);
        CGContextShowTextAtPoint (ctx, xAxis+(kMargin)+11, -((y+(self.normalUp-self.minVal)*yStep))+3, " - NormalUpp", 12);
        
        NSString *norDown = [NSString stringWithFormat:@"%f",_normalDown ];
        NSLog(@"norDown %@",norDown);
        CGContextShowTextAtPoint (ctx, xAxis+(kMargin)+2, -((y+(self.normalDown-self.minVal)*yStep))+3, [norDown UTF8String], 2);
        CGContextShowTextAtPoint (ctx, xAxis+(kMargin)+11, -((y+(self.normalDown-self.minVal)*yStep))+3, " - NormalDown", 13);
        
        
        CGContextSetLineWidth(ctx, kTickLines);
        
        
        for (i=1; i < j; i++) {
            IDRValue *vali=[self.value objectAtIndex:i];
            NSString *si=vali.value;
            CGFloat fi=[si floatValue];
            
            CGContextSetRGBStrokeColor(ctx, 0.7, 0.7, 0.7, 1.0);
            CGContextMoveToPoint(ctx, x, -y-((fi-self.minVal)*(yStep)));
            CGContextAddLineToPoint(ctx, x+(j*xStep),-y-((fi-self.minVal)*(yStep)));
            
            CGContextMoveToPoint(ctx, x+((i)*(xStep)),  -y);
            CGContextAddLineToPoint(ctx, x+((i)*(xStep)), -y-((self.maxVal-self.minVal)*(yStep)));
            CGContextStrokePath(ctx);}
        
        CGContextMoveToPoint(ctx, x+(j*xStep), -y);
        CGContextAddLineToPoint(ctx, x+(j*xStep), -y-((self.maxVal-self.minVal)*(yStep)));
        CGContextStrokePath(ctx);
        
        CGContextSetLineWidth(ctx, kTickWidth);
        
        for (i=0; i < j-1; i++) {
            
            IDRValue *vali=[self.value objectAtIndex:i];
            NSString *si=vali.value;
            
            NSLog(@"si %@",si);
            CGFloat fi=[si floatValue];
            IDRValue *vali1=[self.value objectAtIndex:i+1];
            NSString *si1=vali1.value;
            CGFloat fi1=[si1 floatValue];
            CGContextSetRGBStrokeColor(ctx, 0.6, 0.85, 0.6, 1.0);
            CGContextMoveToPoint(ctx, x+((i+1)*(xStep)), -y-((fi-self.minVal)*(yStep)));
            CGContextAddLineToPoint(ctx, x+((i+2)*(xStep)), -y-((fi1-self.minVal)*(yStep)));
            CGContextStrokePath(ctx);
        }
        
        CGContextSetLineWidth(ctx, kTickLines);
        CGContextSetRGBStrokeColor(ctx, 0.7, 0.7, 0.7, 1.0);
        CGContextMoveToPoint(ctx, x, -y);
        CGContextAddLineToPoint(ctx, x+(j*xStep), -y);
        CGContextMoveToPoint(ctx, x, -y);
        CGContextAddLineToPoint(ctx, x, -y-((self.maxVal-self.minVal)*(yStep)));
        CGContextStrokePath(ctx);
        
               
        //    CGContextMoveToPoint(ctx, x, -y);
        //    CGContextAddLineToPoint(ctx, (rect.size.width)-(kMargin), -y);
        //    CGContextMoveToPoint(ctx, x, -y);
        //    CGContextAddLineToPoint(ctx, x, -((rect.size.height)-(kMargin)-self.minVal));
        //    CGContextStrokePath(ctx);
       
            
    }
    
}

-(void) dealloc{
    self.value=nil;
    self.date=nil;
    [super dealloc];
}

@end
