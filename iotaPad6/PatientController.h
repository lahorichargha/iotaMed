//
//  PatientController.h
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-07-24.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientControllerDelegate.h"

@class Patient;

@interface PatientController : UIViewController {
    UIButton *btnDelete;
}

@property (nonatomic, retain) IBOutlet UITextField *txtPersonnumber;
@property (nonatomic, retain) IBOutlet UITextField *txtFirstname;
@property (nonatomic, retain) IBOutlet UITextField *txtLastname;
@property (nonatomic, retain) IBOutlet UIButton *btnDelete;
@property (retain, nonatomic) IBOutlet UIButton *btnCancel;
@property (retain, nonatomic) IBOutlet UIButton *btnOk;
@property (retain, nonatomic) IBOutlet UILabel *lblPersonnumber;
@property (retain, nonatomic) IBOutlet UILabel *lblFirstname;
@property (retain, nonatomic) IBOutlet UILabel *lblLastname;
@property (retain, nonatomic) IBOutlet UILabel *lblDemoWarning;

@property (retain) Patient *patient;

@property (assign) id <PatientControllerDelegate> delegate;

- (IBAction)btnOk:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnDelete:(id)sender;

@end
