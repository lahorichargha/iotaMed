//
//  PrescriptionController.m
//  iotaPad6
//
//  Created by Martin on 2011-03-25.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "PrescriptionController.h"
#import "IDRItem.h"
#import "IDRAction.h"
#import "IDRDose.h"
#import "PrescriptionDetailController.h"
#import "Notifications.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface PrescriptionController ()
@property (nonatomic, retain) NSString *doseName;
@property (nonatomic, retain) NSString *extendedDoseName;
@end


// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation PrescriptionController

@synthesize lblDescription = _lblDescription;
@synthesize tableView = _tableView;
@synthesize btnCancel = _btnCancel;
@synthesize idrItem = _idrItem;
@synthesize btnOk = _btnOk;
@synthesize btnCustom = _btnCustom;
@synthesize pcDelegate = _pcDelegate;
@synthesize lblGeneralRecommendation = _lblGeneralRecommendation;
@synthesize lblGeneralRecommendationText = _lblGeneralRecommendationText;
@synthesize lblSelectDosage = _lblSelectDosage;

@synthesize doseName = _doseName;
@synthesize extendedDoseName = _extendedDoseName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.lblDescription = nil;
    self.tableView = nil;
    self.idrItem = nil;
    self.btnOk = nil;
    self.btnCustom = nil;
    self.pcDelegate = nil;
    self.doseName = nil;
    self.extendedDoseName = nil;
    [_lblGeneralRecommendation release];
    [_lblGeneralRecommendationText release];
    [_lblSelectDosage release];
    [_btnCancel release];
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

- (void)updateEnables {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath == nil) {
        self.btnOk.enabled = NO;
        self.btnOk.alpha = 0.5;
        self.btnCustom.enabled = NO;
        self.btnCustom.alpha = 0.5;
    }
    else {
        self.btnOk.enabled = YES;
        self.btnOk.alpha = 1.0;
        self.btnCustom.enabled = YES;
        self.btnCustom.alpha = 1.0;
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View lifecycle
// -----------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Prescription", @"Prescription");
    self.lblDescription.text = self.idrItem.content;
    [self updateEnables];
    // Do any additional setup after loading the view from its nib.
    
    [self.btnCustom setTitle:NSLocalizedString(@"Custom", @"Custom") forState:UIControlStateNormal];
    self.lblGeneralRecommendation.text = NSLocalizedString(@"General recommendation", @"General recommendation");
    self.lblSelectDosage.text = NSLocalizedString(@"Select dosage", @"Select dosage");
    
}

- (void)viewDidUnload {
    [self setLblGeneralRecommendation:nil];
    [self setLblGeneralRecommendationText:nil];
    [self setLblSelectDosage:nil];
    [self setBtnCancel:nil];
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

- (IBAction)btnOk:(id)sender {
    if (self.extendedDoseName != nil && self.doseName != nil)
        [self.idrItem setItemValue:self.doseName extendedValue:self.extendedDoseName];
    [self.pcDelegate refresh];
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kObservationDataChangedNotification object:nil];
}

- (IBAction)btnCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnCustom:(id)sender {
    PrescriptionDetailController *pdc = [[[PrescriptionDetailController alloc] initWithNibName:@"PrescriptionDetailController" bundle:nil] autorelease];
    pdc.pdcDelegate = self;
    pdc.idrItem = self.idrItem;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    IDRDose *dose = [self.idrItem.action.doses objectAtIndex:[indexPath row]];
    pdc.idrDoseText = dose.content;
    [self.navigationController pushViewController:pdc animated:YES];
}

- (void)takeDoseName:(NSString *)doseName extendedDoseName:(NSString *)extendedDoseName {
    self.doseName = doseName;
    self.extendedDoseName = extendedDoseName;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.idrItem.action.doses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.textLabel.textAlignment = UITextAlignmentLeft;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:18.0];
    }

    IDRDose *dose = [self.idrItem.action.doses objectAtIndex:[indexPath row]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", dose.name, dose.content];
    
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
    IDRDose *dose = [self.idrItem.action.doses objectAtIndex:[indexPath row]];
    self.doseName = dose.name;
    self.extendedDoseName = dose.content;
    [self updateEnables];
}


@end
