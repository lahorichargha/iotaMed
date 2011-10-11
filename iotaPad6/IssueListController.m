//
//  IssueListController.m
//  iotaPad6
//
//  Created by Martin on 2011-02-11.
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

#import "IssueListController.h"
#import "IotaContext.h"
#import "Patient.h"
#import "PatientContext.h"
#import "IDRWorksheet.h"
#import "IDRBlock.h"
#import "Notifications.h"
#import "IDRContact.h"
#import "IssueWorksheetController.h"
#import "Version.h"
#import "IssueTemplatesMasterViewController.h"
#import "InboxForm.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface IssueListController ()

@property (nonatomic, retain) UIBarButtonItem *popoverButton;
@property (nonatomic, retain) UIPopoverController *activePopover;
@property (nonatomic, retain) UIBarButtonItem *myIotaButton;

- (void)registerForNotifications;
- (void)unregisterForNotifications;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Properties
// -----------------------------------------------------------

@implementation IssueListController

@synthesize popoverButton = _popoverButton;
@synthesize myIotaButton = _myIotaButton;

// the following two are parallel arrays
@synthesize worksheets = _worksheets;
@synthesize arrayOfBlockLists = _arrayOfBlockLists;

//@synthesize issueList = _issueList;
@synthesize wsController = _wsController;
@synthesize tabBarController = _tabBarController;
@synthesize activePopover = _activePopover;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Object lifecycle
// -----------------------------------------------------------

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
        
    }
    return self;
}

- (void)dealloc {
    self.worksheets = nil;
    self.arrayOfBlockLists = nil;
    self.popoverButton = nil;
    self.wsController = nil;
    self.tabBarController = nil;
    self.activePopover = nil;
    self.myIotaButton = nil;
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

- (void)loadArrays {
    PatientContext *pCtx = [IotaContext getCurrentPatientContext];
    self.worksheets = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
    self.arrayOfBlockLists = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
    
    for (IDRContact *contact in pCtx.contacts) {
        for (IDRBlock *block in contact.idrBlocks) {
            IDRWorksheet *worksheet = block.worksheet;
            if (worksheet != nil) {
                NSUInteger index = [self.worksheets indexOfObject:worksheet];
                NSMutableArray *blocks = nil;
                if (index == NSNotFound) {
                    [self.worksheets addObject:worksheet];
                    blocks = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
                    [self.arrayOfBlockLists addObject:blocks];
                }
                else {
                    blocks = [self.arrayOfBlockLists objectAtIndex:index];
                }
                [blocks addObject:block];
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadArrays];
    
    UILabel *newTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    newTitle.text = NSLocalizedString(@"Issues", @"Title for issue list and popover");
    newTitle.backgroundColor = [UIColor clearColor];
    newTitle.textColor = [UIColor whiteColor];
    UIFont *newFont = [UIFont fontWithName:@"Helvetica" size:20];
    newTitle.font = newFont;
    self.navigationItem.titleView = newTitle;
    [newTitle release];
    
    UIBarButtonItem *bbiAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addIssue:)];
    self.navigationItem.rightBarButtonItem = bbiAdd;
    [bbiAdd release];

    UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 600) style:UITableViewStyleGrouped];
    self.tableView = aTableView;
    [aTableView release];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background2.png"]];
    self.tableView.backgroundView = image;
    [image release];
    
    [IotaContext addObserver:self];
    [self registerForNotifications];
    
    UILabel *versionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(8, 10, 100, 20)] autorelease];
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.font = [UIFont fontWithName:@"Palatino" size:14.0];
    versionLabel.textColor = [UIColor grayColor];
//    NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    //    versionLabel.text = [NSString stringWithFormat:@"%@(%@)", kVersion, bundleVersion];
    //    versionLabel.text = kVersion;
    [self.navigationController.view addSubview:versionLabel];
    
    
#ifndef SYSteam
    UITabBarItem *tbiCross = [[self.tabBarController.tabBar items] objectAtIndex:2];
    tbiCross.image = [UIImage imageNamed:@"diagnoser.png"];
    tbiCross.title = @"Diagnoser";
#endif
}

- (void)viewDidUnload {
    [self unregisterForNotifications];
    [IotaContext removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadArrays];
    [self.tableView reloadData];
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
    // makes sure the issue list uses our own background in the navbar
    [self.navigationController.navigationBar setNeedsDisplay];
    // Return YES for supported orientations
	return YES;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark List manipulation
// -----------------------------------------------------------


- (NSIndexPath *)indexPathOfBlock:(IDRBlock *)block {
    for (NSUInteger section = 0; section < [self.worksheets count]; section++) {
        NSArray *blocks = [self.arrayOfBlockLists objectAtIndex:section];
        NSUInteger row = [blocks indexOfObject:block];
        if (row != NSNotFound) {
            return [NSIndexPath indexPathForRow:row inSection:section];
        }
    }
    return nil;
}

- (void)selectBlock:(IDRBlock *)block {
    NSIndexPath *indexPath = [self indexPathOfBlock:block];
    if (indexPath != nil) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self didSelectRowAtIndexPath:indexPath];
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Notifications
// -----------------------------------------------------------

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationIssueListChanged:) 
                                                 name:kIssueListChangedNotification object:nil];
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kIssueListChangedNotification object:nil];
}

- (void)notificationIssueListChanged:(NSNotification *)notification {
    IDRBlock *addedBlock = [[notification userInfo] objectForKey:kIssueListChangedNotificationBlockKey];
    [self loadArrays];
    [self.tableView reloadData];
    if (addedBlock != nil)
        [self selectBlock:addedBlock];
    // if some patient data is returned, we need to add a button for that
    if ([IotaContext getCurrentMyIotaContext] != nil) {
        UIImage *inboxImage = [UIImage imageNamed:@"inkorg.png"];
        self.myIotaButton = [[[UIBarButtonItem alloc] initWithImage:inboxImage
                                                              style:UIBarButtonItemStylePlain 
                                                             target:self 
                                                             action:@selector(myIotaButton:)]
                                                            autorelease];
        self.navigationItem.leftBarButtonItem = self.myIotaButton;
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Editing mode
// -----------------------------------------------------------

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Issue list
// -----------------------------------------------------------

- (IDRWorksheet *)worksheetAtIndex:(NSIndexPath *)indexPath {
    return [self.worksheets objectAtIndex:[indexPath section]];
}

- (IDRBlock *)blockAtIndex:(NSIndexPath *)indexPath {
    IDRBlock *ip = [[self.arrayOfBlockLists objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    return ip;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Actions
// -----------------------------------------------------------

- (void)myIotaButton:(id)sender {
    InboxForm *ibf = [[[InboxForm alloc] initWithNibName:@"InboxForm" bundle:nil] autorelease];
    UINavigationController *unc = [[[UINavigationController alloc] initWithRootViewController:ibf] autorelease];
    unc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    unc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:unc animated:YES];
}

- (void)addIssue:(id)sender {
    IssueTemplatesMasterViewController *itmvc = [[[IssueTemplatesMasterViewController alloc] 
                                                  initWithNibName:@"IssueTemplatesMasterViewController" bundle:nil] autorelease];
    UINavigationController *unc = [[[UINavigationController alloc] initWithRootViewController:itmvc] autorelease];
    unc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    unc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:unc animated:YES];
}

- (void)btnUndo:(id)sender {
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    
        IDRWorksheet *iws = [self worksheetAtIndex:indexPath];
        IDRBlock *ip = [self blockAtIndex:indexPath];
        

        [self.tableView beginUpdates];
        
        // the block will effectively disappear once this routine comes to an end, it's autoreleased
        if (![ip removeSelf])
            return;
        
        NSMutableArray *blocks = [self.arrayOfBlockLists objectAtIndex:[indexPath section]];
        [blocks removeObject:ip];
        if ([blocks count] < 1) {
            [self.worksheets removeObject:iws];
        }
        
         [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        
        // if the worksheet now has no blocks, it will delete itself once the autoreleased reference in this
        // routine is dropped, so all we need to do here is remove the section from the visible table
        if ([blocks count] < 1) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:YES];
        }
        [self.tableView endUpdates];
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark IotaContextDelegate
// -----------------------------------------------------------

- (BOOL)willSwitchFromPatient:(Patient *)oldPatient {
    return YES;
}

- (void)didSwitchToPatient:(Patient *)newPatient {
    [self loadArrays];
    [self.tableView reloadData];
    // if some patient data is returned, we should add a button to the title bar
    MyIotaPatientContext *miCtx = [IotaContext getCurrentMyIotaContext];
    if (miCtx != nil && [miCtx.blocks count] > 0) {
        UIImage *btn = [UIImage imageNamed:@"inkorg.png"];
        self.myIotaButton = [[[UIBarButtonItem alloc]
                              initWithImage:btn 
                              style:UIBarButtonItemStylePlain target:self
                              action:@selector(myIotaButton:)]
                             autorelease];
        
        /*        self.myIotaButton = [[[UIBarButtonItem alloc] 
         initWithBarButtonSystemItem:UIBarButtonSystemItemReply 
         target:self 
         action:@selector(myIotaButton:)] 
         autorelease];  */
        self.navigationItem.leftBarButtonItem = self.myIotaButton;
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Table view data source
// -----------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.worksheets count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.arrayOfBlockLists objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        UIImage *rowImage = [UIImage imageNamed:@"rowImage.png"];
        cell.imageView.image = rowImage;
    }

    IDRBlock *ip = [[self.arrayOfBlockLists objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    cell.textLabel.text = ip.title;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    IDRWorksheet *iws = [self.worksheets objectAtIndex:section];
    return iws.title;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Table view delegate
// -----------------------------------------------------------

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.wsController.idrBlock = [self blockAtIndex:indexPath];
    self.wsController.idrWorkSheet = [self worksheetAtIndex:indexPath];
    [self.wsController refresh];
    self.tabBarController.selectedIndex = 0;
    
    if (self.activePopover != nil)
        [self.activePopover dismissPopoverAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelectRowAtIndexPath:indexPath];
}

- (UIBarButtonItem *)popoverButtonItem {
    return self.popoverButton;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Split view controller delegate
// -----------------------------------------------------------

- (void)splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc {
    self.activePopover = pc;
    barButtonItem.title = NSLocalizedString(@"Issues", @"Title for the issue list and popover");
    NSDictionary *noteDic = [NSDictionary dictionaryWithObject:barButtonItem forKey:@"button"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showPopoverButton" object:self userInfo:noteDic];
    self.popoverButton = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    self.activePopover = nil;
    NSDictionary *noteDic = [NSDictionary dictionaryWithObject:barButtonItem forKey:@"button"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hidePopoverButton" object:self userInfo:noteDic];
    self.popoverButton = nil;
}


@end
