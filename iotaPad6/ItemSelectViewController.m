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
@synthesize itemString=_itemString;
@synthesize avRecorder=_avRecorder;
@synthesize avPlayer=_avPlayer;
@synthesize uuids=_uuids;
@synthesize timer=_timer;
@synthesize myVUmeter=_myVUmeter;
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
    self.itemString=nil;
    [self.btnKeyboard release];
    [self.btnRec release];
    [self.btnPlay release];
    self.avRecorder=nil;
    self.avPlayer=nil;
    self.myVUmeter=nil;
    self.uuids=nil;
    self.timer=nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View Lifecycle
// -----------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!recording) {
        [self.btnRec setTitle:@"Record" forState:UIControlStateNormal];}
    if (!playWasPaused || !playing) {
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

// -----------------------------------------------------------
#pragma - recorder delegate
//------------------------------------------------------------------

-(void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"did finish recording!");
    [self.timer invalidate];
    [self.btnRec setTitle:@"Record" forState:UIControlStateNormal];
    self.btnRec.enabled=YES;

}


-(void) audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"an error accured");
}

//Martin had two more delegate here! Check Later.


//------------------------------------------------------------------

#pragma - player delegate
//------------------------------------------------------------------


-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"did finish playing!");
    [self.timer invalidate];
    [self.btnPlay setTitle:@"Play" forState:UIControlStateNormal];
    self.btnPlay.enabled=YES;
    playing=NO;
       // [self setSymbolnamed:nil];
}

-(void) audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"An error accured!");
}


//------------------------------------------------------------------

#pragma - get directory
//------------------------------------------------------------------

-(NSString*) getDocumentDirectory{
    NSString *path=[NSTemporaryDirectory() stringByAppendingPathComponent: @"recordedFile.caf"];  
    return path;
    NSLog(@"path%@",path);
}

-(NSURL*) getFileURL{
    NSString *docDir=[self getDocumentDirectory];
    NSURL *url=[NSURL fileURLWithPath:docDir];
    return url;
}

-(NSString*) uniquePathDirctory{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    NSString *newPath = [NSString stringWithFormat:@"%@/%@.caf", NSTemporaryDirectory(), uuidString];
    CFRelease(uuidString);
    return newPath;
}

-(NSURL*) getURLToSend{
    
    NSString *docDir=[self uniquePathDirctory];
    NSURL *url;
    url=[NSURL fileURLWithPath:docDir];
    return url;    
}

//---------------------------------------------------------
#pragma mark -
#pragma mark Soundrecording stuff
//---------------------------------------------------------

static const CGFloat dbRange = 120.0;

-(void) currentTimeForPlayer: (AVAudioPlayer *) p {
    timePaused=p.currentTime;
    
}

-(void) updateCurrentTime{
    [self currentTimeForPlayer:self.avPlayer];
}

-(void) updateUVMeter{
    [self.avRecorder updateMeters];
}

- (void)timerFired:(NSTimer *)timer {
    [self updateUVMeter];
}

- (IBAction)recording:(id)sender {
    
    if (recording) {
        [self stopping];}
    else{
        [self.btnRec setTitle:@"Stop" forState:UIControlStateNormal];
        
    
    NSLog(@"start to record.");
    //[self setSymbolnamed:@"record_image@2x"];
        
    NSTimeInterval ti=1.0/30.0;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(updateUVMeter) userInfo:nil repeats:YES];
    
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    
    //sharedInstance Returns the singleton audio session.
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [audioSession setActive:YES error:nil];
    
    //    NSURL *url=[self getFileURL];
    //    NSLog(@"record url%@",url);
    
    NSURL *urluuid=[self getFileURL];
    NSLog(@"record UUIDAdress %@",urluuid);
    
    if (!self.uuids) {
        self.uuids = [[[NSMutableArray alloc] initWithCapacity:5]autorelease];
    }
    [self.uuids addObject:urluuid];
    
    NSMutableDictionary *recordSetting=[[[NSMutableDictionary alloc]init]autorelease]; 
    
    //    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
    //    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    //    [recordSetting setValue :[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
    //    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    //    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    self.avRecorder=[[[AVAudioRecorder alloc]initWithURL:urluuid settings:recordSetting error:nil]autorelease];
    self.avRecorder.delegate=self; 
    [self.avRecorder prepareToRecord];
    self.avRecorder.meteringEnabled=YES;
    
    BOOL didStartRecord=[self.avRecorder record];
    if (!didStartRecord) 
        NSLog(@"faile to record");
    else 
        NSLog(@"Could record");
    
        recording=YES;}
    
}

- (IBAction)playing:(id)sender {
    
    if (playing) {
                [self pausing];
        }
    
    else{
        if (playWasPaused) {
        
            [self.avPlayer play];
            NSLog(@"playing again");
            
            [self.btnPlay setTitle:@"PauseAgain" forState:UIControlStateNormal];
            playing=YES;}
        else{

    
    NSLog(@"start playing");
   // [self setSymbolnamed:@"play_image@2x"];
    
       
    //    NSURL *url = [self getFileURL];
    //    NSLog(@"Url to play: %@", url);
    
    NSURL *urlPlay=[self.uuids objectAtIndex:0];
    
    if (!playWasPaused || !self.avPlayer) {
        self.avPlayer=[[[AVAudioPlayer alloc]initWithContentsOfURL:urlPlay error:nil]autorelease];
        self.avPlayer.delegate = self;
    
        self.timer=[NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:self.avPlayer repeats:YES];

    
    [self.avPlayer play];
        [self currentTimeForPlayer:self.avPlayer];
        [self.btnPlay setTitle:@"Pause" forState:UIControlStateNormal];
        playing=YES; }
        
        }

    }
    
}

- (void)pausing{
    NSLog(@"paused");
    [self.btnPlay setTitle:@"PlayAgain" forState:UIControlStateNormal];
        [self.avPlayer pause];
    playWasPaused=YES;
        playing=NO;
    
    //[self setSymbolnamed:@"pause_image@2x"];
}

- (void)stopping{
    NSLog(@"Stopped recording");
    
    if (stopping) {
        self.btnRec.enabled=YES;
        [self.btnRec setTitle:@"Record" forState:UIControlStateNormal];}
    
    else{
       [self.avRecorder stop];
       stopping=YES;
       recording=NO;}
    //[self setSymbolnamed:@"stop_image@2x"];
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
