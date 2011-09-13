//
//  ItemTableCellImage.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

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

+ (ItemTableCellImage *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCellImage *cell = (ItemTableCellImage *)idrItem.itemTableCell;
    if (cell == nil) {
        cell = [[[self alloc] initWithTableView:tableView idrItem:idrItem] autorelease];
    }
    return cell;
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
