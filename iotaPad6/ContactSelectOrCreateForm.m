//
//  ContactSelectOrCreateForm.m
//  iotaPad6
//
//  Created by Martin on 2011-03-16.
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

/* --------------------------------------------------------------------------
 * This form allows the user to select a preexisting contact or create a new
 * contact. The selected or created contact becomes the current contact in
 * the patient context and YES is returned.
 * If the user cancels, NO is returned.
 * If no patient context is current, this form will throw an error.
 *
 *
 */


#import "ContactSelectOrCreateForm.h"
#import "IotaContext.h"
#import "PatientContext.h"
#import "IDRContact.h"
#import "XML2IDR.h"
#import "IDRWorksheet.h"
#import "IDRBlock.h"
#import "Notifications.h"
#import "ContactCreationForm.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface ContactSelectOrCreateForm ()
@property (nonatomic, assign) BOOL okClicked;
@end



@implementation ContactSelectOrCreateForm

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@synthesize tableView = _tableView;
@synthesize btnOk = _btnOk;
@synthesize action = _action;
@synthesize target = _target;
@synthesize okClicked = _okClicked;

@synthesize lblHeader = _lblHeader;
@synthesize btnCreate = _btnCreate;
@synthesize btnCancel = _btnCancel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.tableView = nil;
    self.btnOk = nil;
    self.action = nil;
    self.target = nil;
    self.lblHeader = nil;
    self.btnCreate = nil;
    self.btnCancel = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View Lifecycle
// -----------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lblHeader.text = NSLocalizedString(@"SelectOrCreateContact", @"Explanatory text");
    [self.btnCreate setTitle:NSLocalizedString(@"New contact", @"Create a new contact button") forState:UIControlStateNormal];
    [self.btnOk setTitle:NSLocalizedString(@"Ok", @"Ok button") forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"Cancel", @"Cancel button") forState:UIControlStateNormal];
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
    PatientContext *pCtx = [IotaContext getCurrentPatientContext];
    if (pCtx == nil) 
        [NSException raise:@"Contact select form called without any current patient context" format:@""];
    return [pCtx.contacts count];
}

// -----------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    PatientContext *pCtx = [IotaContext getCurrentPatientContext];
    IDRContact *contact = [pCtx.contacts objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [contact contactAsHeader];
    
    cell.accessoryType = (contact == pCtx.currentContact) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    // configure the cell here
    
    return cell;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PatientContext *pCtx = [IotaContext getCurrentPatientContext];
    IDRContact *contact = [pCtx.contacts objectAtIndex:[indexPath row]];
    pCtx.currentContact = contact;
    [self.tableView reloadData];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Actions
// -----------------------------------------------------------

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.target performSelector:self.action withObject:[NSNumber numberWithBool:self.okClicked]];
}

- (void)reportResult:(BOOL)ok {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnCreate:(id)sender {
    ContactCreationForm *ccf = [[ContactCreationForm alloc] initWithNibName:@"ContactCreationForm" bundle:nil];
    ccf.modalPresentationStyle = UIModalPresentationFormSheet;
    ccf.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    ccf.target = self;
    ccf.action = @selector(continueContactCreation:);
    [self presentModalViewController:ccf animated:YES];
    [ccf release];
}

- (void)continueContactCreation:(IDRBlock *)idrBlock {
    // we really don't need to do anything here, do we?
    // except maybe...
    [self.tableView reloadData];
}

- (IBAction)btnCancel:(id)sender {
    self.okClicked = NO;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnOk:(id)sender {
    self.okClicked = YES;
    [self dismissModalViewControllerAnimated:YES];
}


@end
