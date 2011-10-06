//
//  IssueWorksheetController_Multiselect.m
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/31/11.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IssueItemMultiselectViewController.h"
#import "IssueWorksheetController_Multiselect.h"
#import "ItemCell.h"
#import "IDRBlock.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRObsDefinition.h"
#import "IDRMultiselect.h"
#import "IDRValue.h"
#import "IDRContact.h"
#import "IotaContext.h"

@implementation IssueWorksheetController (Multiselect)

- (void)initForIssueItemMultiselectViewController {
    IssueItemMultiselectViewController *multiselectListController = [[IssueItemMultiselectViewController alloc] init];
    self.issueItemMultiselect = multiselectListController;
    self.issueItemMultiselect.delegate = self;
    [multiselectListController release];
    
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    [navigationController addChildViewController:self.issueItemMultiselect];
    self.multiselectNavigationController = navigationController;
    [navigationController release];
}

#pragma mark - IssueItemMultielectViewDelegate

- (void)dismissPopoverForMultiselect {
    [self.selectPopoverController dismissPopoverAnimated:YES];
}

- (void)shouldChangeMultiselectLable:(IDRItem *)newItem { 
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (IDRMultiselect *ms in newItem.observation.multiselects) {
        if (ms.selected == YES) {
            NSString *text = ms.content;
            [array addObject:text];
        }
    }
    
    NSMutableString *text = [NSMutableString stringWithCapacity:50];
    
    if ([array count] == 0) {
        [text setString:@"<inga val>"];
    } else {
        for (NSString *s in array) {
            [text appendFormat:@"%@, ", s];
        }
    }
    [array release];
    
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:self.ipForCell];
    ItemCell *myCell = (ItemCell *)cell;
    
    self.issueItemMultiselect.idrItem = newItem;
    [self.issueItemMultiselect.idrItem setItemValue:text];
    
    IDRObsDefinition *obsDef = self.issueItemMultiselect.idrItem.observation.obsDefinition;
    IDRContact *contact = self.issueItemMultiselect.idrItem.parentBlock.contact;
    IDRValue *value = [obsDef valueForContact:contact];
    
    myCell.multiselectLabel.text = value.value;
    
    [self.selectPopoverController dismissPopoverAnimated:YES];
}

- (IBAction)multiselectButtonAction:(id)sender {
    UIView *v = (UIView *)sender;
    ItemCell *cell = (ItemCell *)v.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    self.ipForCell = indexPath;
    
    IDRItem *item = [self.idrBlock.items objectAtIndex:[indexPath row]];
    
    self.issueItemMultiselect.idrItem = item;
    
    IDRContact *currentContact = [[IotaContext getCurrentPatientContext] currentContact];
    IDRContact *itemContact = self.issueItemMultiselect.idrItem.parentBlock.contact;
    
    if (currentContact == itemContact) {
        [self.selectPopoverController setContentViewController:[self.popoverContentView objectAtIndex:1] animated:NO];
        
        NSInteger rowCount = [self.issueItemMultiselect.idrItem.observation.multiselects count];
        CGFloat tableViewRowHeight = 40.0;
        if (rowCount < 10) 
            [self.selectPopoverController setPopoverContentSize:CGSizeMake(250.0, tableViewRowHeight * rowCount) animated:YES];
        else
            [self.selectPopoverController setPopoverContentSize:CGSizeMake(250.0, tableViewRowHeight * 10) animated:YES];
        
        [self.selectPopoverController presentPopoverFromRect:v.frame inView:(UIView *)v.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    } else {
        UIAlertView *aw = [[[UIAlertView alloc] 
                            initWithTitle:@"Information" 
                            message:@"Du kan inte ändra i innehållet eftersom den valda kontakten inte är densamma som issue kontakten" 
                            delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [aw show];
    }
}


@end
