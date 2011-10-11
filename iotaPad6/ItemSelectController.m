//
//  ItemSelectController.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-10-06.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemSelectController.h"


@interface ItemSelectController()
@property (nonatomic, retain) NSArray *selectPrompts;
@property (nonatomic, retain) NSArray *selectValues;
@property (nonatomic, retain) NSIndexPath *selectedIndex;
@end

@implementation ItemSelectController

@synthesize delegate = _delegate;
@synthesize selectPrompts = _selectPrompts;
@synthesize selectValues = _selectValues;
@synthesize selectedIndex = _selectedIndex;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.selectPrompts = nil;
    self.selectValues = nil;
    self.selectedIndex = nil;
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

    self.selectPrompts = [self.delegate selectPrompts];
    self.selectValues = [self.delegate selectValues];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Table view data source
// -----------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.selectPrompts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [self.selectPrompts objectAtIndex:[indexPath row]];
    
    return cell;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Table view delegate
// -----------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndex == nil || [indexPath compare:self.selectedIndex] != NSOrderedSame) {
        if (self.selectedIndex != nil)
            [tableView cellForRowAtIndexPath:self.selectedIndex].accessoryType = UITableViewCellAccessoryNone;
        self.selectedIndex = indexPath;
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        NSArray *result = [NSArray arrayWithObject:[self.selectValues objectAtIndex:[indexPath row]]];
        [self.delegate selectedValues:result];
    }
}

@end
