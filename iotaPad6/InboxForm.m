//
//  InboxForm.m
//  iotaPad6
//
//  Created by Martin on 2011-05-15.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "InboxForm.h"
#import "IotaContext.h"
//#import "PatientContext.h"
#import "MyIotaPatientContext.h"
#import "IDRContact.h"
#import "IDRBlock.h"
#import "IDRWorksheet.h"
#import "InboxMyIotaForm.h"

@interface InboxForm() 

- (void)_loadMyIotaIssues;
@property (nonatomic, retain) NSMutableArray *myIotaIssues;
@end


@implementation InboxForm

@synthesize tableView = _tableView;
@synthesize myIotaIssues = _myIotaIssues;

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
    self.myIotaIssues = nil;
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
    [self _loadMyIotaIssues];
    self.navigationItem.title = @"Inkorg";
    UIBarButtonItem *bbiCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                               target:self action:@selector(btnCancel:)];
    self.navigationItem.leftBarButtonItem = bbiCancel;
    [bbiCancel release];
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
#pragma mark Data management functions
// -----------------------------------------------------------

- (void)_loadMyIotaIssues {
    self.myIotaIssues = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    MyIotaPatientContext *miCtx = [IotaContext getCurrentMyIotaContext];
    for (IDRBlock *block in miCtx.blocks) {
        [self.myIotaIssues addObject:block];
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Actions
// -----------------------------------------------------------

- (void)btnCancel:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.myIotaIssues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
    }
    
    IDRBlock *block = [self.myIotaIssues objectAtIndex:[indexPath row]];
    cell.textLabel.text = block.title;
    cell.detailTextLabel.text = block.worksheet.title;

    return cell;
}

// optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"minIota återkoppling";
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxMyIotaForm *ibmif = [[[InboxMyIotaForm alloc] initWithNibName:@"InboxMyIotaForm" bundle:nil] autorelease];
    ibmif.block = [self.myIotaIssues objectAtIndex:[indexPath row]];
    ibmif.miContext = [IotaContext getCurrentMyIotaContext];
    [self.navigationController pushViewController:ibmif animated:YES];
}



@end
