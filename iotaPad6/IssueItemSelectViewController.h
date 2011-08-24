//
//  IssueItemSelectViewController.h
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/18/11.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IDRItem;

@protocol IssueItemSelectViewDelegate <NSObject>

- (void)changeSelectLable:(NSString *)text;

@end

@interface IssueItemSelectViewController : UITableViewController 

@property (nonatomic, retain) IDRItem *idrItem;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@property (nonatomic, assign) id<IssueItemSelectViewDelegate> itemSelectDelegate;

@end
