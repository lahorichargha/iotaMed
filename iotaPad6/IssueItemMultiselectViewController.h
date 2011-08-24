//
//  IssueItemMultiselectViewController.h
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/23/11.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IDRItem;

@protocol IssueItemMultiselectViewDelegate <NSObject>

- (void)changeMultiselectLable:(IDRItem *)newItem;
- (void)dismissPopoverForMultiselect;

@end

@interface IssueItemMultiselectViewController : UITableViewController

@property (nonatomic, retain) IDRItem *idrItem;
@property (nonatomic, retain) UIBarButtonItem *okButtonItem;
@property (nonatomic, retain) UIBarButtonItem *clearButtonItem;
@property (nonatomic, assign) id<IssueItemMultiselectViewDelegate> delegate;

- (IBAction)doneAction:(id)sender;
- (IBAction)dismissAction:(id)sender;

@end
