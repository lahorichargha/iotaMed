//
//  ReferralControllerDelegate.h
//  iotaPad6
//
//  Created by Martin on 2011-03-27.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDRItem;

@protocol ReferralControllerDelegate <NSObject>

- (void)sentReferralForItem:(IDRItem *)item;

@end
