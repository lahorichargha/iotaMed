//
//  ItemSelectViewController.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-10-09.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemSelectViewController.h"
#import "ItemTableCellString.h"

@interface ItemSelectViewController()
@property (nonatomic, retain) NSIndexPath *selectedIndex;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@end

@implementation ItemSelectViewController

@synthesize delegate = _delegate;
@synthesize btnKeyboard = _btnKeyboard;
@synthesize btnRec=_btnRec;
@synthesize selectedIndex = _selectedIndex;
@synthesize tableView = _tableView;
@synthesize btnPlay=_btnPlay;
@synthesize audioRec=_audioRec;
@synthesize avRec=_avRec;
@synthesize avPlay=_avPlay;
@synthesize vum=_vum;
@synthesize timer=_timer;
@synthesize sliderItemSelect=_sliderItemSelect;
@synthesize currentLabelItemSelect=_currentLabelItemSelect;
@synthesize durationLabelItemSelect=_durationLabelItemSelect;

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
    self.audioRec=nil;
    [self.btnKeyboard release];
    [self.btnRec release];
    [self.btnPlay release];
    self.avRec=nil;
    self.avPlay=nil;
    self.vum=nil;
    self.timer=nil;
    self.sliderItemSelect=nil;
    self.currentLabelItemSelect=nil;
    self.durationLabelItemSelect=nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View Lifecycle
// -----------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!(self.audioRec.recording)) {
        [self.btnRec setTitle:@"Record" forState:UIControlStateNormal];}
    if (!(self.audioRec.playWasPaused) || !(self.audioRec.playing)) {
        [self.btnPlay setTitle:@"Play" forState:UIControlStateNormal];}
}

- (void)viewDidUnload {
    [self setBtnKeyboard:nil];
    [self setBtnRec:nil];
    [self setBtnPlay:nil];
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
static const CGFloat dbRange = 120.0;
-(void) updateMeter{
    [self.avRec updateMeters];
    CGFloat db = [self.avRec averagePowerForChannel:0];
    CGFloat peakDb = [self.avRec peakPowerForChannel:0];
    // db goes from -160.0 to 0.0, but iOS only goes from -120 to 0
    
    NSLog(@"db, peakDb: %f %f", db, peakDb);
    
    // with this conversion, the volume values should become 0.0 - 1.0
    CGFloat myIdeaOfVolume = (db + dbRange) / dbRange;
   CGFloat myIdeaOfPeakVolume = (peakDb + dbRange) / dbRange;
    
    self.vum.volume = myIdeaOfVolume;
    self.vum.peakVolume = myIdeaOfPeakVolume;
    [self.vum setNeedsDisplay];
}

-(void)prepareMeter{
    
}





-(IBAction)recording:(id)sender{
   
    
    if (!(self.audioRec.recording)) {
        AudioRecording *audio=[[[AudioRecording alloc]init]autorelease];
        self.audioRec=nil;
        self.audioRec=audio;
        
//        MyVUMeter *vumeter=(MyVUMeter *)audio.VUmeter;
//        self.vum=vumeter;

        [audio prepareToRecord];
        self.avRec=nil;
        self.avRec=audio.avRecorder;
        
           [audio record];
        

        self.audioRec.recording=YES;  
        [self.btnRec setTitle:@"Stop" forState:UIControlStateNormal];
        
        }
    else{
        
        
        [self.audioRec stopping];
        self.audioRec.stopBool=YES;
       self.audioRec.recording=NO;
        [self.btnRec setTitle:@"Record" forState:UIControlStateNormal];
        }
}

-(IBAction)playing:(id)sender{
    
         
    if (!(self.audioRec.playing)) {
        [self.audioRec play];
        [self sliderChanged:self.sliderItemSelect];
        self.currentLabelItemSelect=self.audioRec.labelCellCurrent;
        self.durationLabelItemSelect=self.audioRec.labelCellDuration;

               

        self.audioRec.playing=YES;
        [self.btnPlay setTitle:@"Pause" forState:UIControlStateNormal];
        self.avPlay=self.audioRec.avPlayer;
        
    }
    else{
        
        if (self.audioRec.didFinishPlay) {
            [self.btnPlay setTitle:@"play" forState:UIControlStateNormal];
        }
        else{
        [self.audioRec pausing];
       self.audioRec.playWasPaused=YES;
        self.audioRec.playing=NO;
            [self.btnPlay setTitle:@"Play" forState:UIControlStateNormal];}
        
    }
   
   
   }


-(IBAction)sliderChanged:(id)sender{
    
    self.sliderItemSelect=sender;
    [self.audioRec sliderValue:self.sliderItemSelect];
    
   self.audioRec.labelCellCurrent= self.currentLabelItemSelect;
   self.audioRec.labelCellDuration= self.durationLabelItemSelect;
        
    
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
