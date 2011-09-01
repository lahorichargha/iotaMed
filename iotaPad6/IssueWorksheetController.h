//
//  IssueWorksheetController.h
//  iotaPad6
//
//  Created by Martin on 2011-02-11.
//  Copyright © 2011, MITM AB, Sweden
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1.  Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//  2.  Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//  3.  Neither the name of MITM AB nor the name iotaMed®, nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY MITM AB ‘’AS IS’’ AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MITM AB BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

@class IDRWorksheet;
@class IDRBlock;

#import <UIKit/UIKit.h>
#import "DetailViewControllerWithToolbar.h"
#import "ItemCellDelegate.h"

#import "LabOrderController.h"
#import "PrescriptionController.h"
#import "ReferralControllerDelegate.h"
#import "IssueItemSelectViewController.h"
#import "IssueItemMultiselectViewController.h"

@interface IssueWorksheetController : DetailViewControllerWithToolbar <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, 
    ItemCellDelegate, 
    LabOrderControllerDelegate, 
    PrescriptionControllerDelegate,
    ReferralControllerDelegate> {
}


@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IDRWorksheet *idrWorkSheet;
@property (nonatomic, retain) IDRBlock *idrBlock;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnContact;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) UIPopoverController *selectPopoverController;
@property (nonatomic, retain) IssueItemSelectViewController *issueItemSelect;
@property (nonatomic, retain) IssueItemMultiselectViewController *issueItemMultiselect;
@property (nonatomic, retain) UINavigationController *multiselectNavigationController;
@property (nonatomic, retain) NSArray *popoverContentView;
@property (nonatomic, retain) NSIndexPath *ipForCell;

- (void)refresh;
- (IBAction)btnContact:(id)sender;
- (void)settingTableViewFrameForPortrait;
- (void)settingTableViewFrameForLandscape;

@end
