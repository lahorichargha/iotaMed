//
//  IssueItemSelectViewController.m
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/18/11.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "IssueItemSelectViewController.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRSelect.h"


static CGFloat kTableViewRowHeight = 40.0;

@implementation IssueItemSelectViewController

@synthesize idrItem = _idrItem;
@synthesize lastIndexPath = _lastIndexPath;
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
    [_lastIndexPath release];
    [_delegate release];

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setIdrItem:nil];
    [self setLastIndexPath:nil];
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
    return [self.idrItem.observation.selects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSInteger row = [indexPath row];
    IDRSelect *select = [self.idrItem.observation.selects objectAtIndex:row];
    
    UIFont *newFont = [UIFont boldSystemFontOfSize:17];
    cell.textLabel.font = newFont;
    cell.textLabel.text = [NSString stringWithFormat:@"%@", select.content];

    NSInteger oldRow = [self.lastIndexPath row];
    
    cell.accessoryType = (row == oldRow && self.lastIndexPath != nil) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    if (self.lastIndexPath == nil && row == 0) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } 
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTableViewRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger newRow = [indexPath row];
    NSInteger oldRow = (self.lastIndexPath != nil) ? [self.lastIndexPath row] : -1;
    if (newRow != oldRow) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        self.lastIndexPath = indexPath;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IDRSelect *select = [self.idrItem.observation.selects objectAtIndex:[self.lastIndexPath row]];
    NSString *text = [NSString stringWithFormat:@"%@", select.content];
    if ([self.delegate conformsToProtocol:@protocol(IssueItemSelectViewDelegate)]) {
        [self.delegate shouldChangeSelectLable:text];
    }
}

@end
