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

#import <UIKit/UIKit.h>
#import "ItemCellDelegate.h"
#import "IDRItem.h"

#define TAG_LBLCONTENT  1001
#define TAG_TEXTFIELD   1002
#define TAG_LBLVALUE    1003
#define TAG_LBLDATE     1004
#define TAG_IMAGE       1005
#define TAG_BULLET      1006
#define TAG_CHECKVIEW   1007

@interface ItemTableCell : UITableViewCell

@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) IDRItem *idrItem; // IDRItem owns this ItemTableCell
@property (nonatomic, retain) id <ItemCellDelegate> itemCellDelegate;
@property (nonatomic, assign) UITableView *parentTableView;

+ (ItemTableCell *)cellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem;
+ (CGFloat)cellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem;

+ (void)addSubclass:(Class)cls;
+ (BOOL)canHandle:(IDRItem *)idrItem;

- (id)initWithTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem;
- (UIView *)viewOfClass:(Class)cls tag:(NSUInteger)tag;

@end
