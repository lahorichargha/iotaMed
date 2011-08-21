//
//  ItemTableCellSvgInteractive.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemTableCellSvgInteractive.h"

@implementation ItemTableCellSvgInteractive

+ (void)load {
    [super addSubclass:self];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return [idrItem hasObservation] && idrItem.idrSvgView != nil;
}

+ (ItemTableCellSvgInteractive *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCellSvgInteractive *cell = [[self alloc] init];
    cell.parentTableView = tableView;
    cell.idrItem = idrItem;
    return cell;
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    return 44.0;
}

@end
