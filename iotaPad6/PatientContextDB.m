//
//  PatientContextDB.m
//  iotaPad6
//
//  Created by Martin on 2011-03-08.
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

#import "PatientContextDB.h"
#import "PatientContext.h"
#import "IotaContext.h"
#import "ServerConnect.h"
#import "ServerDiscovery.h"
#import "Notifications.h"
#import "Patient.h"
#import "IDRContact.h"
#import "IDRBlock.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRObsDefinition.h"
#import "IDRValue.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface PatientContextDB ()
@property (nonatomic, retain) NSString *patientID;
@property (nonatomic, retain) PatientContext *patientContext;
@property (nonatomic, retain) ServerConnect *serverConnect;
@property (nonatomic, retain) PatientContextDB *patientContextDb;

- (void)_loadDataFromMyIotaForPatient:(Patient *)patient;
#ifdef IOTAMED
- (void)_loadPatientContextForPatient:(Patient *)patient;
#endif
- (void)_putPatientContextToServer;
- (void)_putDataForMyIotaForPatient;

@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation PatientContextDB

@synthesize delegate = _delegate;
@synthesize patientID = _patientID;
@synthesize patientContext = _patientContext;
@synthesize serverConnect = _serverConnect;
@synthesize patientContextDb = _patientContextDb;

static NSString *kPatientContextKey = @"patientContextKey";

- (id)initForPatientID:(NSString *)patientID withPatientContext:(PatientContext *)patientContext {
    if ((self = [super init])) {
        self.patientID = patientID;
        self.patientContext = patientContext;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    self.patientContext = nil;
    self.patientID = nil;
    
    self.serverConnect = nil;
    
    self.patientContextDb = nil;
    [super dealloc];
}

- (void)stopConnect {
    self.serverConnect = nil;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Execs
// -----------------------------------------------------------

- (void)loadDataForPatient:(Patient *)patient {
    [self _loadDataFromMyIotaForPatient:patient];
#ifdef IOTAMED
    [self _loadPatientContextForPatient:patient];
#endif
}

- (void)putData {
#ifdef IOTAMED
    [self _putPatientContextToServer];
#endif
    [self _putDataForMyIotaForPatient];
}

#ifdef IOTAMED
- (void)_loadPatientContextForPatient:(Patient *)patient {
    NSLog(@"loadPatientContextForPatient: %@", patient.patientID);
    self.serverConnect = [[[ServerConnect alloc] init] autorelease];
    NSData *data = [self.serverConnect recvDataForPatient:patient.patientID datatype:eDataTypeCompleteRecord];
    PatientContext *pCtx = nil;
    if (data && [data length] > 0) {
        NSKeyedUnarchiver *unarch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        pCtx = [unarch decodeObjectForKey:kPatientContextKey];
        [unarch release];
    }
    else {
        pCtx = [[[PatientContext alloc] init] autorelease];
        pCtx.patient = patient;
    }
    [self.delegate loadFromDbDone:pCtx];
}
#endif

- (void)_loadDataFromMyIotaForPatient:(Patient *)patient {
    ServerConnect *srvConn = [[[ServerConnect alloc] init] autorelease];
    NSData *data = [srvConn recvDataForPatient:patient.patientID datatype:eDataTypePatientWorksheet];
    PatientContext *pCtx = nil;
    if (data && [data length] > 0) {
        NSKeyedUnarchiver *unarch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        pCtx = [unarch decodeObjectForKey:kPatientContextKey];
        [unarch release];
    }
    else {
        pCtx = [[[PatientContext alloc] init] autorelease];
        pCtx.patient = patient;
    }
    [self.delegate loadMyIotaFromDbDone:pCtx];
}

- (BOOL)_putContextToServer:(PatientContext *)ctx datatype:(enum eDataType)datatype {
    NSLog(@"_putContextToServer");
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
    NSKeyedArchiver *arch = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    arch.outputFormat = NSPropertyListXMLFormat_v1_0;
    [arch encodeObject:ctx forKey:kPatientContextKey];
    [arch finishEncoding];
    
    ServerConnect *sc = [[ServerConnect alloc] init];
    BOOL success = [sc sendData:dataToSend forPatientId:self.patientID datatype:datatype];
    
    [sc release];
    [arch release];
    [dataToSend release];
    return success;
}

- (void)_putPatientContextToServer {
    BOOL success = [self _putContextToServer:self.patientContext datatype:eDataTypeCompleteRecord];
    if (success)
        [self.patientContext setDirty:NO];
    [self.delegate saveToDbDone:success];
}

#ifdef IOTAMED
- (void)_putDataForMyIotaForPatient {
    NSLog(@"starting on _putDataForMyIotaForPatient");
    PatientContext *miCtx = [[PatientContext alloc] init];
    miCtx.patient = self.patientContext.patient;
    
    NSLog(@"putData, we have %d contacts", [self.patientContext.contacts count]);
    for (IDRContact *contact in self.patientContext.contacts) {
        NSLog(@"IDRContact has %d blocks", [contact.idrBlocks count]);
        for (IDRBlock *block in contact.idrBlocks) {
            if ([block blockType] == eBlockTypePatient) {
                IDRContact *myIotaContact = [[[IDRContact alloc] init] autorelease];
                IDRBlock *myBlock = [block copy];
                myBlock.contact = myIotaContact;
                //                myBlock.worksheet = nil;
                [myIotaContact.idrBlocks addObject:myBlock];
                [myBlock release];
                [miCtx.contacts addObject:myIotaContact];
            }
        }
    }
    
    BOOL success = [self _putContextToServer:miCtx datatype:eDataTypePatientWorksheet];
    [self.delegate saveMyIotaToDbDone:success];
    
    [miCtx release];
}
#endif

#ifdef MINIOTA
- (void)_putDataForMyIotaForPatient {
    BOOL success = [self _putContextToServer:self.patientContext datatype:eDataTypePatientWorksheet];
    if (success)
        [self.patientContext setDirty:NO];
    [self.delegate saveToDbDone:YES];
}
#endif


// -----------------------------------------------------------
#pragma mark -
#pragma mark Convenience constructors
// -----------------------------------------------------------


+ (NSString *)dataFilePathForPatientID:(NSString *)patientID {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:patientID];
}

+ (PatientContext *)getPatientContextFromLocalFileForPatientID:(NSString *)patientID {
    NSString *filePath = [self dataFilePathForPatientID:patientID];
    PatientContext *pctx = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [[NSMutableData alloc] initWithContentsOfFile:filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        pctx = [unarchiver decodeObjectForKey:kPatientContextKey];
        [unarchiver release];
        [data release];
    }
    else {
        pctx = [[[PatientContext alloc] init] autorelease];
    }
    return pctx;
}

+ (PatientContext *)getPatientContextFromServerForPatientID:(NSString *)patientID {
    return nil;
}

+ (PatientContext *)getPatientContextForPatientID:(NSString *)patientID {
    return [self getPatientContextFromLocalFileForPatientID:patientID];
}

+ (BOOL)putPatientContextInLocalFileForPatientID:(NSString *)patientID patientContext:(PatientContext *)patientContext {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //    archiver.outputFormat = NSPropertyListXMLFormat_v1_0;
    [archiver encodeObject:patientContext forKey:kPatientContextKey];
    [archiver finishEncoding];
    NSString *dStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"%@", dStr);
    [data writeToFile:[self dataFilePathForPatientID:patientID] atomically:YES];
    [data release];
    [archiver release];
    return YES;
}

+ (void)putPatientContextForPatientID:(NSString *)patientID patientContext:(PatientContext *)patientContext {
    PatientContextDB *pcdb = [[self alloc] initForPatientID:patientID withPatientContext:patientContext];
    [pcdb _putPatientContextToServer];
}




@end
