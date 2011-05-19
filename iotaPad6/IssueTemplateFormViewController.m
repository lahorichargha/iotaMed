//
//  IssueTemplateFormViewController.m
//  iotaPad6
//
//  Created by Martin on 2011-02-21.
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

#import "IssueTemplateFormViewController.h"
#import "IssueTemplateDescriptor.h"
#import "IDRWorksheet.h"
#import "IDRBlock.h"
#import "IssueTemplateBlockViewController.h"
#import "Funcs.h"
#import "IDRDescription.h"
#import "NSString+iotaAdditions.h"

@implementation IssueTemplateFormViewController

@synthesize tableView = _tableView;
@synthesize issueTemplateDescriptor = _itd;

// outlets
@synthesize lblTitle = _lblTitle;
@synthesize lblFromICD10 = _lblFromICD10;
@synthesize lblToICD10 = _lblToICD10;
@synthesize lblDescription = _lblDescription;

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
    self.issueTemplateDescriptor = nil;
    self.lblTitle = nil;
    self.lblFromICD10 = nil;
    self.lblToICD10 = nil;
    self.lblDescription = nil;
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
    //    IssueTemplateDescriptor *itd = self.issueTemplateDescriptor;
    self.navigationItem.title = [NSString stringWithFormat:@"Mall %@", self.issueTemplateDescriptor.title];
    self.navigationItem.titleView = navBarLabelWithText([NSString stringWithFormat:@"Mall för %@", self.issueTemplateDescriptor.title]);
    self.lblTitle.text = self.issueTemplateDescriptor.title;
    self.lblFromICD10.text = self.issueTemplateDescriptor.fromICD10;
    self.lblToICD10.text = self.issueTemplateDescriptor.toICD10;
    self.lblDescription.text = [self.issueTemplateDescriptor.worksheet.description.content iotaNormalize];
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
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    [self.issueTemplateDescriptor.worksheet dumpWithIndent:4];
//    NSLog(@"block count: %d", self.issueTemplateDescriptor.worksheet.blockCount);
    return self.issueTemplateDescriptor.worksheet.blockCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    NSUInteger row = [indexPath row];
    
    IDRBlock *block = [self.issueTemplateDescriptor.worksheet blockAtIndex:row];
    
    cell.textLabel.text = block.title;
    return cell;
}

// optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.issueTemplateDescriptor.title;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    IDRBlock *selectedBlock = [self.issueTemplateDescriptor.worksheet blockAtIndex:[indexPath row]];
    IssueTemplateBlockViewController *itpvc = [[[IssueTemplateBlockViewController alloc] initWithNibName:@"IssueTemplateBlockViewController" bundle:nil] autorelease];
    itpvc.idrWorksheet = self.issueTemplateDescriptor.worksheet;
    itpvc.idrBlock = selectedBlock;
    [self.navigationController pushViewController:itpvc animated:YES];
    
//    IssueTemplateFormViewController *itfvc = [[[IssueTemplateFormViewController alloc] initWithNibName:@"IssueTemplateFormViewController" bundle:nil] autorelease];
//    IssueTemplateDescriptor *itd = [self templateDescriptorAtIndexPath:indexPath];
//    itfvc.issueTemplateDescriptor = itd;
//    [self.navigationController pushViewController:itfvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


@end
