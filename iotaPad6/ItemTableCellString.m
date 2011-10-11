//
//  ItemTableCellString.m
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

#import "ItemTableCellString.h"
#import "IDRObservation.h"
#import "IDRItem.h"
#import "IDRValue.h"
#import "NSString+iotaAdditions.h"
#import "IDRPrompt.h"

#import "IDRObsDef.h"
#import "PatientContext.h"
#import "IotaContext.h"
#import "Funcs.h"
#import "Notifications.h"

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
    return [idrItem hasObservation] && [idrItem hasInput] && ![idrItem.observation isNumeric] && ![idrItem.observation isCheck] &&
        ![idrItem.observation isSelect] && ![idrItem.observation isMultiSelect];
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
        self.tfValue.text = [idrItem getItemValue].value;
        // add symbolview here
        
        
        NSString *contentText = self.lblContent.text;
        if (contentText == nil || ![self.lblContent.text iotaIsNonEmpty]) {
            NSString *obsName = idrItem.observation.name;
            PatientContext *pCtx = [IotaContext getCurrentPatientContext];
            IDRObsDef *obsDef = [pCtx getObsDefForName:obsName];
            if (obsDef == nil)
                postAlert([NSString stringWithFormat:@"Definition not found in data dictionary: %@", obsName]);
            IDRPrompt *prompt = [obsDef promptForPreferredLanguage];
            if (prompt != nil)
                self.lblContent.text = prompt.promptString;
        }

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
}

- (void)dealloc {
    self.lblContent = nil;
    self.tfValue = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Metrics
// -----------------------------------------------------------

+ (CGFloat)gadgetSpaceAdd:(CGFloat)oldSpace forItem:(IDRItem *)idrItem {
    return [super gadgetSpaceAdd:(oldSpace + kInputWidthWide + kInterGadgetSpace) forItem:idrItem];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Other stuff
// -----------------------------------------------------------

- (void)refreshDisplay {
    self.tfValue.text = [self.idrItem getItemValue].value;
}

- (void)writeCurrent {
    NSString *newText = self.tfValue.text;
    [self.idrItem setItemValue:newText];
    [[NSNotificationCenter defaultCenter] postNotificationName:kObservationDataChangedNotification object:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // when text field begins editing, the keyboard is not yet fully deployed
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardDidShow:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:nil];
}

- (void)keyboardDidShow:(NSNotification *)n {
    // now the keyboard is fully deployed and we can center the view right
    // we also have to remove the notification right away, else any other cell that gets
    // activated will make this one try to center itself again; not such a great idea
    NSIndexPath *indexPath = [self.parentTableView indexPathForCell:self];
    [self.parentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardDidShowNotification 
                                                  object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [self writeCurrent];
}

@end
