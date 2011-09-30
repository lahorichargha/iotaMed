//
//  ItemTableCellString.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemTableCellString.h"
#import "IDRObservation.h"
#import "IDRItem.h"
#import "IDRValue.h"
#import <AVFoundation/AVAudioSession.h>
#import <CoreAudio/CoreAudioTypes.h>
// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface  ItemTableCellString ()
@end



@implementation ItemTableCellString

@synthesize tfValue = _tfValue;
@synthesize slider = _slider;
@synthesize labelCellCurrent = _labelCellCurrent;
@synthesize labelCellDuration = _labelCellDuration;
@synthesize play = _play;
@synthesize rec = _rec;
@synthesize myVUmeter=_myVUmeter;
@synthesize uuids = _uuids;
@synthesize avPlayer = _avPlayer;
@synthesize avRecorder = _avRecorder;
@synthesize timer = _timer;
@synthesize symbolView=_symbolView;
@synthesize vvbar=_vvbar;
@synthesize sliderbarbutton=_sliderbarbutton;
@synthesize labelBarC=_labelBarC;
@synthesize labelBarD=_labelBarD;
@synthesize stopBar=_stopBar;
@synthesize pauseBar=_pauseBar;


+ (void)load {
    [super addSubclass:self];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return [idrItem hasObservation] && [idrItem hasInput] && ![idrItem.observation isNumeric] && ![idrItem.observation isCheck];
}

+ (ItemTableCellString *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCellString *cell = (ItemTableCellString *)idrItem.itemTableCell;
    if (cell == nil) {
        cell = [[[self alloc] initWithTableView:tableView idrItem:idrItem] autorelease];
    }
    return cell;
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    return [super subCellHeightForTableView:tableView idrItem:idrItem];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    if ((self = [super initWithTableView:tableView idrItem:idrItem]))  {
        self.tfValue = (UITextField *)[self viewOfClass:[UITextField class] tag:TAG_TEXTFIELD];
        self.tfValue.borderStyle = UITextBorderStyleRoundedRect;
        self.tfValue.delegate = self;
        self.tfValue.autocorrectionType = UITextAutocorrectionTypeNo;
        self.tfValue.text = [idrItem getItemValue].value;
        
        //add symbols (record, pause, stop, play) from the left to the text field.
        CGRect symbolRect=CGRectMake(0, 0, self.tfValue.frame.size.height-18,self.tfValue.frame.size.height-18);
        self.symbolView=[[[UIImageView alloc]initWithFrame:symbolRect]autorelease];
        self.tfValue.leftView = self.symbolView;
        self.tfValue.leftViewMode = UITextFieldViewModeWhileEditing;
        
        // single tap: pop up list of choices, including default, manual text, dictation, clear
        UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureListOfChoices)] autorelease];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        // reactivate this one when you have a popup working for edit fields
        //        [self.tfValue addGestureRecognizer:singleTap];
        
        // double tap, one finger: enter default text
        UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureDefaultEntry)] autorelease];
        doubleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;
        [self.tfValue addGestureRecognizer:doubleTap];
        
        // two finger single tap: keyboard entry
        UITapGestureRecognizer *twoFingerSingleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureKeyboardEntry)] autorelease];
        twoFingerSingleTap.numberOfTouchesRequired = 2;
        twoFingerSingleTap.numberOfTapsRequired = 1;
        [self.tfValue addGestureRecognizer:twoFingerSingleTap];
        
        UIToolbar *tb = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 10, 30)] autorelease];
        tb.barStyle = UIBarStyleBlackTranslucent;
        UIBarButtonItem *bbispacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        
        UIImage *microImage = [UIImage imageNamed:@"tape4.png"];
        self.rec = [[[UIBarButtonItem alloc] initWithImage:microImage style:UIBarButtonItemStylePlain target:self action:@selector(doRecord:)] autorelease];
        self.play = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(doPlay:)] autorelease];
        UIBarButtonItem *bbicamera = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:nil] autorelease];
        self.pauseBar=[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(doPause:)]autorelease];
        self.stopBar=[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(doStop:)]autorelease];
        
        UILabel *lb1 = [[[UILabel alloc] initWithFrame:CGRectMake(500, 10, 34, 20)] autorelease];
        [lb1 setBackgroundColor:[UIColor colorWithRed:.45 green:.45 blue:.45 alpha:1.]];
        self.labelBarC=[[[UIBarButtonItem alloc]initWithCustomView:lb1]autorelease];
        self.labelCellCurrent = lb1;
        
        UISlider *sl = [[[UISlider alloc] initWithFrame:CGRectMake(545, 10, 80, 5)] autorelease];
        self.sliderbarbutton=[[[UIBarButtonItem alloc]initWithCustomView:sl]autorelease];
        self.slider = sl;
        
        UILabel *lb2 = [[[UILabel alloc] initWithFrame:CGRectMake(650, 5, 34, 20)] autorelease];
        [lb2 setBackgroundColor:[UIColor colorWithRed:.45 green:.45 blue:.45 alpha:1.]];
        self.labelBarD=[[[UIBarButtonItem alloc]initWithCustomView:lb2]autorelease];
        self.labelCellDuration = lb2;
        
        MyVUMeter *vu=[[[MyVUMeter alloc]initWithFrame:CGRectMake(0, 5, 80, 25)]autorelease];
        self.vvbar=[[[UIBarButtonItem alloc] initWithCustomView:vu] autorelease];
        self.myVUmeter=vu;

        tb.items = [NSArray arrayWithObjects:self.rec,self.stopBar,self.vvbar, bbispacer ,bbicamera, bbispacer,self.labelBarC,self.sliderbarbutton, self.labelBarD, self.play, self.pauseBar, nil];
        
        [self.vvbar.customView setHidden:YES];
        [self.sliderbarbutton.customView setHidden:YES];
        [self.labelBarC.customView setHidden:YES];
        [self.labelBarD.customView setHidden:YES];

        
        self.tfValue.inputAccessoryView = tb;
        [self layoutSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat currentWidth = self.frame.size.width;
    CGRect newFrame = CGRectMake(currentWidth - kInputOffsetRightEndFromRight - kInputWidthWide, kInputOffsetFromTop, kInputWidthWide, kInputHeight);
    self.tfValue.frame = newFrame;
//    NSLog(@"layout ItemTableCellString: %@", NSStringFromCGRect(newFrame));
}

- (void)dealloc {
    self.lblContent = nil;
    self.tfValue = nil;
    self.slider=nil;
    self.labelCellCurrent=nil;
    self.labelCellDuration=nil;
    self.play=nil;
    self.rec=nil;
    self.myVUmeter=nil;
    self.avRecorder = nil;
    self.avPlayer = nil;
    self.timer = nil;
    self.symbolView=nil;
    self.labelBarC=nil;
    self.labelBarD=nil;
    self.vvbar=nil;
    self.stopBar=nil;
    self.pauseBar=nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Gestures
// -----------------------------------------------------------



- (void)gestureListOfChoices {
    // create a popover pointing to the entry field
}

- (void)gestureDefaultEntry {
    
}

- (void)gestureKeyboardEntry {
    [self.tfValue becomeFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Metrics
// -----------------------------------------------------------

+ (CGFloat)gadgetSpaceAdd:(CGFloat)oldSpace forItem:(IDRItem *)idrItem {
    return [super gadgetSpaceAdd:(oldSpace + kInputWidthWide + kInterGadgetSpace) forItem:idrItem];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // when text field begins editing, the keyboard is not yet fully deployed
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardDidShow:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:nil];

}

- (void)keyboardDidShow:(NSNotification *)n {
    // now the keyboard is fully deployed and we can center the view right
    // we also have to remove the notification right away, else any other cell that gets
    // activated will make this one try to center itself again; not such a great idea
    NSIndexPath *indexPath = [self.parentTableView indexPathForCell:self];
    [self.parentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardDidShowNotification 
                                                  object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *newText = textField.text;
    [self.idrItem setItemValue:newText];
}

// -----------------------------------------------------------
#pragma - recorder delegate
//------------------------------------------------------------------

-(void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"did finish recording!");
    [self.timer invalidate];
    [self.vvbar.customView setHidden:YES];
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
    [self.sliderbarbutton.customView setHidden:YES];
    [self.labelBarC.customView setHidden:YES];
    [self.labelBarD.customView setHidden:YES];
    [self setSymbolnamed:nil];
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
    self.labelCellCurrent.text=[NSString stringWithFormat:@"%d:%02d", (int) p.currentTime/60, (int) p.currentTime % 60, nil];
    self.slider.value=p.currentTime;
    timePaused=p.currentTime;
    
}

-(void) durationTimeForPlayer:  (AVAudioPlayer *) p{
    self.labelCellDuration.text=[NSString stringWithFormat:@"%d:%02d", (int) p.duration/60, (int) p.duration % 60, nil];
    self.slider.maximumValue=p.duration;
    
}

-(void) updateCurrentTime{
    [self currentTimeForPlayer:self.avPlayer];
    [self durationTimeForPlayer:self.avPlayer];
    
}

-(void) updateUVMeter{
    [self.avRecorder updateMeters];
    CGFloat db = [self.avRecorder averagePowerForChannel:0];
    CGFloat peakDb = [self.avRecorder peakPowerForChannel:0];
    // db goes from -160.0 to 0.0, but iOS only goes from -120 to 0
    
    NSLog(@"db, peakDb: %f %f", db, peakDb);
    
    // with this conversion, the volume values should become 0.0 - 1.0
    CGFloat myIdeaOfVolume = (db + dbRange) / dbRange;
    CGFloat myIdeaOfPeakVolume = (peakDb + dbRange) / dbRange;
    
    self.myVUmeter.volume = myIdeaOfVolume;
    self.myVUmeter.peakVolume = myIdeaOfPeakVolume;
    [self.myVUmeter setNeedsDisplay];

}

- (void)timerFired:(NSTimer *)timer {
    [self updateUVMeter];
}

- (void)doRecord:(id)sender {
    
    NSLog(@"start to record.");
    [self setSymbolnamed:@"record_image@2x"];
    self.play.enabled=NO;
    self.pauseBar.enabled=NO;
    [self.vvbar.customView setHidden:NO];
    
    NSTimeInterval ti=1.0/30.0;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    
    //sharedInstance Returns the singleton audio session.
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [audioSession setActive:YES error:nil];
    
//    NSURL *url=[self getFileURL];
//    NSLog(@"record url%@",url);
    
    NSURL *urluuid=[self getURLToSend];
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

}

- (void)doPlay:(id)sender {
    NSLog(@"start playing");
    [self setSymbolnamed:@"play_image@2x"];
    
    [self.sliderbarbutton.customView setHidden:NO];
    [self.labelBarC.customView setHidden:NO];
    [self.labelBarD.customView setHidden:NO];
    
//    NSURL *url = [self getFileURL];
//    NSLog(@"Url to play: %@", url);
    
    NSURL *urlPlay=[self.uuids objectAtIndex:0];
    
    if (!playWasPaused || !self.avPlayer) {
        self.avPlayer=[[[AVAudioPlayer alloc]initWithContentsOfURL:urlPlay error:nil]autorelease];
        self.avPlayer.delegate = self;
    }
    
    [self.avPlayer play];
    [self currentTimeForPlayer:self.avPlayer];
    
    self.timer=[NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:self.avPlayer repeats:YES];
    
    if (playWasPaused) {
        [self currentTimeForPlayer:self.avPlayer];
        
        [self.avPlayer playAtTime:timePaused];
    }
    
}

- (void)doPause:(id)sender {
    [self.avPlayer pause];
    NSLog(@"paused");
    playWasPaused=YES;
    [self setSymbolnamed:@"pause_image@2x"];
}

- (void)doStop:(id)sender  {
    NSLog(@"Stopped recording");
    
    self.play.enabled=YES;
    self.pauseBar.enabled=YES;
    
    [self.avRecorder stop];
    
    self.myVUmeter.volume = 0;
    self.myVUmeter.peakVolume = 0;
    [self.myVUmeter setNeedsDisplay];
    
    [self setSymbolnamed:@"stop_image@2x"];
}

- (IBAction)sliderValue:(UISlider*)sender {
    
    self.avPlayer.currentTime=sender.value;
    [self durationTimeForPlayer:self.avPlayer];
    
}

-(void) setSymbolnamed: (NSString *) fileName{
    self.symbolView.image=[UIImage imageNamed:fileName];
    [self.symbolView setNeedsDisplay];
}



@end
