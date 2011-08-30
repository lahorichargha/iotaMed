//
//  ItemTableCellImage.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemTableCellImage.h"

@implementation ItemTableCellImage

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
    return 1.0;
}



@end
