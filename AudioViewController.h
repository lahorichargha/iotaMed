//
//  AudioViewController.h
//  Audio
//
//  Created by Shiva on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioRecorder.h>
#import <UIKit/UIKit.h>
#import "ItemCellDelegate.h"

@class MyVUMeter;


@interface AudioViewController : UIViewController <AVAudioPlayerDelegate,AVAudioRecorderDelegate>{
    
    
   // IBOutlet UITableViewCell *myCell;
   
   
    UIButton *recordButton;
    UIButton *stopButton;
    UIButton *playButton;
    UIButton *pauseButton;
    UILabel *currentTime;
    UILabel *duration;
    UISlider *progressSlider;
    
    BOOL						playWasPaused;
    double timePaused;
       
   

  
   
   
}

@property (retain, nonatomic) IBOutlet UIButton *recordButton;

@property (retain, nonatomic) IBOutlet UIButton *stopButton;

@property (retain , nonatomic) IBOutlet UIButton *playButton;

@property (retain, nonatomic) IBOutlet UIButton *pauseButton;

@property (retain, nonatomic) IBOutlet UILabel *currentTime;

@property (retain, nonatomic) IBOutlet UILabel *duration;

@property (retain, nonatomic) IBOutlet UISlider *progressSlider;

@property (retain, nonatomic) NSMutableArray *uuids;

@property (retain, nonatomic) AVAudioPlayer *avPlayer;

@property (retain,nonatomic) AVAudioRecorder *avRecorder;

@property (retain,nonatomic) NSTimer *timer;

@property (retain, nonatomic) IBOutlet MyVUMeter *myVuMeter;

@property (nonatomic, retain) id <ItemCellDelegate> ItemCellDelegate;



- (IBAction)recordButton:(id)sender;

- (IBAction)stopButton:(id)sender;

- (IBAction)playButton:(id)sender;

- (IBAction)pauseButton:(id)sender;

- (IBAction)sliderValue:(UISlider*)sender;








@end
