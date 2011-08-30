//
//  ItemTableCellSvg.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemTableCellSvg.h"
#import "SVGView.h"

@implementation ItemTableCellSvg

@synthesize svgView = _svgView;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

+ (void)load {
    [super addSubclass:self];
}

- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    if ((self = [super initWithTableView:tableView idrItem:idrItem])) {
        
    }
    return self;
}

- (void)dealloc {
    self.svgView = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Class stuff
// -----------------------------------------------------------

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return ![idrItem hasObservation] && idrItem.idrSvgView != nil;
}

+ (ItemTableCellSvg *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCellSvg *cell = (ItemTableCellSvg *)idrItem.itemTableCell;
    if (cell == nil) {
        cell = [[[self alloc] initWithTableView:tableView idrItem:idrItem] autorelease];
    }
    return cell;
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    return 1.0;
}


@end
