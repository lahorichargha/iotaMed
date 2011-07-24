//
//  PatientContextDB.m
//  iotaMed
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
#import "IMServerConnect.h"
#import "IMServerDiscovery.h"
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
//@property (nonatomic, retain) NSString *patientID;
//@property (nonatomic, retain) PatientContext *patientContext;
//@property (nonatomic, retain) ServerConnect *serverConnect;
//@property (nonatomic, retain) PatientContextDB *patientContextDb;

- (NSString *)dataFilePathForPatientId:(NSString *)patientId;
- (NSString *)dataFilePathForPatientId:(NSString *)patientId subFolder:(NSString *)subFolder;
- (BOOL)_putMyIotaPatientContext:(MyIotaPatientContext *)myIotaPatientContext;
- (BOOL)_putPatientContext:(PatientContext *)patientContext;
@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation PatientContextDB

static NSString *kPatientContextKey = @"patientContextKey";
static NSString *kMyIotaPatientContextKey = @"myIotaPatientContextKey";


- (void)dealloc {
    [super dealloc];
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Execs
// -----------------------------------------------------------

- (PatientContext *)_getPatientContextForPatient:(Patient *)patient {
    IMServerConnect *sc = [[IMServerConnect alloc] init];
    NSData *data = [sc recvDataForPatient:patient.patientID datatype:eDataTypeCompleteRecord];
    [sc release];
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
    return pCtx;
}

- (MyIotaPatientContext *)_getMyIotaPatientContextForPatient:(Patient *)patient {
    IMServerConnect *sc = [[IMServerConnect alloc] init];
    NSData *data = [sc recvDataForPatient:patient.patientID datatype:eDataTypePatientWorksheet];
    [sc release];
    MyIotaPatientContext *miCtx = nil;
    if (data && [data length] > 0) {
        NSKeyedUnarchiver *unarch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        miCtx = [unarch decodeObjectForKey:kMyIotaPatientContextKey];
        [unarch release];
    }
    return miCtx;
}

- (BOOL)_putPatientContext:(PatientContext *)ctx {
    NSLog(@"_putContextToServer");
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
    NSKeyedArchiver *arch = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    arch.outputFormat = NSPropertyListXMLFormat_v1_0;
    [arch encodeObject:ctx forKey:kPatientContextKey];
    [arch finishEncoding];
    
    IMServerConnect *sc = [[IMServerConnect alloc] init];
    BOOL success = [sc sendData:dataToSend forPatientId:ctx.patient.patientID datatype:eDataTypeCompleteRecord];
    
    [sc release];
    [arch release];
    [dataToSend release];
    return success;
}

- (BOOL)_putMyIotaPatientContext:(MyIotaPatientContext *)miCtx {
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
    NSKeyedArchiver *arch = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    arch.outputFormat = NSPropertyListXMLFormat_v1_0;
    [arch encodeObject:miCtx forKey:kMyIotaPatientContextKey];
    [arch finishEncoding];
    
    IMServerConnect *sc = [[IMServerConnect alloc] init];
    NSString *patientID = miCtx.patient.patientID;
    BOOL success = [sc sendData:dataToSend forPatientId:patientID datatype:eDataTypePatientWorksheet];
    
    [sc release];
    [arch release];
    [dataToSend release];
    return success;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Alternates used when running without a server, just local files
// -----------------------------------------------------------

- (PatientContext *)_getPatientContextForPatientFromFile:(Patient *)patient {
    NSString *filePath = [self dataFilePathForPatientId:patient.patientID];
    PatientContext *pCtx = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [[NSMutableData alloc] initWithContentsOfFile:filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        pCtx = [unarchiver decodeObjectForKey:kPatientContextKey];
        [unarchiver release];
        [data release];
    }
    else {
        pCtx = [[[PatientContext alloc] init] autorelease];
        pCtx.patient = patient;
    }
    return pCtx;
}

- (MyIotaPatientContext *)_getMyIotaPatientContextForPatientFromFile:(Patient *)patient {
    NSString *filePath = [self dataFilePathForPatientId:patient.patientID subFolder:@"minIota"];
    MyIotaPatientContext *miCtx = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [[NSMutableData alloc] initWithContentsOfFile:filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        miCtx = [unarchiver decodeObjectForKey:kMyIotaPatientContextKey];
        [unarchiver release];
        [data release];
    }
    else {
        miCtx = [[[MyIotaPatientContext alloc] init] autorelease];
    }
    return miCtx;
}

- (BOOL)_putPatientContextToFile:(PatientContext *)pCtx {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:pCtx forKey:kPatientContextKey];
    [archiver finishEncoding];
    
    NSString *filePath = [self dataFilePathForPatientId:pCtx.patient.patientID];
    [data writeToFile:filePath atomically:YES];
    [archiver release];
    [data release];
    return YES;
}

- (BOOL)_putMyIotaPatientContextToFile:(MyIotaPatientContext *)miCtx {
    NSMutableData *dataToSend = [[NSMutableData alloc] init];
    NSKeyedArchiver *arch = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    //    arch.outputFormat = NSPropertyListXMLFormat_v1_0;
    [arch encodeObject:miCtx forKey:kMyIotaPatientContextKey];
    [arch finishEncoding];
    
    NSString *filePath = [self dataFilePathForPatientId:miCtx.patient.patientID subFolder:@"minIota"];
    [dataToSend writeToFile:filePath atomically:YES];
    
    [arch release];
    [dataToSend release];
    return YES;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Helpers
// -----------------------------------------------------------

- (NSString *)dataFilePathForPatientId:(NSString *)patientId subFolder:(NSString *)subFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:subFolder];
    return [documentsDirectory stringByAppendingPathComponent:patientId];
}

- (NSString *)dataFilePathForPatientId:(NSString *)patientId {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:patientId];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Convenience constructors
// -----------------------------------------------------------


+ (PatientContext *)getPatientContextForPatient:(Patient *)patient {
    PatientContextDB *pcdb = [[[self alloc] init] autorelease];
    if ([IotaContext useRemoteServer]) 
        return [pcdb _getPatientContextForPatient:patient];
    else 
        return [pcdb _getPatientContextForPatientFromFile:patient];
}

+ (MyIotaPatientContext *)getMyIotaPatientContextForPatient:(Patient *)patient {
    PatientContextDB *pcdb = [[[self alloc] init] autorelease];
    if ([IotaContext useRemoteServer]) 
        return [pcdb _getMyIotaPatientContextForPatient:patient];
    else
        return [pcdb _getMyIotaPatientContextForPatientFromFile:patient];
}

+ (BOOL)putPatientContext:(PatientContext *)patientContext {
    PatientContextDB *pcdb = [[[self alloc] init] autorelease];
    if ([IotaContext useRemoteServer]) 
        return [pcdb _putPatientContext:patientContext];
    else 
        return [pcdb _putPatientContextToFile:patientContext];
}

+ (BOOL)putMyIotaPatientContext:(MyIotaPatientContext *)myIotaPatientContext {
    PatientContextDB *pcdb = [[[self alloc] init] autorelease];
    if ([IotaContext useRemoteServer]) 
        return [pcdb _putMyIotaPatientContext:myIotaPatientContext];
    else
        return [pcdb _putMyIotaPatientContextToFile:myIotaPatientContext];
}


@end
