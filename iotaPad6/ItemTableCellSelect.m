//
//  ItemTableCellSelect.m
//  iotaPad6
//
//  Copyright © 2011, MITM AB, Sweden
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1.  Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//  2.  Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//  3.  Neither the name of MITM AB nor the name iotaMed®, nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY MITM AB ‘’AS IS’’ AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MITM AB BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "ItemTableCellSelect.h"
#import "IDRObservation.h"
#import "IDRObsDef.h"
#import "ItemSelectController.h"
#import "ItemSelectViewController.h"
#import "IDRSelect.h"
#import "UIView+iotaExtensions.h"

static CGFloat kButtonWidth = 52.0;
static CGFloat kButtonHeight = 26.0;
static CGFloat kButtonOffsetRight = 40.0;    // from gadget to the right

@interface ItemTableCellSelect()
@property (nonatomic, retain) UIButton *btnSelect;
@property (nonatomic, retain) UIPopoverController *popOver;
@end

@implementation ItemTableCellSelect

@synthesize btnSelect = _btnSelect;
@synthesize popOver = _popOver;

+ (void)load {
    [super addSubclass:self];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    if ([idrItem.observation.obsDef obsDefType] == eObsDefTypeSelect)
        return YES;
    else
        return NO;
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    return [super subCellHeightForTableView:tableView idrItem:idrItem];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

- (void)addGestureRecognizers {
    // remove all recognizers that may already be there (becoming first responder sets up a truckload of them)
    for (UIGestureRecognizer *gr in self.tfValue.gestureRecognizers) {
        [self.tfValue removeGestureRecognizer:gr];
    }
    
    // single tap: pop up list of choices, including default, manual text, dictation, clear
    UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureListOfChoices)] autorelease];
    singleTap.numberOfTouchesRequired = 1;
    singleTap.numberOfTapsRequired = 1;
    // reactivate this one when you have a popup working for edit fields
    [self.tfValue addGestureRecognizer:singleTap];
    
    // double tap, one finger: enter default text
    UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureDefaultEntry)] autorelease];
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    [self.tfValue addGestureRecognizer:doubleTap];
    
    // we have to stop the single tap from firing before its time:
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // two finger single tap: keyboard entry
    UITapGestureRecognizer *twoFingerSingleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureKeyboardEntry)] autorelease];
    twoFingerSingleTap.numberOfTouchesRequired = 2;
    twoFingerSingleTap.numberOfTapsRequired = 1;
    [self.tfValue addGestureRecognizer:twoFingerSingleTap];
}

- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    if ((self = [super initWithTableView:tableView idrItem:idrItem])) {
        _btnSelect = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonHeight)];
        [_btnSelect setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
        [_btnSelect addTarget:self action:@selector(btnSelectPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnSelect];
        
        [self addGestureRecognizers];
    }
    return self;
}

- (void)dealloc {
    self.btnSelect = nil;
    self.popOver = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View lifecycle
// -----------------------------------------------------------

- (void)layoutSubviews {
    [super layoutSubviews];
    self.btnSelect.frame = CGRectMake(self.frame.size.width - kInputOffsetRightEndFromRight - kButtonOffsetRight, kInputOffsetFromTop, kButtonWidth, kButtonHeight);
}

+ (CGFloat)gadgetSpaceAdd:(CGFloat)oldSpace forItem:(IDRItem *)idrItem {
    CGFloat superSpace = [super gadgetSpaceAdd:oldSpace forItem:idrItem];
    return  superSpace + kButtonOffsetRight + kButtonWidth;
}

- (void)btnSelectPressed:(id)sender {
    ItemSelectViewController *isvc = [[ItemSelectViewController alloc] initWithNibName:@"ItemSelectViewController" bundle:nil];
    isvc.delegate = self;
    self.popOver = [[UIPopoverController alloc] initWithContentViewController:isvc];
    [isvc release];
    CGSize size = [ItemSelectViewController neededSizeForRows:[self.selectPrompts count]];
    [self.popOver setPopoverContentSize:size];
    [self.popOver presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    [self.parentTableView findAndResignFirstResponder];
}

// overrides the one from ItemTableCellString
- (void)gestureListOfChoices {
    if (self.selectPrompts && [self.selectPrompts count] > 0)
        [self btnSelectPressed:nil];
    else
        [self.tfValue becomeFirstResponder];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Gestures
// -----------------------------------------------------------

- (void)gestureDefaultEntry {
    NSString *defaultValue = [self.idrItem.observation.obsDef defaultSelect];
    if (defaultValue == nil) 
        [self gestureListOfChoices];
    else {
        self.tfValue.text = defaultValue;
        [self writeCurrent];
    }
}   

- (void)gestureKeyboardEntry {
    [self.tfValue becomeFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark ItemSelectControllerDelegate
// -----------------------------------------------------------

- (NSArray *)selectPrompts {
    NSArray *arr = self.idrItem.observation.obsDef.selects;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[arr count]];
    for (IDRSelect *select in arr) {
        [result addObject:[select promptForPreferredLanguage]];
    }
    return [result autorelease];
}

- (NSArray *)selectValues {
    NSArray *arr = self.idrItem.observation.obsDef.selects;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[arr count]];
    for (IDRSelect *select in arr) {
        [result addObject:[select value]];
    }
    return [result autorelease];
}

- (void)selectedValues:(NSArray *)selected {
    IDRSelect *sel = [self.idrItem.observation.obsDef getSelectWithValue:[selected objectAtIndex:0]]; 
    NSString *value = [sel promptForPreferredLanguage];
    self.tfValue.text = value;
    [self writeCurrent];
    [self.popOver dismissPopoverAnimated:YES];
}

- (void)neededSize:(CGSize)size {
    [self.popOver setPopoverContentSize:size animated:YES];
}

- (void)showKeyboard {
    //    [self.popOver dismissPopoverAnimated:YES];
    [self.tfValue becomeFirstResponder];
    [self.popOver dismissPopoverAnimated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidEndEditing:textField];
    [self writeCurrent];
    [self addGestureRecognizers];
}



- (void)done {
    
}


@end
