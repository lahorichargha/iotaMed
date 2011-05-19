//
//  ReferralController.h
//  iotaPad6
//
//  Created by Martin on 2011-03-25.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReferralControllerDelegate.h"

@class IDRItem;

@interface ReferralController : UIViewController {
    
}

@property (nonatomic, retain) IDRItem *item;

@property (nonatomic, retain) IBOutlet UITextView *toTextView;
@property (nonatomic, retain) IBOutlet UITextView *causeTextView;
@property (nonatomic, retain) IBOutlet UITextView *historyTextView;
@property (nonatomic, retain) IBOutlet UITextView *statusTextView;
@property (nonatomic, retain) IBOutlet UIButton *btnSend;

@property (nonatomic, retain) IBOutlet UIButton *btnCancel;
@property (nonatomic, retain) IBOutlet UILabel *lblTo;
@property (nonatomic, retain) IBOutlet UILabel *lblCause;
@property (nonatomic, retain) IBOutlet UILabel *lblHistory;
@property (nonatomic, retain) IBOutlet UILabel *lblStatus;

@property (nonatomic, retain) id <ReferralControllerDelegate> rcDelegate;

- (IBAction)btnSend:(id)sender;
- (IBAction)btnCancel:(id)sender;

@end
