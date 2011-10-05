//
//  IssueTemplatePhaseViewController.m
//  iotaPad6
//
//  Created by Martin on 2011-03-04.
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

#import "IssueTemplateBlockViewController.h"
#import "IDRWorksheet.h"
#import "IDRWorksheets.h"
#import "IDRBlock.h"
#import "IDRDescription.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRContact.h"
#import "ItemCellTemplate.h"
#import "Funcs.h"
#import "NSString+iotaAdditions.h"
#import "IotaContext.h"
#import "Patient.h"
#import "PatientContext.h"
#import "MyIotaPatientContext.h"
#import "Notifications.h"
#import "IssueBlockInfoDialog.h"
#import "ContactSelectOrCreateForm.h"


// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation IssueTemplateBlockViewController

@synthesize idrWorksheet = _idrWorksheet;
@synthesize idrBlock = _idrBlock;
@synthesize lblDescription = _lblDescription;
@synthesize tableView = _tableView;
@synthesize customTitle = _customTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.idrWorksheet = nil;
    self.idrBlock = nil;
    self.lblDescription = nil;
    self.tableView = nil;
    self.customTitle = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Actions
// -----------------------------------------------------------

- (void)notifyWorksheetsChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:kIssueListChangedNotification object:nil];
}


- (BOOL)blockAlreadyExists {
    PatientContext *pCtx = [IotaContext getCurrentPatientContext];
    IDRBlock *block = [pCtx blockWithTemplateUuid:self.idrBlock.templateUuid inWorksheetWithTemplateUuid:self.idrWorksheet.templateUuid];
    return (block != nil);
}

- (void)addBlockToCurrentPatient {
    // TODO:
    // consider this: sometimes a worksheet should be forcibly added in duplicate,
    // when the patient has a second incidence of the same issue, such as ear infection,
    // or even a second workup for diabetes. But sometimes we don't want to add a 
    // duplicate worksheet, only a phase to an existing worksheet. Right now, we
    // don't add duplicate worksheets.
    
    self.customTitle = @"";

    // if there is already a current contact, skip asking for one and just use it
    PatientContext *pCtx = [IotaContext getCurrentPatientContext];
    if (pCtx != nil && [pCtx currentContact] != nil) {
        self.customTitle = dateForIssueTitles([[pCtx currentContact] date]);
        [pCtx addBlock:self.idrBlock toExistingWorksheet:self.idrWorksheet customTitle:self.customTitle];
        return;
    }
    
    ContactSelectOrCreateForm *cscf = [[ContactSelectOrCreateForm alloc] initWithNibName:@"ContactSelectOrCreateForm" bundle:nil];
    cscf.modalPresentationStyle = UIModalPresentationFormSheet;
    cscf.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    cscf.target = self;
    cscf.action = @selector(afterContactForm:);
    [self presentModalViewController:cscf animated:YES];
    [cscf release];
    return;
   
}

- (void)afterContactForm:(NSNumber *)okOrCreate {

    BOOL didOk = [okOrCreate boolValue];
    if (!didOk)
        return;
    
    PatientContext *pCtx = [IotaContext getCurrentPatientContext];
    [pCtx addBlock:self.idrBlock toExistingWorksheet:self.idrWorksheet customTitle:self.customTitle];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)plusButton:(id)sender {
    Patient *patient = [IotaContext getCurrentPatient];
    if (patient == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lägga till delmall" message:@"Du måste ha valt en patient innan du kan lägga till en mall eller delmall till patienten" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    else if ([self.idrBlock blockType] == eBlockTypePatient) {
        // here we have to check if the block is already in the minIotaContext and if not, add it
        // also we should pop a box telling the user where the template ends up and why
        
        // so, first check if block is already present in minIotaContext
        // and if it is, say so and do nothing more
        MyIotaPatientContext *miCtx = [IotaContext getOrCreateCurrentMyIotaContext];
        self.idrBlock.worksheet = self.idrWorksheet;
        if ([miCtx addBlockIfNew:self.idrBlock])
            [IotaContext saveCurrentMyIotaPatientContext];
        
        // else add it to minIotaContext and do a save to server
        
        // then tell the user what happened and why you won't see this block in the issue list,
        // but only in the inbox form
        [self dismissModalViewControllerAnimated:YES];
    }
    else if ((self.idrBlock.repeats == NO) && [self blockAlreadyExists]) {
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:@"Lägga till delmall"
                                        message:@"Denna mall används normalt endast en gång och finns redan inlagd för denna patient. Vill du ändå lägga till den igen?" 
                                  delegate:self cancelButtonTitle:@"Nej" otherButtonTitles:@"Ja", nil];
        [alertView show];
        [alertView release];
    }
    else {
        [self addBlockToCurrentPatient];
        [self dismissModalViewControllerAnimated:YES];
    }
}

#define kNoButton   0
#define kYesButton  1

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the only possibility here is "Yes add this phase anyhow"
    if (buttonIndex == kYesButton) {
        [self addBlockToCurrentPatient];
    }
    [self dismissModalViewControllerAnimated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View lifecycle
// -----------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = self.idrBlock.title;
    self.lblDescription.text = [self.idrBlock.description.content iotaNormalize];
    NSString *title = self.idrBlock.title;
    self.navigationItem.titleView = navBarLabelWithText(title);
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                            target:self 
                                                                                            action:@selector(plusButton:)] autorelease];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"block item count: %d", [self.idrBlock.items count]);
    return [self.idrBlock.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IDRItem *item = [self.idrBlock.items objectAtIndex:[indexPath row]];
    ItemCellTemplate *cell = [ItemCellTemplate cellForTableView:tableView idrItem:item];
    return cell;
}

// optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Header";
}
 */

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    IDRItem *item = [self.idrBlock.items objectAtIndex:[indexPath row]];
    return [ItemCellTemplate cellHeightForTableView:tableView idrItem:item];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


@end
