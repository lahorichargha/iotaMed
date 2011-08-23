//
//  ContactCreationForm.m
//  iotaPad6
//
//  Created by Martin on 2011-03-12.
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

#import "ContactCreationForm.h"
#import "IDRContact.h"
#import "IotaContext.h"
#import "PatientContext.h"
#import "IDRObservation.h"
#import "IDRObsDefinition.h"
#import "IDRWorksheet.h"
#import "IDRBlock.h"
#import "IDRItem.h"
#import "XML2IDR.h"
#import "Notifications.h"
#import "Funcs.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface ContactCreationForm ()

@property (nonatomic, retain) IDRWorksheet *keywordTemplate;
//@property (nonatomic, retain) NSArray *templates;
@property (nonatomic, retain) NSMutableArray *selections;

@end



// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation ContactCreationForm

@synthesize keywordTemplate = _keywordTemplate;
@synthesize datePicker = _datePicker;
@synthesize timePicker = _timePicker;
@synthesize tableView = _tableView;
@synthesize target = _target;
@synthesize action = _action;
@synthesize selections = _selections;

@synthesize lblNewContact = _lblNewContact;
@synthesize btnOk = _btnOk;
@synthesize btnCancel = _btnCancel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.keywordTemplate = nil;
    self.datePicker = nil;
    self.timePicker = nil;
    self.tableView = nil;
    self.action = nil;
    self.target = nil;
    self.selections = nil;
    self.lblNewContact = nil;
    self.btnOk = nil;
    self.btnCancel = nil;
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
    // Do any additional setup after loading the view from its nib.
    self.datePicker.date = [NSDate date];
    self.timePicker.date = [NSDate date];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.timePicker.datePickerMode = UIDatePickerModeTime;

    self.lblNewContact.text = NSLocalizedString(@"New contact", @"New contact label");
    [self.btnOk setTitle:NSLocalizedString(@"Ok", @"Ok label for button") forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"Cancel", @"Cancel label for button") forState:UIControlStateNormal];
    
    self.keywordTemplate = [XML2IDR worksheetFromFileName:@"keywordtemplates"];

    _selections = [[NSMutableArray alloc] initWithCapacity:[self.keywordTemplate.blocks count]];
    
    for (int i = 0; i < [self.keywordTemplate.blocks count]; i++) {
        IDRBlock *block = [self.keywordTemplate.blocks objectAtIndex:i];
        if (block.blockType == eBlockTypeDefault) {
            [self.selections addObject:[NSNumber numberWithBool:YES]];
        }
        else {
            [self.selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
#pragma mark Actions
// -----------------------------------------------------------

- (NSArray *)chosenObservations {
    NSMutableArray *result = [[[NSMutableArray alloc] initWithCapacity:25] autorelease];
    for (int i = 0; i < [self.selections count]; i++) {
        NSNumber *number = [self.selections objectAtIndex:i];
        if ([number boolValue]) {
            IDRBlock *block = [self.keywordTemplate.blocks objectAtIndex:i];
            for (IDRItem *item in block.items) {
                [result addObject:item];
            }
        }
    }
    return result;
}

- (IBAction)btnOk:(id)sender {
    // what has to be done, is:
    //      create a new contact
    //      create a new journal
    //      add in selected observations into that journal
    //      call the parent action with the new journal as parameter
    
    IDRContact *contact = [[[IDRContact alloc] init] autorelease];
    
    NSDate *datePart = self.datePicker.date;
    NSDate *timePart = self.timePicker.date;
    contact.date = combineDateAndTime(datePart, timePart);
    
    contact.nameOfDoctor = [IotaContext nameOfCurrentUser];
    
    [[IotaContext getCurrentPatientContext] addContactAndMakeCurrent:contact];

    for (int i = 0; i < [self.keywordTemplate.blocks count]; i++) {
        if ([[self.selections objectAtIndex:i] boolValue] == YES) {
            IDRBlock *block = [self.keywordTemplate.blocks objectAtIndex:i];
            block.contact = contact;
            block.worksheet = nil;  // very important, but probably superfluous
            [contact addBlock:block];
        }
    }
    
    [self dismissModalViewControllerAnimated:YES];
    [self.target performSelector:self.action withObject:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kContactListChangedNotification object:nil];
}

- (IBAction)btnCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.keywordTemplate.blocks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    IDRBlock *block = [self.keywordTemplate.blocks objectAtIndex:[indexPath row]];
    cell.textLabel.text = block.title;
    
    BOOL selected = [((NSNumber *)[self.selections objectAtIndex:[indexPath row]]) boolValue];
    cell.accessoryType = (selected) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

// optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *number = [self.selections objectAtIndex:[indexPath row]];
    [self.selections replaceObjectAtIndex:[indexPath row] withObject:[NSNumber numberWithBool:([number boolValue]) ? NO : YES]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadData];
}



@end
