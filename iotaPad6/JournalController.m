//
//  JournalController.m
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

#import "JournalController.h"
#import "IotaContext.h"
#import "PatientContext.h"
#import "IDRBlock.h"
#import "IDRItem.h"
#import "ItemCellJournal.h"
#import "IotaContext.h"
#import "PatientContext.h"
#import "IDRContact.h"
#import "IDRObsDefinition.h"
#import "IDRObservation.h"
#import "IDRValue.h"
#import "Notifications.h"
#import "ObservationCell.h"
#import "IDRWorksheet.h"
#import "ContactSelectOrCreateForm.h"
#import "ValueLookupForm.h"
#import "UIView+iotaExtensions.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface JournalController ()
@property (nonatomic, retain) NSMutableArray *jBlocks;
@end


// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation JournalController

@synthesize tableView = _tableView;
@synthesize btnContact = _btnContact;
@synthesize contact = _contact;
@synthesize fullFrame;
@synthesize jBlocks = _jBlocks;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.tableView = nil;
    self.btnContact = nil;
    self.contact = nil;
    self.jBlocks = nil;
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

- (void)reload {
    PatientContext *pCtx = [IotaContext getCurrentPatientContext];
    self.contact = pCtx.currentContact;
    self.btnContact.title = (self.contact) ? [self.contact contactAsHeader] : @"<Inga kontakter>";
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactListChangedNotification:) 
                                            name:kContactListChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(obsDataChangedNotification:) 
                                                 name:kObservationDataChangedNotification object:nil];
    [self reload];
    self.fullFrame = self.tableView.frame;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    self.jBlocks = nil;
    [super viewWillAppear:animated];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Notification handlers
// -----------------------------------------------------------

- (void)contactListChangedNotification:(NSNotification *)notification {
    self.jBlocks = nil;
    [self reload];
}

- (void)obsDataChangedNotification:(NSNotification *)notification {
    self.jBlocks = nil;
    [self reload];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Action handlers
// -----------------------------------------------------------

- (void)btnContact:(id)sender {
    ContactSelectOrCreateForm *cscf = [[ContactSelectOrCreateForm alloc] initWithNibName:@"ContactSelectOrCreateForm" bundle:nil];
    
    cscf.modalPresentationStyle = UIModalPresentationFormSheet;
    cscf.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    cscf.target = self;
    cscf.action = @selector(afterContactForm:);
    
    [self presentModalViewController:cscf animated:YES];
    [cscf release];
}

- (void)afterContactForm:(NSNumber *)okOrCreate {
    if (![okOrCreate boolValue])
        return;
    self.jBlocks = nil;
    [self reload];
}

// this doesn't work anyway
- (IBAction)backgroundTap:(id)sender {
    //    [self.view findAndResignFirstResponder];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Item cell delegate
// -----------------------------------------------------------

- (void)presentValueLookupForm:(IDRItem *)item {
    ValueLookupForm *vlf = [[[ValueLookupForm alloc] initWithNibName:@"ValueLookupForm" bundle:nil] autorelease];
    vlf.idrItem = item;
    vlf.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vlf.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:vlf animated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSMutableArray *)getJournalBlocks {
    if (_jBlocks == nil) {
        _jBlocks = [[NSMutableArray alloc] initWithCapacity:5];
        for (IDRBlock *block in self.contact.idrBlocks) {
            if (block.worksheet == nil) {
                [_jBlocks addObject:block];
            } 
        }
        // create new blocks for the issue items
        for (IDRBlock *block in self.contact.idrBlocks) {
            if (block.worksheet != nil) {
                IDRBlock *jBlock = [[[IDRBlock alloc] init] autorelease];
                jBlock.title = [NSString stringWithFormat:@"%@ - %@", block.worksheet.title, block.title];
                for (IDRItem *item in block.items) {
                    if ([item hasInput] || [item hasValues]) {
                        [jBlock.items addObject:item];
                    }
                }
                if ([jBlock.items count] > 0)
                    [_jBlocks addObject:jBlock];
            }
        }
    }
    return self.jBlocks;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    IDRBlock *block = [[self getJournalBlocks] objectAtIndex:section];
    return [block.items count];
}

// -----------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *jBlocks = [self getJournalBlocks];
    IDRBlock *block = [jBlocks objectAtIndex:[indexPath section]];
    IDRItem *item = [block.items objectAtIndex:[indexPath row]];
    
    ItemCellJournal *cell = [ItemCellJournal cellForTableView:tableView idrItem:item];
    cell.itemCellDelegate = self;
    return cell;
}

// -----------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self getJournalBlocks] count];
}

// -----------------------------------------------------------

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 
    IDRBlock *block = [[self getJournalBlocks] objectAtIndex:section];
    return block.title;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    IDRBlock *block = [[self getJournalBlocks] objectAtIndex:[indexPath section]];
    IDRItem *item = [block.items objectAtIndex:[indexPath row]];
    return [ItemCellJournal cellHeightForTableView:tableView idrItem:item];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Detailview overrides
// -----------------------------------------------------------

- (void)didSwitchToPatient:(Patient *)newPatient {
    self.jBlocks = nil;
    [super didSwitchToPatient:newPatient];
    [self reload];
    self.btnContact.enabled = (newPatient != nil);
}

@end
