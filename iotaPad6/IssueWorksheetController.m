//
//  IssueWorksheetController.m
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

#import "IssueWorksheetController.h"
#import "IDRWorksheet.h"
#import "IDRBlock.h"
#import "ItemCellIssue.h"
#import "IDRItem.h"
#import "IDRAction.h"
#import "Patient.h"
#import "Notifications.h"
#import "IDRContact.h"
#import "IotaContext.h"
#import "PatientContext.h"
#import "ReferralController.h"
#import "PrescriptionController.h"
#import "ValueLookupForm.h"
#import "Funcs.h"
#import "ThemeColors.h"
#import "ContactSelectOrCreateForm.h"
#import "IDRObservation.h"
#import "IDRSelect.h"

@implementation IssueWorksheetController

@synthesize tableView = _tableView;
@synthesize idrWorkSheet = _idrWorkSheet;
@synthesize idrBlock = _idrBlock;
@synthesize activityIndicator = _activityIndicator;
@synthesize btnContact = _btnContact;
@synthesize imageView = _imageView;
@synthesize selectPopoverController = _selectPopoverController;
@synthesize issueItemSelect = _issueItemSelect;
@synthesize selectedText = _selectedText;
@synthesize ipForCell = _ipForCell;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Object life cycle
// -----------------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.selectedText = @"Text";
    }
    return self;
}

- (void)dealloc {
    self.tableView = nil;
    self.idrWorkSheet = nil;
    self.idrBlock = nil;
    self.activityIndicator = nil;
    self.btnContact = nil;
    [_imageView release];
    [_selectPopoverController release];
    [_issueItemSelect release];
    [_selectedText release];
    [_ipForCell release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Configuration overrides
// -----------------------------------------------------------

// tell superclass to implement popover button for issue list in portrait
- (BOOL)usePopoverButton {
    return YES;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View lifecycle
// -----------------------------------------------------------

- (void)settingTableViewFrameForPortrait {
    if (!self.idrBlock) {
        self.tableView.frame = CGRectMake(0, 44, 768, 911);
        UIImageView *tableBackg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background5.png"]];
        self.tableView.backgroundView = tableBackg;
        [tableBackg release];
        self.imageView.image = nil;
    } else {
        self.tableView.frame = CGRectMake(30, 79, 708, 841);
        UIImageView *tableBackg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background6.png"]];
        self.tableView.backgroundView = tableBackg;
        [tableBackg release];
        self.imageView.frame = CGRectMake(0, 44, 768, 911);
        self.imageView.image = [UIImage imageNamed:@"background8.png"];
    }
}

- (void)settingTableViewFrameForLandscape {
    if (!self.idrBlock) {
        self.tableView.frame = CGRectMake(0, 44, 704, 655);
        UIImageView *tableBackg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background4.png"]];
        self.tableView.backgroundView = tableBackg;
        [tableBackg release];
        self.imageView.image = nil;
    } else {
        self.tableView.frame = CGRectMake(30, 64, 644, 615);
        UIImageView *tableBackg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background6.png"]];
        self.tableView.backgroundView = tableBackg;
        [tableBackg release];
        self.imageView.frame = CGRectMake(0, 44, 704, 655);
        self.imageView.image = [UIImage imageNamed:@"background7.png"];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self refresh];
}

- (void)setTableHeader {
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        [self settingTableViewFrameForPortrait];
    } else {
        [self settingTableViewFrameForLandscape];
    }

    IDRContact *currentContact = [[IotaContext getCurrentPatientContext] currentContact];
    self.btnContact.title = (currentContact) ? [currentContact contactAsHeader] : @"<Inga kontakter>";
    
    if (!self.idrBlock) {
        self.tableView.tableHeaderView = nil;
        return;
    }
    UIView *thView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 760, 120)] autorelease];
    UIImageView *backround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doctor.png"]];
    [thView addSubview:backround];
    UILabel *thLabel = [[[UILabel alloc] initWithFrame:CGRectMake(140, 20, 620, 66)] autorelease];
    thLabel.backgroundColor = [UIColor clearColor];
    thLabel.textColor = [UIColor brownColor];
    [thView addSubview:thLabel];
    
    IDRContact *issueWSContact = self.idrBlock.contact;
    
    thLabel.font = [UIFont boldSystemFontOfSize:20.0];
    thLabel.text = [issueWSContact contactAsHeader];
    
    if (issueWSContact != currentContact) {
        UIImage *image = [UIImage imageNamed:@"Lockknock.png"];
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
        CGFloat w = image.size.width;
        CGFloat h = image.size.height;
        CGFloat tw = thView.frame.size.width;
        imageView.frame = CGRectMake(tw - 60, 10, w/4.0, h/4.0);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [thView addSubview:imageView];
    }
    self.tableView.tableHeaderView = thView;
    if ([self.idrBlock blockType] == eBlockTypePatient) {
        [self.tableView setBackgroundColor:[[ThemeColors themeColors] worksheetBackgroundPatientBlock]];
        backround.image = nil;
    }
    [backround release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(obsDataChanged:) name:kObservationDataChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactChanged:) name:kContactListChangedNotification object:nil];
    [self refresh];
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setSelectPopoverController:nil];
    [self setIssueItemSelect:nil];
    [self setSelectedText:nil];
    [self setIpForCell:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)refresh {
    [self.tableView reloadData];
    [self setTableHeader];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void)obsDataChanged:(NSNotification *)notification {
    [self refresh];
}

- (void)contactChanged:(NSNotification *)notification {
    [self refresh];
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.idrBlock.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IDRItem *item = [self.idrBlock.items objectAtIndex:[indexPath row]];
    ItemCellIssue *cell = [ItemCellIssue cellForTableView:tableView idrItem:item];
    cell.itemCellDelegate = self;
    //    cell.textLabel.text = item.content;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Item cell delegate
// -----------------------------------------------------------

- (void)presentLabOrderForm:(IDRItem *)item {
    LabOrderController *loc = [[LabOrderController alloc] initWithNibName:@"LabOrderController" bundle:nil];
    loc.idrItem = item;
    loc.modalPresentationStyle = UIModalPresentationFormSheet;
    loc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    loc.labOrderControllerDelegate = self;
    [self presentModalViewController:loc animated:YES];
    [loc release];
}

- (void)sentLabOrderForItem:(IDRItem *)item {
    [self.tableView reloadData];
}

// -----------------------------------------------------------
    
- (void)presentReferralForm:(IDRItem *)item {
    ReferralController *rc = [[ReferralController alloc] initWithNibName:@"ReferralController" bundle:nil];
    rc.item = item;
    rc.rcDelegate = self;
    rc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    rc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:rc animated:YES];
    [rc release];
}

- (void)sentReferralForItem:(IDRItem *)item {
    [[NSNotificationCenter defaultCenter] postNotificationName:kObservationDataChangedNotification object:nil];
    [self refresh];
}

// -----------------------------------------------------------

- (void)presentPrescriptionForm:(IDRItem *)item {
    PrescriptionController *pc = [[[PrescriptionController alloc] initWithNibName:@"PrescriptionController" bundle:nil] autorelease];
    pc.idrItem = item;
    pc.pcDelegate = self;
    UINavigationController *unc = [[[UINavigationController alloc] initWithRootViewController:pc] autorelease];
    unc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    unc.modalPresentationStyle = UIModalPresentationFormSheet;  // this one has no effect
    [self presentModalViewController:unc animated:YES];
}

- (void)sentPrescriptionForItem:(IDRItem *)item {
    [[NSNotificationCenter defaultCenter] postNotificationName:kObservationDataChangedNotification object:nil];
}

// -----------------------------------------------------------

- (void)presentValueLookupForm:(IDRItem *)item {
    ValueLookupForm *vlf = [[[ValueLookupForm alloc] initWithNibName:@"ValueLookupForm" bundle:nil] autorelease];
    vlf.idrItem = item;
    vlf.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vlf.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:vlf animated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ItemCellIssue cellHeightForTableView:tableView idrItem:[self.idrBlock.items objectAtIndex:[indexPath row]]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCellIssue *myCell = (ItemCellIssue *)cell;
    [myCell.selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

// -----------------------------------------------------------
#pragma mark -
#pragma mark IotaContext delegate overrides
// -----------------------------------------------------------

- (BOOL)willSwitchFromPatient:(Patient *)oldPatient {
    return YES;
}

- (void)didSwitchToPatient:(Patient *)newPatient {
    self.idrBlock = nil;
    self.idrWorkSheet = nil;
    [self refresh];
    self.patientButton.title = [Patient buttonTitleForPatient:newPatient];
    self.btnContact.enabled = (newPatient != nil);
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Action handler
// -----------------------------------------------------------

- (void)btnContact:(id)sender {
    ContactSelectOrCreateForm *cscf = [[ContactSelectOrCreateForm alloc] initWithNibName:@"ContactSelectOrCreateForm" 
                                                                                  bundle:nil];
    cscf.modalPresentationStyle = UIModalPresentationFormSheet;
    cscf.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    cscf.target = self;
    cscf.action = @selector(afterContactForm:);
    [self presentModalViewController:cscf animated:YES];
    [cscf release];
}

- (void)afterContactForm:(NSNumber *)okOrCreate {
    if (![okOrCreate boolValue])
        return;
    [self refresh];
}

#pragma mark - IssueItemSelectViewDelegate 

- (void)changeSelectLable:(NSString *)text {
    self.selectedText = text;
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:self.ipForCell];
    ItemCell *myCell = (ItemCell *)cell;
    myCell.selectLable.text = self.selectedText;
    
    if ([text isEqualToString:@""]) {
        NSLog(@"selected nothing");
    } else {
        [self.selectPopoverController dismissPopoverAnimated:YES];
    }
}

- (IBAction)selectButtonAction:(id)sender {
    UIView *v = (UIView *)sender;
    ItemCell *cell = (ItemCell *)v.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    self.ipForCell = indexPath;
    
    IDRItem *item = [self.idrBlock.items objectAtIndex:[indexPath row]];
    
    IssueItemSelectViewController *selectListController = [[IssueItemSelectViewController alloc] init];
    selectListController.idrItem = item;
    self.issueItemSelect = selectListController;
    self.issueItemSelect.itemSelectDelegate = self;
    [selectListController release];
    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.issueItemSelect];
    
    
//    UIPopoverController *poc = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    
    UIPopoverController *poc = [[UIPopoverController alloc] initWithContentViewController:self.issueItemSelect];
    [poc presentPopoverFromRect:v.frame inView:(UIView *)v.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
    self.selectPopoverController = poc;
    self.selectPopoverController.delegate = self;
    [poc release];
//    [navigationController release];
}

#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
//    NSLog(@"a popover was dismissed!");
}

@end
