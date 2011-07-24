//
//  PatientDB.m
//  iotaPad6
//
//  Created by Martin on 2011-02-18.
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

#import "PatientDB.h"
#import "Patient.h"
#import "DemoData.h"
#import "IotaContext.h"
#import "PatientContextDB.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface PatientDB ()
@end




@implementation PatientDB

static NSString *kPatientKey = @"patientKey";


+ (NSString *)dataFilePathForPatientList {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"patientlist"];
}


+ (NSArray *)allPatients {
    if ([IotaContext namingOfPatients] == namingRealNames) {
        NSString *filePath = [self dataFilePathForPatientList];
        NSError *error = nil;
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:&error];
        if (error)
            NSLog(@"error: %@", error);
        if (files == nil || [files count] == 0)
            return nil;
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:5];
        for (NSString *fn in files) {
            NSString *fileName = [filePath stringByAppendingPathComponent:fn];
            NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:fileName];
            NSKeyedUnarchiver *unarch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            [data release];
            Patient *patient = [unarch decodeObjectForKey:kPatientKey];
            [unarch finishDecoding];
            [unarch release];
            [array addObject:patient];
        }
        return [array autorelease];
    }
    else {
        return [DemoData getDemoPatients];
    }
}

+ (void)addOrUpdatePatient:(Patient *)patient {
    NSString *path = [self dataFilePathForPatientList];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error)
        NSLog(@"createDirectoryAtPath error: %@", error);
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *arch = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [arch encodeObject:patient forKey:kPatientKey];
    [arch finishEncoding];
    [arch release];

    NSString *fullPath = [path stringByAppendingPathComponent:patient.patientID];
    [data writeToFile:fullPath atomically:YES];
    
    [data release];
}

+ (void)deletePatient:(Patient *)patient {
    NSString *fullPath = [[self dataFilePathForPatientList] stringByAppendingPathComponent:patient.patientID];
    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    [PatientContextDB deleteAllContextsForPatient:patient];
}


@end
