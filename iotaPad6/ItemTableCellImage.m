//
//  ItemTableCellImage.m
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

#import "ItemTableCellImage.h"
#import "IDRImage.h"

@implementation ItemTableCellImage

@synthesize itemImageView = _itemImageView;

+ (void)load {
    [super addSubclass:self];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return idrItem.idrImage != nil;
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    CGFloat height = [super subCellHeightForTableView:tableView idrItem:idrItem];
    CGFloat imageHeight = idrItem.idrImage.image.size.height + kImageTopMargin + kImageBottomMargin;
    return fmax(height, imageHeight);
}

+ (CGFloat)gadgetSpaceAdd:(CGFloat)oldSpace forItem:(IDRItem *)idrItem {
    CGFloat usedSpace = [super gadgetSpaceAdd:oldSpace forItem:idrItem];
    CGFloat mySpace = idrItem.idrImage.image.size.width + kImageXOffsetFromRight;
    return usedSpace + mySpace;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    if ((self = [super initWithTableView:tableView idrItem:idrItem])) {
        self.itemImageView = (UIImageView *)[self viewOfClass:[UIImageView class] tag:TAG_IMAGE];
        self.itemImageView.image = idrItem.idrImage.image;
        self.itemImageView.userInteractionEnabled = YES;

        // NEVER set the delegate on a recognizer! It's done automatically, and if you do it
        // manually, it stops working
        UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)] autorelease];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 1;
        [self.imageView addGestureRecognizer:doubleTap];
        
        UITapGestureRecognizer *twoFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerTap)] autorelease];
        twoFingerTap.numberOfTapsRequired = 1;
        twoFingerTap.numberOfTouchesRequired = 2;
        [self.itemImageView addGestureRecognizer:twoFingerTap];
        
        [self layoutSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.idrItem.idrImage.image != nil) {
        CGSize imageSize = self.idrItem.idrImage.image.size;
        CGRect rect = CGRectMake([self cellWidth] - kImageXOffsetFromRight - imageSize.width, kImageTopMargin, imageSize.width, imageSize.height);
        self.itemImageView.frame = rect;
    }
}

- (void)dealloc {
    self.itemImageView = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark User interaction
// -----------------------------------------------------------

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    NSLog(@"simultaneously");
    return YES;
}

- (void)doubleTap {
    NSLog(@"Double Tap");
}

- (void)twoFingerTap {
    NSLog(@"Two finger tap");
}

@end
