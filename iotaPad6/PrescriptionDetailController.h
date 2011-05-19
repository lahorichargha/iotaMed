//
//  PrescriptionDetailController.h
//  iotaPad6
//
//  Created by Martin on 2011-03-26.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IDRItem;

@protocol PrescriptionDetailControllerDelegate <NSObject>

- (void)takeDoseName:(NSString *)doseName extendedDoseName:(NSString *)extendedDoseName;

@end

@interface PrescriptionDetailController : UIViewController <UITextViewDelegate> {
    
}

@property (nonatomic, retain) IDRItem *idrItem;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) NSString *idrDoseText;
@property (nonatomic, retain) id <PrescriptionDetailControllerDelegate> pdcDelegate;


@end
