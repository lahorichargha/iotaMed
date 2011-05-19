//
//  LabOrderController.h
//  iotaPad6
//
//  Created by Martin on 2011-03-24.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IDRItem;

@protocol LabOrderControllerDelegate <NSObject>

- (void)sentLabOrderForItem:(IDRItem *)item;

@end


@interface LabOrderController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IDRItem *idrItem;
@property (nonatomic, retain) id <LabOrderControllerDelegate> labOrderControllerDelegate;

- (IBAction)btnOk:(id)sender;
- (IBAction)btnCancel:(id)sender;

@end
