//
//  InboxMyIotaForm.h
//  iotaPad6
//
//  Created by Martin on 2011-05-15.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IDRBlock;
@class PatientContext;

@interface InboxMyIotaForm : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IDRBlock *block;
@property (nonatomic, retain) PatientContext *miContext;
@end
