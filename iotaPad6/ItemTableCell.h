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

#import <UIKit/UIKit.h>
#import "ItemCellDelegate.h"
#import "IDRItem.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Cell metrics
// -----------------------------------------------------------


static float kValueOffsetFromTop            __attribute__ ((unused)) = 1.0;
static float kValueOffsetFromRight          __attribute__ ((unused)) = 200.0;
static float kValueWidth                    __attribute__ ((unused)) = 90.0;
static float kValueHeight                   __attribute__ ((unused)) = 20.0;

static float kDateOffsetFromTop             __attribute__ ((unused)) = 1.0;
static float kDateOffsetFromRight           __attribute__ ((unused)) = 100.0;
static float kDateWidth                     __attribute__ ((unused)) = 95.0;
static float kDateHeight                    __attribute__ ((unused)) = 20.0;

static float kInputOffsetFromTop            __attribute__ ((unused)) = 1.0;
static float kInputOffsetRightEndFromRight  __attribute__ ((unused)) = 210; 
static float kInputWidthWide                __attribute__ ((unused)) = 200.0;
static float kInputWidthNarrow              __attribute__ ((unused)) = 150.0;
static float kInputHeight                   __attribute__ ((unused)) = 26.0;

static float kIndentSize                    __attribute__ ((unused)) = 20.0;

static float kContentTextOffsetFromLeft     __attribute__ ((unused)) = 10.0;
static float kContentTextOffsetFromTop      __attribute__ ((unused)) = 3.0;

// indicate the right margin for the content text in different situation
// the width depends on right margin *and* indent
static float kNarrowRight                   __attribute__ ((unused)) = 200.0;
static float kMediumNarrowRight             __attribute__ ((unused)) = 300.0;
static float kMediumWideRight               __attribute__ ((unused)) = 400.0;
static float kWideRight                     __attribute__ ((unused)) = 600.0;

// images

static float kImageXOffsetFromRight         __attribute__ ((unused)) = 40.0;
static float kImageTopMargin                __attribute__ ((unused)) = 8.0;
static float kImageBottomMargin             __attribute__ ((unused)) = 8.0;

static float kMinRightMargin                __attribute__ ((unused)) = 5.0;

// check view
static float kCheckViewWidth                __attribute__ ((unused)) = 50.0;






#define TAG_LBLCONTENT  1001
#define TAG_TEXTFIELD   1002
#define TAG_LBLVALUE    1003
#define TAG_LBLDATE     1004
#define TAG_IMAGE       1005
#define TAG_BULLET      1006
#define TAG_CHECKVIEW   1007

@interface ItemTableCell : UITableViewCell

@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) IDRItem *idrItem; // IDRItem owns this ItemTableCell
@property (nonatomic, retain) id <ItemCellDelegate> itemCellDelegate;
@property (nonatomic, assign) UITableView *parentTableView;

+ (ItemTableCell *)cellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem;
+ (CGFloat)cellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem;

+ (void)addSubclass:(Class)cls;
+ (BOOL)canHandle:(IDRItem *)idrItem;

+ (UIFont *)contentFontBold:(BOOL)bold;

- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem;
- (UIView *)viewOfClass:(Class)cls tag:(NSUInteger)tag;

@end
