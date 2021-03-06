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

/*  ItemTableCell is the base class for a cluster of cell types:
    ItemTableCellContentOnly        Content text only, no inputs, no outputs.
    ItemTableCellString             Content and input and output for string values.
    ItemTableCellNumeric            Content and input and output for numeric values.
    ItemTableCellCheck              Content and input and output for tri-valued state (Yes/No/?).
    ItemTableCellSelect             Content, input and output. Allows selection of one of a list of
                                    values. Shows the selected value. Includes get with last value selected.
    ItemTableCellMultiSelect        Content, input and output. Allows selection of any number of values from
                                    a list. Allows both a history and a list of selected values.
    ItemTableCellAnalog             Content, input and output. Allow the setting of a value between a 
                                    minimum and a maximum value, or the selection of "no value".
    ItemTableCellImage              Content and a PNG image.
    ItemTableCellSvg                Content and an SVG image.
    ItemTableCellSvgInteractive     Content and an SVG image.
                                    Touching the image opens an editor. The edited image is saved as
                                    an observation value. Has a get field allowing the viewing of a history
                                    of edits of the same image.
 
    All these cell types can contain an action as well.
 
    Each subclass adds itself to the subclasses array using their own +(void)load class methods.
 
 */
 


#import "ItemTableCell.h"
#import "IDRItem.h"
#import "IDRImage.h"
#import "IDRBlock.h"
#import "IDRContact.h"
#import "IotaContext.h"

#import "TestFlight.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Constants
// -----------------------------------------------------------

static float kNormalFontSize        __attribute__ ((unused)) = 14.0;
static float kBoldFontSize          __attribute__ ((unused)) = 18.0;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface  ItemTableCell ()
@end

// holds a reference to all reported subclasses, so instances can be
// created when needed
static NSMutableArray *subclasses;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation ItemTableCell

@synthesize isActive = _isActive;
@synthesize idrItem = _idrItem;
@synthesize itemCellDelegate = _itemCellDelegate;
@synthesize parentTableView = _parentTableView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

// children must override and call super:
- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    if ((self = [super init])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.parentTableView = tableView;
        self.idrItem = idrItem;
        idrItem.itemTableCell = self;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    self.idrItem = nil;
    self.itemCellDelegate = nil;
    self.parentTableView = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Cluster class methods
// -----------------------------------------------------------

+ (void)load {
    [super load];
    subclasses = [[NSMutableArray alloc] initWithCapacity:5];
}

+ (void)addSubclass:(Class)cls {
    [subclasses addObject:cls];
}

+ (BOOL)canHandle:(IDRItem *)idrItem {
    [NSException raise:@"Should never be called" format:@"abstract canHandle called from %@", self];
    return NO;
}


+ (ItemTableCell *)subCellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCell *cell = idrItem.itemTableCell;
    if (cell == nil) {
        cell = [[[self alloc] initWithTableView:tableView idrItem:idrItem] autorelease];
    }
    else {
        [cell refreshDisplay];
    }
    return cell;
}

+ (CGFloat)subCellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    [NSException raise:@"Should never be called" format:@"abstract subCellHeightForTableView called from %@", self];
    return 5.0;
}

+ (ItemTableCell *)cellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    ItemTableCell *cell = nil;
    // we scan all the subclasses, just to be able to detect if the canHandle algorithm fails somewhere
    for (Class cls in subclasses) {
        if ([cls canHandle:idrItem]) {
            if (cell != nil) 
                [NSException raise:@"Ambiguous canHandle" format:@"Two different classes (%@ and %@) claim to handle the same IDRItem (%@)", [cell class], cls, idrItem.content];
            cell = [cls subCellForTableView:tableView idrItem:idrItem];
        }
    }
    if (cell == nil) {
        [NSException raise:@"No cell could be created for item" format:@"Item content: %@, description: %@", idrItem.content, idrItem.description];
    }
    return cell;
}

+ (CGFloat)cellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    for (Class cls in subclasses) {
        if ([cls canHandle:idrItem]) {
            return [cls subCellHeightForTableView:tableView idrItem:idrItem];
        }
    }
    return 0.0;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Metrics helpers
// -----------------------------------------------------------

+ (CGFloat)gadgetSpaceAdd:(CGFloat)oldSpace forItem:(IDRItem *)idrItem {
    return oldSpace;
}


+ (CGFloat)cellWidthForTableView:(UITableView *)tableView {
    return tableView.frame.size.width;
}

- (CGFloat)cellWidth {
    return self.parentTableView.frame.size.width;
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Class helper methods
// -----------------------------------------------------------

+ (UIFont *)boldContentFont {
    return [UIFont boldSystemFontOfSize:kBoldFontSize];
}

+ (UIFont *)normalContentFont {
    return [UIFont systemFontOfSize:kNormalFontSize];
}

+ (UIFont *)contentFontBold:(BOOL)bold {
    return (bold) ? [self boldContentFont] : [self normalContentFont];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Touch stuff
// -----------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // touch the worksheet anywhere to dismiss keyboard
    [self.parentTableView endEditing:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Should be overridden
// -----------------------------------------------------------

- (void)refreshDisplay {
    
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Utility functions
// -----------------------------------------------------------

- (CGRect)defaultRect {
    return CGRectMake(0, 0, 500, 44);
}

- (UIView *)viewOfClass:(Class)cls tag:(NSUInteger)tag {
    UIView *view = [[cls alloc] initWithFrame:[self defaultRect]];
    view.tag = tag;
    [self.contentView addSubview:view];
    return [view autorelease];
}

- (BOOL)isItemCurrentlyEnabled {
    IDRContact *currentContact = [[IotaContext getCurrentPatientContext] currentContact];
    IDRContact *itemContact = self.idrItem.parentBlock.contact;
    return (currentContact == itemContact);
}

@end
