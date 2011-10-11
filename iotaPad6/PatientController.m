//
//  PatientController.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-07-24.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "PatientController.h"
#import "Patient.h"

// -----------------------------------------------------------
// This form is in one of two modes:
//  patient == nil          only adding a new patient is possible
//  patient != nil          only updating or deleting
//      
// -----------------------------------------------------------

@implementation PatientController

@synthesize delegate = _delegate;
@synthesize patient = _patient;

@synthesize txtPersonnumber;
@synthesize txtFirstname;
@synthesize txtLastname;
@synthesize btnDelete;
@synthesize btnCancel;
@synthesize btnOk;
@synthesize lblPersonnumber;
@synthesize lblFirstname;
@synthesize lblLastname;
@synthesize lblDemoWarning;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.patient == nil) {
        self.btnDelete.enabled = NO;
        self.btnDelete.alpha = 0.5;
    }
    else {
        self.txtPersonnumber.text = self.patient.patientID;
        self.txtFirstname.text = self.patient.firstName;
        self.txtLastname.text = self.patient.lastName;
    }
    self.lblPersonnumber.text = NSLocalizedString(@"Personnumber", @"Personnumber");
    self.lblFirstname.text = NSLocalizedString(@"Firstname", @"Firstname");
    self.lblLastname.text = NSLocalizedString(@"Lastname", @"Lastname");
    [self.btnCancel setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
    [self.btnOk setTitle:NSLocalizedString(@"Ok", @"Ok") forState:UIControlStateNormal];
    self.lblDemoWarning.text = NSLocalizedString(@"Demo warning", @"Demo warning");
}

- (void)viewDidUnload {
    [self setTxtPersonnumber:nil];
    [self setTxtFirstname:nil];
    [self setTxtLastname:nil];
    self.patient = nil;
    [self setBtnDelete:nil];
    [self setLblPersonnumber:nil];
    [self setLblFirstname:nil];
    [self setLblLastname:nil];
    [self setBtnCancel:nil];
    [self setBtnOk:nil];
    [self setLblDemoWarning:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [txtPersonnumber release];
    [txtFirstname release];
    [txtLastname release];
    [_patient release];
    [btnDelete release];
    [lblPersonnumber release];
    [lblFirstname release];
    [lblLastname release];
    [btnCancel release];
    [btnOk release];
    [lblDemoWarning release];
    [super dealloc];
}

- (void)_readFields {
    self.patient.patientID = self.txtPersonnumber.text;
    self.patient.firstName = self.txtFirstname.text;
    self.patient.lastName = self.txtLastname.text;
}

- (IBAction)btnOk:(id)sender {
    if (self.patient == nil) {
        _patient = [[Patient alloc] init];
        [self _readFields];
        [self.delegate createPatient:self.patient];
    }
    else {
        [self _readFields];
        [self.delegate updatePatient:self.patient];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnDelete:(id)sender {
    [self.delegate deletePatient:self.patient];
    [self dismissModalViewControllerAnimated:YES];
}

@end
