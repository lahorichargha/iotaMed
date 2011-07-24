//
//  IotaContext.m
//  iotaMed
//
//  Created by Martin on 2011-02-15.
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

#import "IotaContext.h"
#import "Patient.h"
#import "PatientContextDB.h"
#import "IDRWorksheet.h"
#import "IDRBlock.h"
#import "XML2IDR.h"
#import "IssueTemplateDB.h"
#import "IssueTemplateDescriptor.h"
#import "NSString+iotaAdditions.h"
#import "Notifications.h"
#import "IMServerDiscovery.h"
#import "MyIotaPatientContext.h"

#import "Patients.h"
#import "DemoData.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface IotaContext()

- (void)_addObserver:(id <IotaContextDelegate>) observer;
- (void)_removeObserver:(id <IotaContextDelegate>) observer;
- (void)_saveCurrentPatientContext;
- (void)_saveCurrentMyIotaPatientContext;
- (void)changeToPatient:(Patient *)newPatient;

@property (nonatomic, retain) NSMutableArray *observers;
@property (nonatomic, retain) PatientContext *currentPatientContext;
@property (nonatomic, retain) MyIotaPatientContext *currentMyIotaContext;

@property (nonatomic, retain) NSMutableDictionary *worksheets;
@property (nonatomic, retain) NSMutableDictionary *blocks;

@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Properties
// -----------------------------------------------------------

@implementation IotaContext

@synthesize observers = _observers;
@synthesize currentPatientContext = _currentPatientContext;
@synthesize currentMyIotaContext = _currentMyIotaContext;

@synthesize worksheets = _worksheets;
@synthesize blocks = _blocks;

// -----------------------------------------------------------
#pragma mark -
#pragma mark Singleton implementation
// -----------------------------------------------------------

static IotaContext * volatile _sharedInstance = nil;

+ (IotaContext *)_sharedInstance {
    if (_sharedInstance == nil) {
        @synchronized(self) {
            if (_sharedInstance == nil) {
                _sharedInstance = [[self alloc] init];
            }
        }
    }
    return _sharedInstance;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Object lifecycle
// -----------------------------------------------------------

- (id)init {
    if ((self = [super init])) {
        _observers = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryLowNotification:) name:kLowMemoryNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.observers = nil;
    self.currentPatientContext = nil;
    self.currentMyIotaContext = nil;
    self.worksheets = nil;
    self.blocks = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Class methods
// -----------------------------------------------------------


+ (void)addObserver:(id <IotaContextDelegate>)observer {
    [[self _sharedInstance] _addObserver:observer];
}

+ (void)removeObserver:(id <IotaContextDelegate>)observer {
    [[self _sharedInstance] _removeObserver:observer];
}

+ (void)changeToPatient:(Patient *)newPatient {
    [[self _sharedInstance] changeToPatient:newPatient];
}

+ (Patient *)getCurrentPatient {
    @synchronized(self) {
        if ([self _sharedInstance].currentPatientContext != nil)
            return [self _sharedInstance].currentPatientContext.patient;
        else
            return nil;
    }
}

+ (NSString *)nameOfCurrentUser {
    NSString *drName = [[NSUserDefaults standardUserDefaults] objectForKey:@"dr_name"];
    if ((drName == nil) || [drName length] < 1)
        return @"Dr Sistronberg";
    else
        return drName;
}

+ (NSString *)crossServerIPNumber {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"cross_ip"];
}

+ (CGFloat)minRowHeight {
    CGFloat rowHeight = [[[NSUserDefaults standardUserDefaults] objectForKey:@"minRowHeight"] floatValue];
    return fmax(rowHeight, 30.0);
}

+ (BOOL)useRemoteServer {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"remoteServer"] boolValue];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Templates index
// -----------------------------------------------------------

- (void)_loadWorksheetsAndBlocks {
    self.worksheets = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    self.blocks = [[[NSMutableDictionary alloc] initWithCapacity:25] autorelease];
    NSArray *descriptors = [IssueTemplateDB allTemplateDescriptors];
    for (IssueTemplateDescriptor *itd in descriptors) {
        if ([itd.resourceName iotaIsNonEmpty]) {
            IDRWorksheet *ws = itd.worksheet;
            [self.worksheets setObject:ws forKey:ws.templateUuid];
            for (IDRBlock *block in ws.blocks) {
                [self.blocks setObject:block forKey:block.templateUuid];
            }
        }
    }
}

- (IDRWorksheet *)_worksheetForUuid:(NSString *)uuid {
    if (_worksheets == nil) {
        [self _loadWorksheetsAndBlocks];
    }
    return [self.worksheets objectForKey:uuid];
}

- (IDRBlock *)_blockForUuid:(NSString *)uuid {
    if (_blocks == nil) {
        [self _loadWorksheetsAndBlocks];
    }
    return [self.blocks objectForKey:uuid];
}

+ (IDRWorksheet *)worksheetForUuid:(NSString *)uuid {
    return [[self _sharedInstance] _worksheetForUuid:uuid];
}

+ (IDRBlock *)blockForUuid:(NSString *)uuid {
    return [[self _sharedInstance] _blockForUuid:uuid];
}



// -----------------------------------------------------------
#pragma mark -
#pragma mark Patient context
// -----------------------------------------------------------

+ (PatientContext *)getCurrentPatientContext {
    @synchronized(self) {
        return [self _sharedInstance].currentPatientContext;
    }
}

+ (MyIotaPatientContext *)getCurrentMyIotaContext {
    @synchronized(self) {
        return [self _sharedInstance].currentMyIotaContext;
    }
}

+ (MyIotaPatientContext *)getOrCreateCurrentMyIotaContext {
    @synchronized(self) {
        MyIotaPatientContext *miCtx = [self getCurrentMyIotaContext];
        if (miCtx == nil) {
            miCtx = [[[MyIotaPatientContext alloc] init] autorelease];
            miCtx.patient = [self _sharedInstance].currentPatientContext.patient;
            [self _sharedInstance].currentMyIotaContext = miCtx;
        }
        return miCtx;
    }
}

+ (void)saveCurrentPatientContext {
    [[self _sharedInstance] _saveCurrentPatientContext];
}

+ (void)saveCurrentMyIotaPatientContext {
    [[self _sharedInstance] _saveCurrentMyIotaPatientContext];
}



// -----------------------------------------------------------
#pragma mark -
#pragma mark Instance methods
// -----------------------------------------------------------

- (Patient *)_currentPatient {
    if (self.currentPatientContext)
        return self.currentPatientContext.patient;
    else
        return nil;
}

- (void)memoryLowNotification:(NSNotification *)note {
    NSLog(@"Iotacontext low memory notification");
    self.worksheets = nil;
    self.blocks = nil;
}

- (void)_addObserver:(id <IotaContextDelegate>) observer {
    [_observers addObject:observer];
    // always reset client to start with
    [observer didSwitchToPatient:[self _currentPatient]];  
}

- (void)_removeObserver:(id <IotaContextDelegate>) observer {
    [_observers removeObject:observer];
}


- (void)changeToPatient:(Patient *)newPatient {
    @synchronized(self) {
        if (self.currentPatientContext != nil) {
            [PatientContextDB putPatientContext:self.currentPatientContext];
        }
        PatientContext *pCtx = [PatientContextDB getPatientContextForPatient:newPatient];
        if (pCtx == nil) {
            NSLog(@"Failed to load new patient: %@", [Patient buttonTitleForPatient:newPatient]);
            [[NSNotificationCenter defaultCenter] postNotificationName:kPatientChangeEnded object:[NSNumber numberWithBool:NO]];
        }
        // miCtx does not necessarily have to exist, so a nil return is not unexpected
        MyIotaPatientContext *miCtx = [PatientContextDB getMyIotaPatientContextForPatient:newPatient];
        
        if (newPatient != nil && newPatient != [self _currentPatient]) {
            for (id<IotaContextDelegate> observer in _observers) {
                if (![observer willSwitchFromPatient:[self _currentPatient]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPatientChangeEnded object:[NSNumber numberWithBool:NO]];
                    return;
                }
            }
            
            self.currentPatientContext = pCtx;
            self.currentMyIotaContext = miCtx;
            
            for (id<IotaContextDelegate> observer in _observers) {
                [observer didSwitchToPatient:pCtx.patient];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kPatientChangeEnded object:[NSNumber numberWithBool:YES]];
        }
        
    }
}


- (void)_saveCurrentPatientContext {
    @synchronized(self) {
        NSLog(@"saveCurrentPatientContext: %@", self.currentPatientContext.patient.patientID);
        PatientContext *pCtx = self.currentPatientContext;
        if (pCtx != nil) {
            [PatientContextDB putPatientContext:pCtx];
        }
    }
}

- (void)_saveCurrentMyIotaPatientContext {
    @synchronized(self) {
        NSLog(@"saveCurrentMyIotaPatientContext");
        MyIotaPatientContext *miCtx = self.currentMyIotaContext;
        if (miCtx != nil) {
            [PatientContextDB putMyIotaPatientContext:miCtx];
        }
    }
}



@end
