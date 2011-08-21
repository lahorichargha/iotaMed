//
//  ItemTableCellAnalog.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemTableCellAnalog.h"

@implementation ItemTableCellAnalog

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

+ (void)load {
    [super addSubclass:self];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Class constructors
// -----------------------------------------------------------

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return NO;
}

+ (ItemTableCellAnalog *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCellAnalog *cell = [[self alloc] init];
    cell.parentTableView = tableView;
    cell.idrItem = idrItem;
    return cell;
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    return 44.0;
}

@end
