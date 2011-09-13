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

#import "ItemTableCellContent.h"
#import "BulletView.h"
#import "NSString+iotaAdditions.h"
#import "IotaContext.h"

@implementation ItemTableCellContent

@synthesize lblContent = _lblContent;
@synthesize bulletView = _bulletView;


// -----------------------------------------------------------
#pragma mark -
#pragma mark Override in subclasses
// -----------------------------------------------------------

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return ![idrItem hasObservation] && !idrItem.idrImage && !idrItem.idrSvgView;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Class 
// -----------------------------------------------------------

+ (void)load {
    [super addSubclass:self];
}

+ (ItemTableCellContent *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCellContent *cell = (ItemTableCellContent *)(idrItem.itemTableCell);
    if (cell == nil) {
        cell = [[[self alloc] initWithTableView:tableView idrItem:idrItem] autorelease];
    }
    return cell;
}

+ (CGFloat)leftMarginForIdrItem:(IDRItem *)idrItem {
    return idrItem.indentLevel * kIndentSize + kContentTextOffsetFromLeft;
}

- (CGFloat)leftMargin {
    return [[self class] leftMarginForIdrItem:self.idrItem];
}

+ (CGFloat)contentWidthForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    CGFloat leftMargin = [self leftMarginForIdrItem:idrItem];
    CGFloat rightMargin = [self cellWidthForTableView:tableView] - [self gadgetSpaceAdd:kInterGadgetSpace forItem:idrItem];
    return rightMargin - leftMargin;
}

- (CGFloat)contentWidth {
    return [[self class] contentWidthForTableView:self.parentTableView idrItem:self.idrItem];
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    CGFloat contentWidth = [self contentWidthForTableView:tableView idrItem:idrItem];
    CGFloat formWidth = tableView.frame.size.width;
    contentWidth = fminf(contentWidth, formWidth - kMinRightMargin);
    
    NSString *sContent = [idrItem.content iotaNormalize];
    CGSize size = [sContent sizeWithFont:[self contentFontBold:idrItem.isBold]
                       constrainedToSize:CGSizeMake(contentWidth, 1997.0) 
                           lineBreakMode:UILineBreakModeWordWrap];
    size.height += kContentTextOffsetFromTop;
    CGFloat minCellHeight = [IotaContext minRowHeight];
    return fmax(minCellHeight, size.height);
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Metrics
// -----------------------------------------------------------

+ (CGFloat)gadgetSpaceAdd:(CGFloat)oldSpace forItem:(IDRItem *)idrItem {
    return [super gadgetSpaceAdd:oldSpace forItem:idrItem];     // we don't use any gadget space
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------


- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    if ((self = [super initWithTableView:tableView idrItem:idrItem])) {
        self.lblContent = (UILabel *)[self viewOfClass:[UILabel class] tag:TAG_LBLCONTENT];
        self.lblContent.userInteractionEnabled = YES;
        self.lblContent.backgroundColor = [UIColor clearColor];
        self.lblContent.text = [idrItem.content iotaNormalize];
        self.lblContent.font = [[self class] contentFontBold:idrItem.isBold];
        self.lblContent.numberOfLines = 0;
        self.lblContent.lineBreakMode = UILineBreakModeWordWrap;

        if ([idrItem hasAction])
            self.lblContent.textColor = [UIColor blueColor];
        // TODO: check why there is no bullet displayed
        if ([idrItem hasBullet]) {
            self.bulletView = (BulletView *)[self viewOfClass:[BulletView class] tag:TAG_BULLET];
        }
        [self layoutSubviews];
    }
    return self;
}

- (void)dealloc {
    self.lblContent = nil;
    self.bulletView = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Layout
// -----------------------------------------------------------

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat leftMargin =  [self leftMargin];
    CGFloat contentWidth = [self contentWidth];
    self.lblContent.frame = CGRectMake(leftMargin, kContentTextOffsetFromTop, contentWidth, 20);
    [self.lblContent sizeToFit];
}

@end
