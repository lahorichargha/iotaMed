//
//  InboxMyIotaForm.m
//  iotaPad6
//
//  Created by Martin on 2011-05-15.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "InboxMyIotaForm.h"
#import "IDRBlock.h"
#import "IDRWorksheet.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRObsDefinition.h"
#import "IDRValue.h"
#import "MyIotaPatientContext.h"
#import "PatientContext.h"
#import "IotaContext.h"

@interface InboxMyIotaForm()

- (void)_loadArrays;

@property (nonatomic, retain) NSMutableArray *items;

@end

@implementation InboxMyIotaForm

@synthesize tableView = _tableView;
@synthesize block = _block;
@synthesize items = _items;
@synthesize miContext = _miContext;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Object lifecycle
// -----------------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.tableView = nil;
    self.block = nil;
    self.items = nil;
    self.miContext = nil;
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
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@: %@", self.block.worksheet.title, self.block.title];
    [self _loadArrays];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Importera" 
                                                                               style:UIBarButtonItemStylePlain 
                                                                              target:self 
                                                                              action:@selector(importButton:)] autorelease];
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

- (IBAction)importButton:(id)sender {
    PatientContext *pCtx = [IotaContext getCurrentPatientContext];
    [pCtx addBlockAndValuesToCurrentContact:self.block];
    [self dismissModalViewControllerAnimated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Data management
// -----------------------------------------------------------

- (void)_loadArrays {
    self.items = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    for (IDRItem *item in self.block.items) {
        if ([item hasInput]) {
            [self.items addObject:item];
        }
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
    }
    
    // configure the cell here

    IDRItem *item = [self.items objectAtIndex:[indexPath row]];
    //IDRValue *value = [self.miContext getCurrentValueForObsName:item.observation.name];
    NSArray *values = [self.miContext getAllValuesForObsName:item.observation.name];
    if (values && [values count] > 0) {
        IDRValue *val = [values objectAtIndex:0];
        if ([item.observation.type isEqualToString:@"check"]) {
            cell.detailTextLabel.text = ([val.value isEqualToString:@"yes"]) ? @"Ja" : @"Nej";
        }
        else {
            cell.detailTextLabel.text = val.value;
        }
    }
    else {
        cell.detailTextLabel.text = @"<inget>";
    }
    //    cell.detailTextLabel.text = value.value;
    
    cell.textLabel.text = item.content;
    
    return cell;
}

// optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


@end
