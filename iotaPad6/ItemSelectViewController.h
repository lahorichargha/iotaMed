//
//  ItemSelectViewController.h
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-10-09.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemSelectControllerDelegate.h"

@interface ItemSelectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id <ItemSelectControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *btnKeyboard;
@property (retain, nonatomic) IBOutlet UIButton *btnRecord;

+ (CGSize)neededSizeForRows:(NSUInteger)rows;
- (IBAction)btnKeyboard:(id)sender;
- (IBAction)btnRecord:(id)sender;

@end
