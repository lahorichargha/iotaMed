//
//  IssueWorksheetController_Multiselect.h
//  iotaPad6
//
//  Created by Piotr Perzanowski on 8/31/11.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "IssueWorksheetController.h"

@interface IssueWorksheetController (Multiselect) <IssueItemMultiselectViewDelegate>

- (void)initForIssueItemMultiselectViewController;
- (IBAction)multiselectButtonAction:(id)sender;

@end
