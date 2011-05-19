//
//  GraphView.m
//  iotaPad6
//
//  Created by Martin on 2011-03-17.
//  Copyright © 2011, MITM AB, Sweden
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1.  Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//  2.  Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//  3.  Neither the name of MITM AB nor the name iotaMed®, nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY MITM AB ‘’AS IS’’ AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MITM AB BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "GraphView.h"
#import "DemoData.h"

#define kMargin         60.0
#define kMinDiff        0.5
#define kTickLength     5.0
#define kTickWidth      2.0

@implementation GraphView

@synthesize dates = _dates;
@synthesize values = _values;
@synthesize unit = _unit; 
@synthesize axisValue = _axisValue;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (CGFloat)convertY:(CGFloat)y inRect:(CGRect)rect {
    CGFloat yAxis = rect.size.height - 2 * kMargin;
    CGFloat yScaleFactor = yAxis / (self.axisValue.maxValue - self.axisValue.minValue);
    CGFloat yScaled = (y - self.axisValue.minValue) * yScaleFactor;
    CGFloat yAbs = rect.size.height - kMargin - yScaled;
    return yAbs;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
//    NSLog(@"%@", NSStringFromCGRect(self.frame));
    if ([self.dates count] < 2 || [self.values count] < 2)
        return;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGFloat xAxis = rect.size.width - 2 * kMargin;
    CGFloat yAxis = rect.size.height - 2 * kMargin;
    CGFloat xStep = xAxis / ([self.dates count] - 1);

    // do the tick marks
    CGContextSetLineWidth(ctx, kTickWidth);
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    for (CGFloat y = self.axisValue.minValue; y <= self.axisValue.maxValue; y += self.axisValue.stepValue) {
        NSString *yAsString = [NSString stringWithFormat:@"%f", y];
        CGFloat yAbs = [self convertY:y inRect:rect];
        [yAsString drawInRect:CGRectMake(0.0, yAbs, 50.0, 22.0) withFont:[UIFont systemFontOfSize:18.0]];
        CGContextMoveToPoint(ctx, kMargin, yAbs);
        CGContextAddLineToPoint(ctx, kMargin + kTickLength, yAbs);
        CGContextStrokePath(ctx);
    }
    
    CGContextSetLineWidth(ctx, 4.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);

    
    CGFloat yValue;
    CGFloat cYValue;
    yValue = [[self.values objectAtIndex:0] floatValue];
    cYValue = [self convertY:yValue inRect:rect];
    CGContextMoveToPoint(ctx, kMargin, cYValue);
    
    for (int i = 1; i < [self.values count]; i++) {
        yValue = [[self.values objectAtIndex:i] floatValue];
        cYValue = [self convertY:yValue inRect:rect];
        CGContextAddLineToPoint(ctx, kMargin + i * xStep, cYValue);
    }
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    
    CGContextMoveToPoint(ctx, kMargin, kMargin + yAxis);
    CGContextAddLineToPoint(ctx, kMargin, kMargin);
    CGContextStrokePath(ctx);
    
    CGContextMoveToPoint(ctx, kMargin, kMargin + yAxis);
    CGContextAddLineToPoint(ctx, kMargin + xAxis, kMargin + yAxis);
    CGContextStrokePath(ctx);
}


- (void)dealloc {
    self.dates = nil;
    self.values = nil;
    self.unit = nil;
    self.axisValue = nil;
    [super dealloc];
}

@end
