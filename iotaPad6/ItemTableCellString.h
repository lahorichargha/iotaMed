//
//  ItemTableCellString.h
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemTableCellHistory.h"
#import "MyVUMeter.h"
#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>


@interface ItemTableCellString : ItemTableCellHistory <UITextFieldDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate>{
    
    BOOL  playWasPaused;
    double timePaused;
}

@property (nonatomic, retain) UITextField *tfValue;
@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) UILabel *labelCellCurrent;
@property (nonatomic,retain)UILabel *labelCellDuration;
@property (nonatomic,retain) MyVUMeter *myVUmeter;
@property (retain, nonatomic) NSMutableArray *uuids;
@property (retain, nonatomic) AVAudioPlayer *avPlayer;
@property (retain,nonatomic) AVAudioRecorder *avRecorder;
@property (retain,nonatomic) NSTimer *timer;
@property (retain,nonatomic) UIImageView *symbolView;
@property(nonatomic,retain) UIBarButtonItem *vvbar;
@property(nonatomic,retain)UIBarButtonItem *sliderbarbutton;
@property (nonatomic, retain) UIBarButtonItem *play;
@property(nonatomic,retain) UIBarButtonItem *rec;
@property (nonatomic, retain) UIBarButtonItem *labelBarC;
@property(nonatomic,retain) UIBarButtonItem *labelBarD;
@property (nonatomic, retain) UIBarButtonItem *stopBar;
@property(nonatomic,retain) UIBarButtonItem *pauseBar;

-(void) setSymbolnamed: (NSString *) fileName;

+ (ItemTableCellString *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem;
+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem;

@end
