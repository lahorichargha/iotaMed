//
//  ItemTableCellString.h
//  iotaPad6
//
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

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem;
- (void)writeCurrent;
@end
