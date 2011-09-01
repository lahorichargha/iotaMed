//
//  IssueWorksheetController_Select.h
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/31/11.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IssueWorksheetController.h"

@interface IssueWorksheetController (Select) <IssueItemSelectViewDelegate>

- (void)initForIssueItemSelectViewController;
- (IBAction)selectButtonAction:(id)sender;

@end
