//
//  PatientControllerDelegate.h
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-07-24.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Patient;
@protocol PatientControllerDelegate <NSObject>

- (void)createPatient:(Patient *)patient;
- (void)updatePatient:(Patient *)patient;
- (void)deletePatient:(Patient *)patient;

@end
