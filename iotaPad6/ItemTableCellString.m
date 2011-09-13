//
//  ItemTableCellString.m
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-08-21.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//

#import "ItemTableCellString.h"
#import "IDRObservation.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface  ItemTableCellString ()
@end



@implementation ItemTableCellString

@synthesize tfValue = _tfValue;

+ (void)load {
    [super addSubclass:self];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    return [idrItem hasObservation] && [idrItem hasInput] && ![idrItem.observation isNumeric] && ![idrItem.observation isCheck];
}

+ (ItemTableCellString *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCellString *cell = (ItemTableCellString *)idrItem.itemTableCell;
    if (cell == nil) {
        cell = [[[self alloc] initWithTableView:tableView idrItem:idrItem] autorelease];
    }
    return cell;
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    return [super subCellHeightForTableView:tableView idrItem:idrItem];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    if ((self = [super initWithTableView:tableView idrItem:idrItem]))  {
        self.tfValue = (UITextField *)[self viewOfClass:[UITextField class] tag:TAG_TEXTFIELD];
        self.tfValue.borderStyle = UITextBorderStyleRoundedRect;
        self.tfValue.delegate = self;
        self.tfValue.autocorrectionType = UITextAutocorrectionTypeNo;
        
        // single tap: pop up list of choices, including default, manual text, dictation, clear
        UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureListOfChoices)] autorelease];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [self.tfValue addGestureRecognizer:singleTap];
        
        // double tap, one finger: enter default text
        UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureDefaultEntry)] autorelease];
        doubleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;
        [self.tfValue addGestureRecognizer:doubleTap];
        
        // two finger single tap: keyboard entry
        UITapGestureRecognizer *twoFingerSingleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureKeyboardEntry)] autorelease];
        twoFingerSingleTap.numberOfTouchesRequired = 2;
        twoFingerSingleTap.numberOfTapsRequired = 1;
        [self.tfValue addGestureRecognizer:twoFingerSingleTap];
        
        UIToolbar *tb = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 10, 30)] autorelease];
        tb.barStyle = UIBarStyleBlackTranslucent;
        UIBarButtonItem *bbispacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        
        UIImage *microImage = [UIImage imageNamed:@"tape4.png"];
        UIBarButtonItem *bbirec = [[[UIBarButtonItem alloc] initWithImage:microImage style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        UIBarButtonItem *bbiplay = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:nil action:nil] autorelease];
        UIBarButtonItem *bbicamera = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:nil] autorelease];
        tb.items = [NSArray arrayWithObjects:bbirec, bbispacer, bbicamera, bbispacer, bbiplay, nil];
        
        self.tfValue.inputAccessoryView = tb;
        [self layoutSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat currentWidth = self.frame.size.width;
    CGRect newFrame = CGRectMake(currentWidth - kInputOffsetRightEndFromRight - kInputWidthWide, kInputOffsetFromTop, kInputWidthWide, kInputHeight);
    self.tfValue.frame = newFrame;
    NSLog(@"layout ItemTableCellString: %@", NSStringFromCGRect(newFrame));
}

- (void)dealloc {
    self.lblContent = nil;
    self.tfValue = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Gestures
// -----------------------------------------------------------

- (void)gestureListOfChoices {
    // create a popover pointing to the entry field
}

- (void)gestureDefaultEntry {
    
}

- (void)gestureKeyboardEntry {
    [self.tfValue becomeFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Metrics
// -----------------------------------------------------------

+ (CGFloat)gadgetSpaceAdd:(CGFloat)oldSpace forItem:(IDRItem *)idrItem {
    return [super gadgetSpaceAdd:(oldSpace + kInputWidthWide + kInterGadgetSpace) forItem:idrItem];
}

@end
