//
//  PrescriptionDetailController.m
//  iotaPad6
//
//  Created by Martin on 2011-03-26.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "PrescriptionDetailController.h"
#import "IDRDose.h"
#import "IDRAction.h"
#import "IDRItem.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation PrescriptionDetailController

@synthesize idrItem = _idrItem;
@synthesize textView = _textView;
@synthesize idrDoseText = _idrDoseText;
@synthesize pdcDelegate = _pdcDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.idrItem = nil;
    self.textView = nil;
    self.idrDoseText = nil;
    self.pdcDelegate = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View lifecycle
// -----------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textView.text = self.idrDoseText;
    self.textView.delegate = self;
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

// -----------------------------------------------------------
#pragma mark -
#pragma mark Text view delegate
// -----------------------------------------------------------

- (void)textViewDidChange:(UITextView *)textView {
    [self.pdcDelegate takeDoseName:self.idrItem.action.name extendedDoseName:self.textView.text];
}

@end
