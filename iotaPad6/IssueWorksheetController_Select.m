//
//  IssueWorksheetController_Select.m
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/31/11.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IssueWorksheetController_Select.h"
#import "ItemCell.h"
#import "IDRBlock.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRObsDefinition.h"
#import "IDRSelect.h"
#import "IDRValue.h"

@implementation IssueWorksheetController (Select)

- (void)initForIssueItemSelectViewController {
    IssueItemSelectViewController *selectListController = [[IssueItemSelectViewController alloc] init];
    self.issueItemSelect = selectListController;
    self.issueItemSelect.delegate = self;
    [selectListController release];
}

#pragma mark - IssueItemSelectViewDelegate 

- (void)shouldChangeSelectLable:(NSString *)text {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:self.ipForCell];
    ItemCell *myCell = (ItemCell *)cell;
    
    [self.issueItemSelect.idrItem setItemValue:text];
    
    IDRObsDefinition *obsDef = self.issueItemSelect.idrItem.observation.obsDefinition;
    IDRContact *contact = self.issueItemSelect.idrItem.parentBlock.contact;
    IDRValue *value = [obsDef valueForContact:contact];
    
    myCell.selectLabel.text = value.value;
    
    [self.selectPopoverController dismissPopoverAnimated:YES];
}

- (IBAction)selectButtonAction:(id)sender {
    UIView *v = (UIView *)sender;
    ItemCell *cell = (ItemCell *)v.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    self.ipForCell = indexPath;
    
    IDRItem *item = [self.idrBlock.items objectAtIndex:[indexPath row]];
    
    IDRSelect *noChoice = [[IDRSelect alloc] init];
    NSMutableString *contentText = [NSMutableString stringWithString:@"<inget valt>"];
    noChoice.content = contentText;
    if (![[[item.observation.selects objectAtIndex:0] content] isEqualToString:@"<inget valt>"]) {
        [item.observation.selects insertObject:noChoice atIndex:0];
    } 
    [noChoice release];
    
    self.issueItemSelect.idrItem = item;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (IDRSelect *s in self.issueItemSelect.idrItem.observation.selects) {
        NSString *text = s.content;
        [array addObject:text];
    }
    NSUInteger i = [array indexOfObject:cell.selectLabel.text];
    self.issueItemSelect.lastIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
    [array release];
    
    [self.selectPopoverController setContentViewController:[self.popoverContentView objectAtIndex:0] animated:NO];
    
    NSInteger rowCount = [self.issueItemSelect.idrItem.observation.selects count];
    CGFloat tableViewRowHeight = 40.0;
    if (rowCount < 10) 
        [self.selectPopoverController setPopoverContentSize:CGSizeMake(250.0, tableViewRowHeight * rowCount) animated:YES];
    else
        [self.selectPopoverController setPopoverContentSize:CGSizeMake(250.0, tableViewRowHeight * 10) animated:YES];
    
    [self.selectPopoverController presentPopoverFromRect:v.frame inView:(UIView *)v.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

@end
