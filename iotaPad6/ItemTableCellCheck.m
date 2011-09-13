//
//  ItemTableCellCheck.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemTableCellCheck.h"
#import "IDRObservation.h"
#import "IDRObsDefinition.h"
#import "IDRContact.h"
#import "IDRValue.h"
#import "IDRBlock.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface  ItemTableCellCheck ()
- (void)displayValue;
@end


@implementation ItemTableCellCheck

@synthesize lblCheck = _lblCheck;

+ (void)load {
    [super addSubclass:self];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return [idrItem hasObservation] && [idrItem.observation isCheck];
}

+ (ItemTableCellCheck *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCellCheck *cell = (ItemTableCellCheck *)idrItem.itemTableCell;
    if (cell == nil) {
        cell = [[[self alloc] initWithTableView:tableView idrItem:idrItem] autorelease];
    }
    return cell;
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    return [super subCellHeightForTableView:tableView idrItem:idrItem];
}

+ (CGFloat)gadgetSpaceAdd:(CGFloat)oldSpace forItem:(IDRItem *)idrItem {
    return [super gadgetSpaceAdd:(oldSpace + kCheckViewWidth + kInterGadgetSpace) forItem:idrItem];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    if ((self = [super initWithTableView:tableView idrItem:idrItem])) {
        self.lblCheck = (UILabel *)[self viewOfClass:[UILabel class] tag:TAG_CHECKVIEW];
        self.lblCheck.backgroundColor = [UIColor clearColor];
        [self layoutSubviews];
        [self displayValue];
    }
    return self;
}

- (void)dealloc {
    self.lblCheck = nil;
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat rightMargin = [self cellWidth] - [[self superclass] gadgetSpaceAdd:kInterGadgetSpace forItem:self.idrItem];
    self.lblCheck.frame = CGRectMake(rightMargin - kCheckViewWidth, kInputOffsetFromTop, kCheckViewWidth, kInputHeight);
}

- (void)displayValue {
    IDRObservation *obs = self.idrItem.observation;
    IDRObsDefinition *obsDef = obs.obsDefinition;
    IDRBlock *block = self.idrItem.parentBlock;
    IDRContact *contact = block.contact;
    IDRValue *value = [obsDef valueForContact:contact];
    if ([value.value isEqualToString:@"yes"])
        self.lblCheck.text = @"Ja";
    else if ([value.value isEqualToString:@"no"])
        self.lblCheck.text = @"Nej";
    else
        self.lblCheck.text = @"?";
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Touch stuff
// -----------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        NSLog(@"got a touch with tapcount: %d", t.tapCount);
    
        for (UIGestureRecognizer *gest in [t gestureRecognizers]) {
            NSLog(@"got a gesture");
        }
    }
}

@end
