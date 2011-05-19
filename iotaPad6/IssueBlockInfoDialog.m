//
//  IssueBlockInfoDialog.m
//  iotaPad6
//
//  Created by Martin on 2011-03-09.
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

#import "IssueBlockInfoDialog.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface IssueBlockInfoDialog ()
@property (nonatomic, assign) BOOL okPressed;
@end


@implementation IssueBlockInfoDialog
@synthesize okPressed = _okPressed;
@synthesize mainTitle = _mainTitle;
@synthesize explanation = _explanation;
@synthesize customTitle = _customTitle;

@synthesize lblMainTitle = _lblMainTitle;
@synthesize lblExplanation = _lblExplanation;
@synthesize fldCustomTitle = _fldCustomTitle;
@synthesize okButton = _okButton;
@synthesize cancelButton = _cancelButton;
@synthesize action = _action;
@synthesize parent = _parent;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.mainTitle = nil;
    self.explanation = nil;
    self.customTitle = nil;
    self.lblMainTitle = nil;
    self.lblExplanation = nil;
    self.fldCustomTitle = nil;
    self.okButton = nil;
    self.cancelButton = nil;
    self.action = nil;
    [super dealloc];
    // dum kommentar

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Convenience
// -----------------------------------------------------------

+ (void)getCustomTitle:(NSString *)mainTitle explanation:(NSString *)explanation parentView:(UIViewController *)parent action:(SEL)action {
    IssueBlockInfoDialog *dlg = [[self alloc] initWithNibName:@"IssueBlockInfoDialog" bundle:nil];
    dlg.action = action;
    dlg.parent = parent;
    
    dlg.mainTitle = mainTitle;
    dlg.explanation = explanation;
    
    
    dlg.modalPresentationStyle = UIModalPresentationFormSheet;
    dlg.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [parent presentModalViewController:dlg animated:YES];
    [dlg release];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View lifecycle
// -----------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lblMainTitle.text = self.mainTitle;
    self.lblExplanation.text = self.explanation;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.okPressed)
        [self.parent performSelectorOnMainThread:self.action withObject:self.fldCustomTitle.text waitUntilDone:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------

- (IBAction)okButton:(id)sender {
    self.okPressed = YES;
    [self dismissModalViewControllerAnimated:YES];
    //    [self.parent performSelectorOnMainThread:self.action withObject:self.fldCustomTitle.text waitUntilDone:YES];
}

- (IBAction)cancelButton:(id)sender {
    self.okPressed = NO;
    [self dismissModalViewControllerAnimated:YES];
}

@end
