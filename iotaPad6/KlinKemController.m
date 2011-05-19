//
//  KlinKemController.m
//  iotaPad6
//
//  Created by Martin on 2011-02-25.
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

#import "KlinKemController.h"
#import "SysTeamNPO.h"
#import "KlinKemGrafController.h"
#import "Xml2IotaDom.h"
#import "DemoData.h"
#import "IotaContext.h"
#import "Patient.h"
#import "Funcs.h"
#import "DemoData.h"
#import "UndersokningsResultat.h"
#import "AnalysTjanst.h"
#import "IotaDOMContent.h"
#import "IotaDOMElement.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface  KlinKemController ()
//@property (nonatomic, retain) NSArray *currentReports;
@property (nonatomic, retain) NSString *selectedAnalysisCode;
@property (nonatomic, retain) SysTeamNPO *sNpo;
@property (nonatomic, retain) NSMutableArray *results;

- (void)getNPOData;
@end

@implementation KlinKemController

@synthesize tableView = _tableView;
//@synthesize currentReports = _currentReports;
@synthesize selectedAnalysisCode = _selectedAnalysisCode;
@synthesize sNpo = _sNpo;
@synthesize results = _results;
@synthesize activityIndicator = _activityIndicator;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Load patient dependent data
// -----------------------------------------------------------

//- (void)loadForCurrentPatient {
//    Patient *currentPatient = [IotaContext getCurrentPatient];
//    if (currentPatient != nil) {
//        self.currentReports = [DemoKlinLabReports klinKemReportsForPatientId:currentPatient.patientID];
//        NSLog(@"Got %d reports on patient id: %@", [self.currentReports count], currentPatient.patientID);
//    }
//    else {
//        self.currentReports = nil;
//    }
//}

- (void)didSwitchToPatient:(Patient *)newPatient {
    [super didSwitchToPatient:newPatient];
    [self getNPOData];
//    [self loadForCurrentPatient];
    [self.tableView reloadData];
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

- (void)dealloc {
    self.tableView = nil;
//    self.currentReports = nil;
    self.selectedAnalysisCode = nil;
    self.sNpo = nil;
    self.results = nil;
    self.activityIndicator = nil;
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
    //self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backg3.png"]] autorelease];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
#pragma mark talking to Cross
// -----------------------------------------------------------

- (void)getNPOData {
    self.results = nil;
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
    [self.sNpo deliverChemistryToTarget:self action:@selector(chemistry:)];
}

// a file consists of a number of "undersokningsresultat", each of which is for a set of analyses,
// a particular datetime. You'll find the datetime under "svarsstidpunkt" (sic!)
// undersokningsresultat                                an entire section
// undersokningsresultat/svarsstidpunkt                 datetime of resultsheet (section)
// undersokningsresultat/svarstyp                       "Slutgiltigt svar" or similar
// undersokningsresultat/utford_analystjanst            one of more of these, one for each analysis
//   utford_analystjanst/atgardskod_text                the analysiscode as text
//   utford_analystjanst/utfall_resultat/varde          the actual result value
//   utford_analystjanst/utfall_resultat/varde_enhet    unit
//   utford_analystjanst/utfall_resultat/patologiskmarkerad     "False" or "True", signals if abnormal
//   utford_analystjanst/utfall_resultat/referensintervall      reference intervall


- (void)chemistry:(NSString *)result {
    [result retain];
//    NSLog(@"---%@", result);
    
    Xml2IotaDom *x2id = [[Xml2IotaDom alloc] initWithString:result];
    [x2id parse];
    IotaDOMElement *document = [x2id document];
    [result release];
    
    self.results = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    NSArray *resultNodes = [document elementsInPathString:@"*/undersokningsresultat"];
    for (IotaDOMElement *element in resultNodes) {
        UndersokningsResultat *ur = [[[UndersokningsResultat alloc] init] autorelease];
        [self.results addObject:ur];
        
        NSString *dtReg = [[element elementInPathString:@"*/registreringstidpunkt"] content];
        ur.registreringstidpunkt = strT2date(dtReg);
        
        NSString *dtSvar = [[element elementInPathString:@"*/svarsstidpunkt"] content];
        ur.svarsstidpunkt = strT2date(dtSvar);
        
        NSString *svarstyp = [[element elementInPathString:@"*/svarstyp"] content];
        ur.svarstyp = svarstyp;
        
        NSArray *utford = [element elementsInPathString:@"*/utford_analystjanst"];
        for (IotaDOMElement *utfElement in utford) {
            NSString *atgardskodtext = [[utfElement elementInPathString:@"*/atgardskod_text"] content];
            NSString *varde = [[utfElement elementInPathString:@"*/utfall_resultat/varde"] content];
            NSString *vardeEnhet = [[utfElement elementInPathString:@"*/utfall_resultat/varde_enhet"] content];
            NSString *strPatologisk = [[utfElement elementInPathString:@"*/utfall_resultat/patologiskmarkerad"] content];
            NSString *referensintervall = [[utfElement elementInPathString:@"*/utfall_resultat/referensintervall"] content];
            AnalysTjanst *anaT = [[[AnalysTjanst alloc] init] autorelease];
            anaT.atgardskodText = atgardskodtext;
            anaT.varde = varde;
            anaT.vardeEnhet = vardeEnhet;
            anaT.patologiskmarkerad = [strPatologisk isEqualToString:@"True"];
            anaT.referensintervall = referensintervall;
            [ur.analysTjanster addObject:anaT];
        }
    }
    
    [x2id release];
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    [self.tableView reloadData];
}



// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------


// -----------------------------------------------------------
#pragma mark -
#pragma mark Actions
// -----------------------------------------------------------


- (IBAction)btnGraph:(id)sender {
/*    if ([self.selectedAnalysisCode length] < 1)
        return;
    NSMutableArray *values = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
    NSMutableArray *dates = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
    NSString *unit;
    for (DemoKlinLabReport *report in self.currentReports) {
        for (DemoKlinLabResult *result in report.results) {
            NSString *anaCode = result.analysisCode;
            if ([self.selectedAnalysisCode isEqualToString:anaCode]) {
                unit = result.resultUnit;
                [dates addObject:report.samplesTaken];
                [values addObject:result.resultValue];
            }
        }
    }
    KlinKemGrafController *kkgc = [[[KlinKemGrafController alloc] initWithNibName:@"KlinKemGrafController" bundle:nil] autorelease];
    kkgc.analysisCode = self.selectedAnalysisCode;
    kkgc.axisValue = [DemoGraphAxisValue graphAxisValueForAnalysisCode:self.selectedAnalysisCode];
    kkgc.dates = dates;
    kkgc.values = values;
    kkgc.unit = unit;
    kkgc.modalPresentationStyle = UIModalPresentationPageSheet;
    kkgc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:kkgc animated:YES];
*/
}
 
// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    UndersokningsResultat *ur = [self.results objectAtIndex:section];
    return [ur.analysTjanster count];
}

- (UILabel *)makeLabelAtX:(CGFloat)x y:(CGFloat)y width:(CGFloat)w height:(CGFloat)h tag:(NSUInteger)tag {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
    //lbl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.tag = tag;
    return [lbl autorelease];
}

- (void)setLabelTextInCell:(UITableViewCell *)cell text:(NSString *)text tag:(NSUInteger)tag {
    UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:tag];
    lbl.text = text;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        [[[cell subviews] objectAtIndex:0] setTag:111];
        //[[cell viewWithTag:111] setBackgroundColor:[UIColor yellowColor]];
        
        [cell.contentView addSubview:[self makeLabelAtX:45.0 y:5.0 width:150.0 height:22.0 tag:1001]];
        [cell.contentView addSubview:[self makeLabelAtX:200.0 y:5.0 width:40.0 height:22.0 tag:1002]];
        [cell.contentView addSubview:[self makeLabelAtX:245.0 y:5.0 width:70.0 height:22.0 tag:1003]];
        [cell.contentView addSubview:[self makeLabelAtX:330.0 y:5.0 width:200.0 height:22.0 tag:1004]];
        
        cell.backgroundView.frame = CGRectMake(0, 0, 768, 100);
        UIImage *bgImage = [UIImage imageNamed:@"b1.png"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:bgImage] autorelease];
    }
    
    // configure the cell here
    
    UndersokningsResultat *ur = [self.results objectAtIndex:[indexPath section]];
    AnalysTjanst *at = [ur.analysTjanster objectAtIndex:[indexPath row]];
    
    [self setLabelTextInCell:cell text:at.atgardskodText tag:1001];
    [self setLabelTextInCell:cell text:at.varde tag:1002];
    [self setLabelTextInCell:cell text:at.vardeEnhet tag:1003];
    [self setLabelTextInCell:cell text:at.referensintervall tag:1004];
    
    //    cell.accessoryType = ([self.selectedAnalysisCode isEqualToString:result.analysisCode]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

// optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.results count];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    DemoKlinLabReport *report = [self.currentReports objectAtIndex:section];
    NSDate *from = report.samplesTaken;
    NSDate *result = report.resultReady;
    NSString *hdr = date2str(report.samplesTaken);
    NSLog(@"Header for section %d: %@", section, hdr);
    return hdr;
}*/

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 34.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    DemoKlinLabReport *report = [self.currentReports objectAtIndex:[indexPath section]];
//    DemoKlinLabResult *result = [report.results objectAtIndex:[indexPath row]];
//    if ([result.analysisCode isEqualToString:self.selectedAnalysisCode])
//        self.selectedAnalysisCode = @"";
//    else
//        self.selectedAnalysisCode = result.analysisCode;
//    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 100.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat tvWidth     = tableView.frame.size.width;
    UndersokningsResultat *ur = [self.results objectAtIndex:section];
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tvWidth, 100)];
    view.image = [UIImage imageNamed:@"b3.png"];
    
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tvWidth, 100)];
    UILabel *title = [self makeLabelAtX:35.0 y:25.0 width:300.0 height:44.0 tag:101];
    title.text = @"Klinisk Kemi Rapport";
    title.font = [UIFont boldSystemFontOfSize:24.0];
    title.backgroundColor = [UIColor clearColor];
    [view addSubview:title];
    
    UILabel *taken = [self makeLabelAtX:(tvWidth - 305.0) y:25.0 width:170 height:22 tag:102];
    taken.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    taken.text = @"Registrerad:";
    taken.backgroundColor = [UIColor clearColor];
    [view addSubview:taken];

    UILabel *takenDate = [self makeLabelAtX:(tvWidth - 170.0) y:25.0 width:160 height:22 tag:103];
    takenDate.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    takenDate.text = date2str(ur.registreringstidpunkt);
    takenDate.backgroundColor = [UIColor clearColor];
    [view addSubview:takenDate];
    
    UILabel *ready = [self makeLabelAtX:(tvWidth - 305.0) y:50.0 width:170 height:22 tag:104];
    ready.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    ready.text = @"Klart:";
    ready.backgroundColor = [UIColor clearColor];
    [view addSubview:ready];
    
    UILabel *readyDate = [self makeLabelAtX:(tvWidth - 170.0) y:50.0 width:160 height:22 tag:105];
    readyDate.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    readyDate.text = date2str(ur.svarsstidpunkt);
    readyDate.backgroundColor = [UIColor clearColor];
    [view addSubview:readyDate];
    
    return [view autorelease];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 50)];
    view.image = [UIImage imageNamed:@"b2b.png"];
    
    UILabel *title = [self makeLabelAtX:35 y:0 width:400 height:40 tag:101];
    title.text = @"Slut på rapport";
    title.font = [UIFont systemFontOfSize:18.0];
    title.backgroundColor = [UIColor clearColor];
    [view addSubview:title];
    return [view autorelease];
}

@end
