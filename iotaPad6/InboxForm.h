//
//  InboxForm.h
//  iotaPad6
//
//  Created by Martin on 2011-05-15.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InboxForm : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
