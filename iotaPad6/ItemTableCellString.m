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

@synthesize tfValue = _tfValue;

+ (void)load {
    [super addSubclass:self];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return [idrItem hasObservation] && ![idrItem.observation isNumeric] && ![idrItem.observation isCheck];
}

+ (ItemTableCellString *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCellString *cell = (ItemTableCellString *)idrItem.itemTableCell;
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
    if ((self = [super initWithTableView:tableView idrItem:idrItem]))  {
        self.tfValue = (UITextField *)[self viewOfClass:[UITextField class] tag:TAG_TEXTFIELD];
        self.tfValue.borderStyle = UITextBorderStyleRoundedRect;
        self.tfValue.delegate = self;
        self.tfValue.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return self;
}

- (void)layoutSubviews {
    CGRect newFrame = CGRectMake(260, 0, 150, 22);
    self.tfValue.frame = newFrame;
}

- (void)dealloc {
    self.lblContent = nil;
    self.tfValue = nil;
    [super dealloc];
}

@end
