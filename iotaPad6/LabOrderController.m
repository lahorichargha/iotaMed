//
//  LabOrderController.m
//  iotaPad6
//
//  Copyright © 2011, MITM AB, Sweden
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1.  Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//  2.  Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//  3.  Neither the name of MITM AB nor the name iotaMed®, nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY MITM AB ‘’AS IS’’ AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MITM AB BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "LabOrderController.h"
#import "IDRItem.h"
#import "IDRAction.h"
#import "IDRTest.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation LabOrderController

@synthesize idrItem = _idrItem;
@synthesize tableView = _tableView;
@synthesize labOrderControllerDelegate = _labOrderControllerDelegate;
@synthesize lblOrder = _lblOrder;
@synthesize btnCancel = _btnCancel;
@synthesize btnSend = _btnSend;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.tableView = nil;
    self.idrItem = nil;
    self.labOrderControllerDelegate = nil;
    [_lblOrder release];
    [_btnCancel release];
    [_btnSend release];
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
    // set the tests all to selected by default
    self.lblOrder.text = NSLocalizedString(@"Order lab tests", @"Lab order prompt");

    [self.btnCancel setTitle:NSLocalizedString(@"Cancel", @"Cancel button label") forState:UIControlStateNormal];
    [self.btnSend setTitle:NSLocalizedString(@"Send", @"Send button") forState:UIControlStateNormal];
    for (IDRTest *test in self.idrItem.action.tests) {
        test.selected = YES;
    }
}

- (void)viewDidUnload {
    [self setLblOrder:nil];
    [self setBtnCancel:nil];
    [self setBtnSend:nil];
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
#pragma mark Button actions
// -----------------------------------------------------------

- (IBAction)btnOk:(id)sender {
    [self.labOrderControllerDelegate sentLabOrderForItem:self.idrItem];
    [self.idrItem setItemValue:NSLocalizedString(@"Sent", @"Sent")];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.idrItem.action.tests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    // configure the cell here
    
    IDRTest *test = [self.idrItem.action.tests objectAtIndex:[indexPath row]];
    cell.textLabel.text = test.name;
    cell.accessoryType = (test.selected) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
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
    IDRTest *test = [self.idrItem.action.tests objectAtIndex:[indexPath row]];
    test.selected = !test.selected;
    [self.tableView reloadData];
}


@end
