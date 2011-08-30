//
//  ItemTableCellCheck.h
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemTableCellContent.h"

@interface ItemTableCellCheck : ItemTableCellContent

+ (ItemTableCellCheck *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem;
+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem;


@end
