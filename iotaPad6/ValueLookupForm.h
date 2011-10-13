//
//  ValueLookupForm.h
//  iotaPad6
//
//  Created by Martin on 2011-03-25.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IDRItem;
@class graphDrawing;

@interface ValueLookupForm : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IDRItem *idrItem;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segControl;
@property (nonatomic, retain) IBOutlet UIView *grafView;
@property (retain, nonatomic) IBOutlet UIButton *btnClose;
@property (nonatomic, retain)  IBOutlet graphDrawing *graph;
@property (nonatomic, retain) NSMutableArray *arrValue;
@property (nonatomic, retain) NSMutableArray *arrDate;

- (IBAction)segmentedChanged:(id)sender;
- (IBAction)btnClose:(id)sender;

@end
