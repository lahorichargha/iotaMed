//
//  EhrViewController.m
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

#import "EhrViewController.h"
#import "IotaContext.h"
#import "PatientContext.h"
#import "Patient.h"
#import "SysTeamNPO.h"
#import "Xml2IotaDom.h"
#import "IotaDOMElement.h"
#import "Funcs.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface EhrViewController()
@property (nonatomic, retain) SysTeamNPO *sNpo;
@property (nonatomic, retain) NSMutableArray *diagnoser;
@end


// -----------------------------------------------------------

@implementation EhrViewController

// -----------------------------------------------------------
#pragma mark -
#pragma mark Properties
// -----------------------------------------------------------

@synthesize activityIndicator = _activityIndicator;
@synthesize sNpo = _sNpo;
@synthesize diagnoser = _diagnoser;
@synthesize tableView = _tableView;

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
    self.activityIndicator = nil;
    self.sNpo = nil;
    self.diagnoser = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark talking to Cross
// -----------------------------------------------------------

- (void)getNPOData {
    self.diagnoser = nil;
    [self.tableView reloadData];
    
    Patient *pat = [IotaContext getCurrentPatient];
    if (pat == nil)
        return;
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    self.sNpo = [[[SysTeamNPO alloc] init] autorelease];
    self.sNpo.patientId = pat.patientID;
    self.sNpo.fromDate = [dateFormatterDate() dateFromString:@"2001-01-01"];
    self.sNpo.toDate = [dateFormatterDate() dateFromString:@"2011-11-11"];
    self.sNpo.serverIp = [IotaContext crossServerIPNumber];
    [self.sNpo deliverDiagnosesToTarget:self action:@selector(diagnoses:)];
}

- (void)diagnoses:(NSString *)result {
    [result retain];
//    NSLog(@"Hey, got a call!");
//    NSLog(@"---%@", result);
    
    Xml2IotaDom *x2id = [[Xml2IotaDom alloc] initWithString:result];
    [x2id parse];
    IotaDOMElement *document = [x2id document];
    [result release];
    
    self.diagnoser = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    NSArray *diagnoseNodes = [document elementsInPathString:@"*/diagnos"];
    for (IotaDOMElement *element in diagnoseNodes) {
        NSString *code = [[element elementInPathString:@"*/diagnoskod/kod"] content];
        NSString *codeTxt = [[element elementInPathString:@"*/diagnoskod/text"] content];
        NSString *dateTimeRaw = [[element elementInPathString:@"*/registreringstidpunkt"] content];
        NSString *dateTime = [dateFormatter() stringFromDate:[dateFormatterTypeT() dateFromString:dateTimeRaw]];
        NSString *diagnosDesc = [NSString stringWithFormat:@"%@   -   %@ %@", dateTime, code, codeTxt];
        [self.diagnoser addObject:diagnosDesc];
    }
    
    [x2id release];
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    [self.tableView reloadData];
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark View lifecycle
// -----------------------------------------------------------

// all these methods are in the superclass DetailViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNPOData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.diagnoser count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.backgroundView.frame = CGRectMake(0, 0, 768, 100);
        UIImage *bgImage = [UIImage imageNamed:@"b1.png"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:bgImage] autorelease];
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(50, 0, 600, 28)] autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 1001;
        [cell.contentView addSubview:label];
    }
    
    NSString *diagnosTxt = [self.diagnoser objectAtIndex:[indexPath row]];
    UILabel *v = (UILabel *)[cell.contentView viewWithTag:1001];
    v.text = diagnosTxt;    
    return cell;
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat tvWidth     = tableView.frame.size.width;
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tvWidth, 100)];
    view.image = [UIImage imageNamed:@"b3.png"];
    UILabel *lbl = [[[UILabel alloc] initWithFrame:CGRectMake(50, 20, 600, 60)] autorelease];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont boldSystemFontOfSize:28.0];
    lbl.text = @"Diagnoser:";
    [view addSubview:lbl];
    return [view autorelease];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGFloat tvWidth     = tableView.frame.size.width;
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tvWidth, 100)];
    view.image = [UIImage imageNamed:@"b2b.png"];
    return [view autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 100.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50.0;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Notifications
// -----------------------------------------------------------

- (void)didSwitchToPatient:(Patient *)newPatient {
    [super didSwitchToPatient:newPatient];
    [self getNPOData];
}

@end
