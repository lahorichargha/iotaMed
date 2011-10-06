//
//  ItemTableCellCheck.m
//  iotaPad6
//
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

#import "ItemTableCellCheck.h"
#import "IDRObservation.h"
#import "IDRContact.h"
#import "IDRValue.h"
#import "IDRBlock.h"
#import "NSString+iotaAdditions.h"
#import "Notifications.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface  ItemTableCellCheck ()
- (void)displayValue;
@end


@implementation ItemTableCellCheck

@synthesize lblCheck = _lblCheck;

+ (void)load {
    [super addSubclass:self];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return [idrItem hasObservation] && [idrItem hasInput] && [idrItem.observation isCheck];
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    return [super subCellHeightForTableView:tableView idrItem:idrItem];
}

+ (CGFloat)gadgetSpaceAdd:(CGFloat)oldSpace forItem:(IDRItem *)idrItem {
    return [super gadgetSpaceAdd:(oldSpace + kCheckViewWidth + kInterGadgetSpace) forItem:idrItem];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    if ((self = [super initWithTableView:tableView idrItem:idrItem])) {
        self.lblCheck = (UILabel *)[self viewOfClass:[UILabel class] tag:TAG_CHECKVIEW];
        self.lblCheck.backgroundColor = [UIColor clearColor];
        self.lblCheck.userInteractionEnabled = YES;
        [self layoutSubviews];
        [self displayValue];
        
        UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCheck)] autorelease];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [self.lblCheck addGestureRecognizer:singleTap];
    }
    return self;
}

- (void)dealloc {
    self.lblCheck = nil;
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat rightMargin = [self cellWidth] - [[self superclass] gadgetSpaceAdd:kInterGadgetSpace forItem:self.idrItem];
    self.lblCheck.frame = CGRectMake(rightMargin - kCheckViewWidth, kInputOffsetFromTop, kCheckViewWidth, kInputHeight);
}

- (void)displayValue {
    IDRValue *val = [self.idrItem getItemValue];
    NSString *dValue = [val displayValue];
    if ([dValue iotaIsNonEmpty])
        self.lblCheck.text = dValue;
    else
        self.lblCheck.text = @"?";
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Touch stuff
// -----------------------------------------------------------

- (void)toggleCheck {
    NSString *value = [self.idrItem getItemValue].value;
    if ([value isEqualToString:@"yes"])
        value = @"no";
    else if ([value isEqualToString:@"no"])
        value = @"?";
    else
        value = @"yes";
    [self.idrItem setItemValue:value];
    [[NSNotificationCenter defaultCenter] postNotificationName:kObservationDataChangedNotification object:nil];
//    [self displayValue];
}

- (void)refreshDisplay {
    [self displayValue];
}


@end
