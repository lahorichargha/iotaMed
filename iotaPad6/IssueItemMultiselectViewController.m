//
//  IssueItemMultiselectViewController.m
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/23/11.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IssueItemMultiselectViewController.h"
#import "IssueWorksheetController.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRMultiselect.h"


static CGFloat kTableViewRowHeight = 40.0;

@implementation IssueItemMultiselectViewController

@synthesize idrItem = _idrItem;
@synthesize okButtonItem = _okButtonItem;
@synthesize clearButtonItem = _clearButtonItem;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [_idrItem release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Välj", @"");
    
    // Create a buttons item
    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    self.okButtonItem = okButton;
    [okButton release];
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Avbryt" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissAction:)];
    self.clearButtonItem = clearButton;
    [clearButton release];
    
    self.navigationItem.leftBarButtonItem = self.clearButtonItem;
    self.navigationItem.rightBarButtonItem = self.okButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setIdrItem:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.idrItem.observation.multiselects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSInteger row = [indexPath row];
    IDRMultiselect *multiselect = [self.idrItem.observation.multiselects objectAtIndex:row];
    
    UIFont *newFont = [UIFont boldSystemFontOfSize:17];
    cell.textLabel.font = newFont;
    cell.textLabel.text = [NSString stringWithFormat:@"%@", multiselect.content];
    
//    NSInteger oldRow = [self.lastIndexPath row];
//    
//    cell.accessoryType = (row == oldRow && self.lastIndexPath != nil) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
//    
//    if (self.lastIndexPath == nil && row == 0) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    } 
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTableViewRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger newRow = [indexPath row];
//    NSInteger oldRow = (self.lastIndexPath != nil) ? [self.lastIndexPath row] : -1;
//    if (newRow != oldRow) {
//        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
//        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
//        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.lastIndexPath];
//        oldCell.accessoryType = UITableViewCellAccessoryNone;
//        self.lastIndexPath = indexPath;
//    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    IDRMultiselect *multiselect = [self.idrItem.observation.multiselects objectAtIndex:[self.lastIndexPath row]];
//    NSString *text = [NSString stringWithFormat:@"%@", select.content];
//    [self.itemSelectDelegate changeSelectLable:text];
}

#pragma mark - Bar buttons actions

- (IBAction)doneAction:(id)sender {
    [self.delegate changeMultiselectLable:self.idrItem];
}

- (IBAction)dismissAction:(id)sender {
    [self.delegate dismissPopoverForMultiselect];
}

@end
