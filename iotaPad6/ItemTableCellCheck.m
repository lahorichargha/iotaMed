//
//  ItemTableCellCheck.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemTableCellCheck.h"
#import "IDRObservation.h"

@implementation ItemTableCellCheck

+ (CGFloat)rightMargin {
    return kMediumWideRight;
}

+ (void)load {
    [super addSubclass:self];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return [idrItem hasObservation] && [idrItem.observation isCheck];
}

+ (ItemTableCellCheck *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCellCheck *cell = (ItemTableCellCheck *)idrItem.itemTableCell;
    if (cell == nil) {
        cell = [[[self alloc] initWithTableView:tableView idrItem:idrItem] autorelease];
    }
    return cell;
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    return [super subCellHeightForTableView:tableView idrItem:idrItem];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    if ((self = [super initWithTableView:tableView idrItem:idrItem])) {
        
    }
    return self;
}


@end
