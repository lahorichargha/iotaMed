//
//  PatientListController.m
//  iotaPad6
//
//  Created by Martin on 2011-02-16.
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

//  The interaction between the changing and saving of patient contexts need to be explained.
//
//  When this view is opened, it initiates the saving of the current
//  patient context. This view enables or disables the Ok button depending on if the current
//  patient context is clean or dirty.
//  This view subscribes to the notification dirtyStateChanged, and every time that notification
//  is received, it updates the Ok button state accordingly.
//
//  This view subscribes to the patientChange:(BOOL) notification.
//  When the Ok button is hit, it asks IotaContext to change patient. When the patient is changed,
//  or fails to change, it gets a patientChange:(BOOL) notification so it can close, even if the
//  change failed.



#import "PatientListController.h"
#import "IotaContext.h"
#import "PatientContext.h"
#import "Patients.h"
#import "Patient.h"
#import "PatientController.h"
#import "PatientDB.h"
#import "Notifications.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface PatientListController() 
- (void)enableOkButton;
- (void)disableOkButton;
- (void)updateOkButtonState;
@property (retain) NSIndexPath *deletePath;
@end


@implementation PatientListController

// -----------------------------------------------------------
#pragma mark -
#pragma mark Properties
// -----------------------------------------------------------

@synthesize patientTableView = _patientTableView;
@synthesize btnOk = _btnOk;
@synthesize btnCancel = _btnCancel;
@synthesize activityIndicator = _activityIndicator;
@synthesize btnNew = _btnNew;
@synthesize deletePath = _deletePath;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Convenience constructor
// -----------------------------------------------------------

+ (void)showList:(UIViewController *)parent {
    PatientListController *plc = [[[PatientListController alloc] initWithNibName:@"PatientListController" bundle:nil] autorelease];
    plc.modalPresentationStyle = UIModalPresentationFormSheet;
    [parent presentModalViewController:plc animated:YES];
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Object life cycle
// -----------------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.btnOk = nil;
    self.patientTableView = nil;
    self.activityIndicator = nil;
    self.deletePath = nil;
    [_btnCancel release];
    [_btnNew release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View lifecycle
// -----------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dirtyStateChanged:) name:kPatientDirtyStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patientChangeEnded:) name:kPatientChangeEnded object:nil];
    [self updateOkButtonState];
    [self.activityIndicator startAnimating];
    [IotaContext saveCurrentPatientContext];
    [self.activityIndicator stopAnimating];
    
    [self.btnNew setTitle:NSLocalizedString(@"New", @"New button") forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"Cancel", @"Cancel button") forState:UIControlStateNormal];
    [self.btnOk setTitle:NSLocalizedString(@"Ok", @"Ok button") forState:UIControlStateNormal];
    
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setBtnCancel:nil];
    [self setBtnNew:nil];
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
#pragma mark Actions
// -----------------------------------------------------------

- (Patient *)_patientAt:(NSIndexPath *)indexPath {
    Patient *selected = nil;
    if (indexPath != nil) {
        selected = (Patient *)[[Patients allPatients] objectAtIndex:[indexPath row]];
    }
    return selected;
}

- (Patient *)_selectedPatient {
    NSIndexPath *indexPath = [self.patientTableView indexPathForSelectedRow];
    return [self _patientAt:indexPath];
}

- (IBAction)btnOk:(id)sender {
    Patient *selectedPatient = [self _selectedPatient];
    if (selectedPatient) {
        [self.activityIndicator startAnimating];
        [IotaContext changeToPatient:selectedPatient];
        [self.activityIndicator stopAnimating];
        NSLog(@"Selected patient: %@", [Patient buttonTitleForPatient:selectedPatient]);
    }
}

- (IBAction)btnCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnNew:(id)sender {
    Patient *patient = [[Patient alloc] init];
    
    PatientController *pc = [[[PatientController alloc] initWithNibName:@"PatientController" bundle:nil] autorelease];
    pc.delegate = self;
    pc.modalPresentationStyle = UIModalPresentationFormSheet;
    pc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:pc animated:YES];
    
    [patient release];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark PatientControllerDelegate
// -----------------------------------------------------------

- (void)createPatient:(Patient *)patient {
    [PatientDB addOrUpdatePatient:patient];
    [self.patientTableView reloadData];
}

- (void)updatePatient:(Patient *)patient {
    [PatientDB addOrUpdatePatient:patient];
    [self.patientTableView reloadData];
}

- (void)deletePatient:(Patient *)patient {
    [PatientDB deletePatient:patient];
    [self.patientTableView reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Notifications
// -----------------------------------------------------------

- (void)dirtyStateChanged:(NSNotification *)notification {
    [self updateOkButtonState];
}

- (void)patientChangeEnded:(NSNotification *)notification {
    BOOL success = [[notification object] boolValue];
    if (success) 
        NSLog(@"PatientListController: Changed patient successfully");
    else
        NSLog(@"PatientListController: Failed to change patient");
    [self dismissModalViewControllerAnimated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View state
// -----------------------------------------------------------
     
- (void)updateOkButtonState {
    PatientContext *pCtx = [IotaContext getCurrentPatientContext];
    // if something is selected and either no current patient is selected, or there is a current patient
    // and it's not dirty and it's not the same as you select, then enable
    BOOL hasPctx = (pCtx != nil);
    BOOL isDirty = pCtx.dirty;
    BOOL differentPatient = ![[self _selectedPatient].patientID isEqualToString:pCtx.patient.patientID];
    BOOL hasIndexPath = [self.patientTableView indexPathForSelectedRow] != nil;
    if (hasIndexPath && (!hasPctx || (!isDirty && differentPatient))) 
        [self enableOkButton];
    else
        [self disableOkButton];
}

- (void)enableOkButton {
    self.btnOk.enabled = YES;
    self.btnOk.alpha = 1.0;
}

- (void)disableOkButton {
    self.btnOk.enabled = NO;
    self.btnOk.alpha = 0.5;
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Table view delegate
// -----------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateOkButtonState];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.deletePath = indexPath;
        Patient *patient = [self _patientAt:self.deletePath];
        if (patient) {
            NSString *msg = [NSString stringWithFormat:@"Är du säker att du vill ta bort hela journalen för patient %@?", [Patient buttonTitleForPatient:patient]];
            UIAlertView *aw = [[UIAlertView alloc] initWithTitle:@"Ta bort patient" 
                                                         message:msg
                                                        delegate:self 
                                               cancelButtonTitle:@"Avbryt" 
                                               otherButtonTitles:@"Ok", nil];
            aw.delegate = self;
            [aw show];
            [aw release];
        }
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Modal warning for delete, UIAlertViewDelegate
// -----------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // cancel = 0, ok = 1
    if (buttonIndex == 1) {
        [PatientDB deletePatient:[self _patientAt:self.deletePath]];
        [self.patientTableView beginUpdates];
        [self.patientTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.deletePath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.patientTableView endUpdates];
    }
    self.deletePath = nil;
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Table view data source
// -----------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[Patients allPatients] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"Patients", @"Patients");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellID = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID] autorelease];
    }
    
    NSArray *rpts = [Patients allPatients];
    Patient *pat = (Patient *)[rpts objectAtIndex:[indexPath row]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@ %@", pat.patientID, pat.firstName, pat.lastName];
    
    return cell;
    
}


@end
