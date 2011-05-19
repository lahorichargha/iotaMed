//
//  DemoData.h
//  iotaPad6
//
//  Created by Martin on 2011-02-11.
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
//  As the name says, this is where I put all the fake patients and patient data

#import <Foundation/Foundation.h>
#import "KlinKemProtocols.h"

@interface DemoData : NSObject {
    
}

+ (NSArray *)getDemoPatients;
+ (NSArray *)getDemoLabreports;

@end


@interface DemoKlinKemReferenceValue : NSObject <KlinKemReferenceValue> {
}
@property (nonatomic, readonly) NSString *gender;       // "M" or "F"
@property (nonatomic, readonly) NSString *analysisCode;
@property (nonatomic, readonly) NSString *lowestNormal;
@property (nonatomic, readonly) NSString *highestNormal;
@property (nonatomic, readonly) NSString *resultUnit;
@end

@interface DemoGraphAxisValue : NSObject {
}
@property (nonatomic, readonly) CGFloat minValue;
@property (nonatomic, readonly) CGFloat maxValue;
@property (nonatomic, readonly) CGFloat stepValue;
+ (DemoGraphAxisValue *)graphAxisValueForAnalysisCode:(NSString *)analysisCode;
@end

@interface DemoKlinLabResult : NSObject <KlinKemResult> {
}
@property (nonatomic, readonly) NSString *analysisCode;
@property (nonatomic, readonly) NSString *referenceInterval;
@property (nonatomic, readonly) NSString *resultValue;
@property (nonatomic, readonly) NSString *resultUnit;
@property (nonatomic, readonly) BOOL pathological;
@end

@interface DemoKlinLabReport : NSObject <KlinKemReport> {
}
@property (nonatomic, readonly) NSDate *samplesTaken;
@property (nonatomic, readonly) NSDate *resultReady;
@property (nonatomic, readonly) NSString *patientId;
@property (nonatomic, readonly) NSArray *analysisCodes;       // an array of strings

@property (nonatomic, retain) NSArray *results;               // an array of <KlinKemResult>
@end


@interface DemoKlinLabReports : NSObject <KlinKemReports> {
}

+ (NSArray *)klinKemReportsForPatientId:(NSString *)patientId;  // array of KlinKemReport

@end
