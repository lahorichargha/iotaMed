//
//  ItemTableCellHistory.m
//  iotaPad6

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

#import "ItemTableCellHistory.h"
#import "ThemeColors.h"
#import "IDRValue.h"
#import "IDRContact.h"
#import "Funcs.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface ItemTableCellHistory()
@end


@implementation ItemTableCellHistory

@synthesize lblValue = _lblValue;
@synthesize lblDate = _lblDate;

+ (void)load {
    [self addSubclass:self];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return [idrItem hasGet] && ![idrItem hasInput];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    if ((self = [super initWithTableView:tableView idrItem:idrItem])) {
        self.lblValue = (UILabel *)[self viewOfClass:[UILabel class] tag:TAG_LBLVALUE];
        self.lblValue.backgroundColor = [[ThemeColors themeColors] valueBackground];
        self.lblValue.userInteractionEnabled = YES;
        
        self.lblDate = (UILabel *)[self viewOfClass:[UILabel class] tag:TAG_LBLDATE];
        self.lblDate.backgroundColor = [[ThemeColors themeColors] dateBackground];
        self.lblDate.userInteractionEnabled = YES;
        
        [self refreshHistory];
        [self layoutSubviews];
        
        UITapGestureRecognizer *singleTapValue = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHistory)] autorelease];
        singleTapValue.numberOfTapsRequired = 1;
        singleTapValue.numberOfTouchesRequired = 1;
        [self.lblValue addGestureRecognizer:singleTapValue];

        UITapGestureRecognizer *singleTapDate = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHistory)] autorelease];
        singleTapDate.numberOfTapsRequired = 1;
        singleTapDate.numberOfTouchesRequired = 1;
        [self.lblDate addGestureRecognizer:singleTapDate];

    }
    return self;
}

- (void)showHistory {
    [self.itemCellDelegate presentValueLookupForm:self.idrItem];
}

- (void)refreshDisplay {
    [self refreshHistory];
}

- (void)refreshHistory {
    IDRValue *value;
    if ([self.idrItem hasInput])
        value = [self.idrItem getHistoricValue];
    else
        value = [self.idrItem getLatestValue];
    self.lblValue.text = value.displayValue;
    self.lblDate.text = dateshort2str(value.contact.date);
}

- (void)dealloc {
    self.lblValue = nil;
    self.lblDate = nil;
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat currentWidth = self.frame.size.width;
    self.lblValue.frame = CGRectMake(currentWidth - kValueOffsetFromRight, kValueOffsetFromTop, kValueWidth, kValueHeight);
    self.lblDate.frame = CGRectMake(currentWidth - kDateOffsetFromRight, kDateOffsetFromTop, kDateWidth, kDateHeight);
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Metrics
// -----------------------------------------------------------

+ (CGFloat)gadgetSpaceAdd:(CGFloat)oldSpace forItem:(IDRItem *)idrItem {
    CGFloat ourGadgetSpace = kValueWidth + kDateWidth + 2 * kInterGadgetSpace;
    return [super gadgetSpaceAdd:(oldSpace + ourGadgetSpace) forItem:idrItem];
}

@end
