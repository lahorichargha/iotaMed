//
//  ItemSelectController.h
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-10-06.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemSelectControllerDelegate.h"

@interface ItemSelectController : UITableViewController

@property (nonatomic, assign) id <ItemSelectControllerDelegate> delegate;

@end
