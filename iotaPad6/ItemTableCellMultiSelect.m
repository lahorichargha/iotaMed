//
//  ItemTableCellMultiSelect.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemTableCellMultiSelect.h"

@implementation ItemTableCellMultiSelect

+ (void)load {
    [super addSubclass:self];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return NO;
}

+ (ItemTableCellMultiSelect *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCellMultiSelect *cell = (ItemTableCellMultiSelect *)idrItem.itemTableCell;
    if (cell == nil) {
        cell = [[[self alloc] initWithTableView:tableView idrItem:idrItem] autorelease];
    }
    return cell;
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    return 1.0;
}


@end
