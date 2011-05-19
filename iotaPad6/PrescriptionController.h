//
//  PrescriptionController.h
//  iotaPad6
//
//  Created by Martin on 2011-03-25.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrescriptionDetailController.h"

@protocol PrescriptionControllerDelegate <NSObject>

- (void)refresh;

@end

@class IDRItem;

@interface PrescriptionController : UIViewController <UITableViewDelegate, UITableViewDataSource,
            PrescriptionDetailControllerDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UILabel *lblDescription;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IDRItem *idrItem;
@property (nonatomic, retain) IBOutlet UIButton *btnOk;
@property (nonatomic, retain) IBOutlet UIButton *btnCustom;
@property (nonatomic, retain) id <PrescriptionControllerDelegate> pcDelegate;

- (IBAction)btnOk:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnCustom:(id)sender;

@end
