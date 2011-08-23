//
//  ReferralController.m
//  iotaPad6
//
//  Created by Martin on 2011-03-25.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "ReferralController.h"
#import "IDRItem.h"
#import "IDRAction.h"
#import "IDRObservation.h"
#import "PatientContext.h"
#import "IotaContext.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation ReferralController

@synthesize item = _item;

@synthesize toTextView = _toTextView;
@synthesize causeTextView = _causeTextView;
@synthesize historyTextView = _historyTextView;
@synthesize statusTextView = _statusTextView;
@synthesize btnSend = _btnSend;

@synthesize btnCancel = _btnCancel;
@synthesize lblTo = _lblTo;
@synthesize lblCause = _lblCause;
@synthesize lblHistory = _lblHistory;
@synthesize lblStatus = _lblStatus;

@synthesize rcDelegate = _rcDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.item = nil;
    self.toTextView = nil;
    self.causeTextView = nil;
    self.historyTextView = nil;
    self.statusTextView = nil;
    self.btnSend = nil;
    self.rcDelegate = nil;
    self.btnCancel = nil;
    self.lblTo = nil;
    self.lblCause = nil;
    self.lblHistory = nil;
    self.lblStatus = nil;
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
    NSMutableString *mutableTo = [[self.item.action.to mutableCopy] autorelease];
    [mutableTo replaceOccurrencesOfString:@"|" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableTo length])];
    self.toTextView.text = mutableTo;
    
    PatientContext *pCtx = [IotaContext getCurrentPatientContext];
    
    self.causeTextView.text = [pCtx replaceObsNamesInString:self.item.action.cause];
    self.historyTextView.text = [pCtx replaceObsNamesInString:self.item.action.history];
    self.statusTextView.text = [pCtx replaceObsNamesInString:self.item.action.status];
    
    // update UI for current language
    self.lblTo.text = NSLocalizedString(@"To:", @"Label for destination of referral");
    self.lblCause.text = NSLocalizedString(@"Cause:", @"Referral cause");
    self.lblHistory.text = NSLocalizedString(@"History:", @"Referral history label");
    self.lblStatus.text = NSLocalizedString(@"Status:", @"Referral status label");
    
    [self.btnSend setTitle:NSLocalizedString(@"Send", @"Send referral button") forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"Cancel", @"Cancel referral button") forState:UIControlStateNormal];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (IBAction)btnSend:(id)sender {
    NSLog(@"Setting: %@ / %@", self.item.observation.name, self.causeTextView.text);
    [self.item setItemValue:self.item.observation.name extendedValue:self.causeTextView.text];
    [self dismissModalViewControllerAnimated:YES];
    [self.rcDelegate sentReferralForItem:self.item];
}

- (IBAction)btnCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
