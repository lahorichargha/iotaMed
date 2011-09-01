//
//  IssueItemMultiselectViewController.m
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/23/11.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IssueItemMultiselectViewController.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRMultiselect.h"
#import "IDRObsDefinition.h"


static CGFloat kTableViewRowHeight = 40.0;

@implementation IssueItemMultiselectViewController

@synthesize idrItem = _idrItem;
@synthesize tempMultiselects = _tempMultiselects;
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
    [_tempMultiselects release];
    [_okButtonItem release];
    [_clearButtonItem release];
    [_tempMultiselects release];
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
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    self.tempMultiselects = dict;
    [dict release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setIdrItem:nil];
    [self setTempMultiselects:nil];
    [self setOkButtonItem:nil];
    [self setClearButtonItem:nil];
    [self setTempMultiselects:nil];
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
    cell.accessoryType = (multiselect.selected) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
  
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTableViewRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IDRMultiselect *multiselect = [self.idrItem.observation.multiselects objectAtIndex:[indexPath row]];

    multiselect.selected = !multiselect.selected;
    [self.tableView reloadData];
    
    [self.tempMultiselects setObject:multiselect forKey:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Bar buttons actions

- (IBAction)doneAction:(id)sender {
    if ([self.delegate conformsToProtocol:@protocol(IssueItemMultiselectViewDelegate)]) {
        [self.delegate shouldChangeMultiselectLable:self.idrItem];
    }
    [self.tempMultiselects removeAllObjects];
}

- (IBAction)dismissAction:(id)sender {
    [self.delegate dismissPopoverForMultiselect];
    
    NSEnumerator *enumerator = [self.tempMultiselects keyEnumerator];
    id key;
    
    while ((key = [enumerator nextObject])) {
        NSIndexPath *indexPath = (NSIndexPath *)key;
        IDRMultiselect *multiselect = [self.idrItem.observation.multiselects objectAtIndex:[indexPath row]];
        
        multiselect.selected = !multiselect.selected;
        [self.idrItem.observation.multiselects replaceObjectAtIndex:[indexPath row] withObject:multiselect];
    }
    [self.tableView reloadData];
    [self.tempMultiselects removeAllObjects];
}

@end
