//
//  ItemSelectViewController.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-10-09.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemSelectViewController.h"

@interface ItemSelectViewController()
@property (nonatomic, retain) NSIndexPath *selectedIndex;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@end

@implementation ItemSelectViewController

@synthesize delegate = _delegate;
@synthesize btnKeyboard = _btnKeyboard;
@synthesize btnRecord = _btnRecord;
@synthesize selectedIndex = _selectedIndex;
@synthesize tableView = _tableView;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Sizing helper
// -----------------------------------------------------------

+ (CGSize)neededSizeForRows:(NSUInteger)rows {
    CGFloat width = 250.0;
    CGFloat height = 66.0 + 44.0 * fminf(rows, 10.0);
    return CGSizeMake(width, height);
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

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

- (void)dealloc {
    self.delegate = nil;
    self.selectedIndex = nil;
    [_btnKeyboard release];
    [_btnRecord release];
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View Lifecycle
// -----------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setBtnKeyboard:nil];
    [self setBtnRecord:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.delegate selectPrompts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    cell.textLabel.text = [[self.delegate selectPrompts] objectAtIndex:[indexPath row]];
    return cell;
}

// optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Actions
// -----------------------------------------------------------

- (IBAction)btnKeyboard:(id)sender {
    [self.delegate showKeyboard];
}

- (IBAction)btnRecord:(id)sender {
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndex == nil || [indexPath compare:self.selectedIndex] != NSOrderedSame) {
        if (self.selectedIndex != nil)
            [tableView cellForRowAtIndexPath:self.selectedIndex].accessoryType = UITableViewCellAccessoryNone;
        self.selectedIndex = indexPath;
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        NSArray *result = [NSArray arrayWithObject:[[self.delegate selectValues] objectAtIndex:[indexPath row]]];
        [self.delegate selectedValues:result];
    }
}

@end
