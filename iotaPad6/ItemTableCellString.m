//
//  ItemTableCellString.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemTableCellString.h"
#import "IDRObservation.h"

@implementation ItemTableCellString

+ (void)load {
    [super addSubclass:self];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return [idrItem hasObservation] && ![idrItem.observation isNumeric];
}

+ (ItemTableCellString *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    return [[self alloc] init];
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    return 1.0;
}

@end
