//
//  IssueTemplatesMasterViewController.m
//  iotaPad6
//
//  Created by Martin on 2011-02-22.
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

#import "IssueTemplatesMasterViewController.h"
#import "IssueTemplateDB.h"
#import "IssueTemplateDescriptor.h"
#import "IssueTemplateFormViewController.h"
#import "Funcs.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface  IssueTemplatesMasterViewController ()

@property (nonatomic, retain) NSArray *templates;

- (void)setupAllPointerArrays;

@end


@implementation IssueTemplatesMasterViewController

@synthesize tableView = _tableView;
@synthesize templates = _templates;

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
    for (int i = 0; i < MAXINDEX; i++) {
        NSString *s = sectionPrefix[i];
        [s release];
    }
    self.templates = nil;
    self.tableView = nil;
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
    [self setupAllPointerArrays];
    self.navigationItem.titleView = navBarLabelWithText(@"Mallar (Issues)");
    self.navigationItem.title = @"Mallar";
    UIBarButtonItem *bbiCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnCancel:)];
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

- (void)btnCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Row access handlers
// -----------------------------------------------------------

- (void)setupAllPointerArrays {
    // we assume the templates are already in alphabetical order
    unsigned int currentCount = 0;
    NSString *oldPrefix = [((IssueTemplateDescriptor *)[self.templates objectAtIndex:0]).title substringToIndex:1];
    sectionPrefix[0] = [oldPrefix retain];
    
    unsigned int currentSection = 0;
    sectionStart[currentSection] = 0;
    for (IssueTemplateDescriptor *itd in self.templates) {
        NSString *prefix = [itd.title substringToIndex:1];
        if (![oldPrefix isEqualToString:prefix]) {
            // new section starts
            currentSection++;
            if (currentSection >= MAXINDEX)
                [NSException raise:@"Internal overflow" format:@"Too many sections in list of templates"];
            sectionStart[currentSection] = currentCount;
            oldPrefix = prefix;
            sectionPrefix[currentSection] = [prefix retain];;
        }
        sectionRowCount[currentSection]++;
        currentCount++;
    }
    nbOfSections = currentSection + 1;
}

- (IssueTemplateDescriptor *)templateDescriptorAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger realRow = sectionStart[[indexPath section]] + [indexPath row];
    return [self.templates objectAtIndex:realRow];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Table view delegate
// -----------------------------------------------------------

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Accessory button tapped!");
    
    IssueTemplateFormViewController *itfvc = [[[IssueTemplateFormViewController alloc] 
                                               initWithNibName:@"IssueTemplateFormViewController" bundle:nil] autorelease];
    IssueTemplateDescriptor *itd = [self templateDescriptorAtIndexPath:indexPath];
    itfvc.issueTemplateDescriptor = itd;
    [self.navigationController pushViewController:itfvc animated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Table view datasource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sectionRowCount[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSUInteger realRow = sectionStart[section] + row;
    
    IssueTemplateDescriptor *itd = [self.templates objectAtIndex:realRow];
    
    cell.textLabel.text = itd.title;
    if ([itd.resourceName length] > 0)
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {    
    return nbOfSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *prefix = sectionPrefix[section];
    return prefix;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [NSArray arrayWithObjects:sectionPrefix count:nbOfSections];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------

- (NSArray *)templates {
    if (_templates == nil) {
        _templates = [[IssueTemplateDB allTemplateDescriptors] retain];
    }
    return _templates;
}



@end
