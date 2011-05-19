//
//  DemoData.m
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

#import "DemoData.h"
#import "Patient.h"
#import "Funcs.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark DemoData
// -----------------------------------------------------------

@implementation DemoData

static NSArray *demoPatients = nil;

#define PATDEF(I, F, L)   [Patient patientWithID:I firstName:F lastName:L]

+ (NSArray *)getDemoPatients {
    if (demoPatients == nil) {
        demoPatients = [NSArray arrayWithObjects:
                        PATDEF(@"19010101-0101", @"Hannibal", @"Lecter"),
                        PATDEF(@"19121212-1212", @"Tolvan", @"Tolvansson"),
                        PATDEF(@"19480303-5916", @"Rune", @"Röding"),
                        PATDEF(@"19670505-3723", @"Lilian", @"Adensjö"),
                        PATDEF(@"19520806-2223", @"Svea", @"Norden"),
                        PATDEF(@"19300320-1880", @"Catarina", @"Lundblad"),
                        PATDEF(@"19540303-0306", @"Laila", @"Lorentzon"),
                        PATDEF(@"19480210-1685", @"Linda", @"Ljung"),
                        PATDEF(@"19340404-2131", @"Anders", @"Ahl"),
                        PATDEF(@"19111111-1111", @"Elvis", @"Elfenben"),
                        PATDEF(@"19101010-1010", @"Tiro", @"Decadron"),
                        PATDEF(@"19090909-0909", @"Dodeca", @"Hedron"),
                        PATDEF(@"19080808-0808", @"Lisa", @"Hydro"),
                        PATDEF(@"19000919-7369", @"Apfella", @"Skrutt"),
                        nil];
        [demoPatients retain];
    }
    return demoPatients;
}

+ (NSArray *)getDemoLabreports {
    return nil;
}

@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Demo reference values
// -----------------------------------------------------------

@implementation DemoKlinKemReferenceValue

@synthesize gender = _gender; 
@synthesize analysisCode = _analysisCode;
@synthesize lowestNormal = _lowestNormal;
@synthesize highestNormal = _highestNormal;
@synthesize resultUnit = _resultUnit;

- (void)dealloc {
    [_gender release]; 
    [_analysisCode release];
    [_lowestNormal release];
    [_highestNormal release];
    [_resultUnit release];
    [super dealloc];
}

- (id)initWithAnalysisCode:(NSString *)analysisCode gender:(NSString *)gender lowestNormal:(NSString *)lowestNormal
             highestNormal:(NSString *)highestNormal resultUnit:(NSString *)resultUnit {
    if ((self = [super init])) {
        _gender = [gender copy];
        _analysisCode = [analysisCode copy];
        _lowestNormal = [lowestNormal copy];
        _highestNormal = [highestNormal copy];
        _resultUnit = [resultUnit copy];
    }
    return self;
}

#define REFVALDEF(G,A,L,H,U) if([analysisCode isEqualToString:A] && [gender isEqualToString:G]) \
    return [[[DemoKlinKemReferenceValue alloc] initWithAnalysisCode:A gender:G lowestNormal:L highestNormal:H resultUnit:U] autorelease]

+ (DemoKlinKemReferenceValue *)referenceForAnalysisCode:(NSString *)analysisCode gender:(NSString *)gender {
    REFVALDEF(@"M", @"Hb", @"134", @"170", @"g/L");
    REFVALDEF(@"F", @"Hb", @"117", @"153", @"g/L");
    REFVALDEF(@"M", @"Na", @"137", @"145", @"mmol/L");
    REFVALDEF(@"F", @"Na", @"137", @"145", @"mmol/L");
    REFVALDEF(@"M", @"K", @"3.5", @"5.0", @"mmol/L");
    REFVALDEF(@"F", @"K", @"3.5", @"5.0", @"mmol/L");
    REFVALDEF(@"M", @"Fe", @"9", @"34", @"µmol/L");
    REFVALDEF(@"F", @"Fe", @"9", @"34", @"µmol/L");
    REFVALDEF(@"M", @"Glukos", @"5.0", @"6.8", @"mmol/L");
    REFVALDEF(@"F", @"Glukos", @"5.0", @"6.8", @"mmol/L");
    REFVALDEF(@"M", @"HbA1c", @"4.8", @"6.0", @"%");
    REFVALDEF(@"F", @"HbA1c", @"4.8", @"6.0", @"%");
    return nil;
}

@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Demo graph axis values
// -----------------------------------------------------------

@implementation DemoGraphAxisValue

@synthesize minValue = _minValue;
@synthesize maxValue = _maxValue;
@synthesize stepValue = _stepValue;

- (id)initWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue stepValue:(CGFloat)stepValue {
    if ((self = [super init])) {
        _minValue = minValue;
        _maxValue = maxValue;
        _stepValue = stepValue;
    }
    return self;
}

#define GRAPHVALDEF(AC,MIN,MAX,STEP) if ([analysisCode isEqualToString:AC]) \
    return [[[DemoGraphAxisValue alloc] initWithMinValue:MIN maxValue:MAX stepValue:STEP] autorelease]

+ (DemoGraphAxisValue *)graphAxisValueForAnalysisCode:(NSString *)analysisCode {
    GRAPHVALDEF(@"Hb", 50.0, 200.0, 20.0);
    GRAPHVALDEF(@"Na", 120.0, 160.0, 5.0);
    GRAPHVALDEF(@"K", 2.0, 8.0, 1.0);
    GRAPHVALDEF(@"Fe", 5.0, 50.0, 5.0);
    GRAPHVALDEF(@"Glukos", 0.0, 30.0, 5.0);
    GRAPHVALDEF(@"HbA1c", 3.0, 15.0, 1.0);
    return nil;
}

@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Demo Lab Result
// -----------------------------------------------------------

@implementation DemoKlinLabResult

@synthesize analysisCode = _analysisCode;
@synthesize referenceInterval = _referenceInterval;
@synthesize resultValue = _resultValue;
@synthesize resultUnit = _resultUnit;
@synthesize pathological = _pathological;


- (id)initWithAnalysisCode:(NSString *)analysisCode referenceInterval:(NSString *)referenceInterval
               resultValue:(NSString *)resultValue resultUnit:(NSString *)resultUnit pathological:(BOOL)pathological {
    if ((self = [super init])) {
        _analysisCode = [analysisCode copy];
        _referenceInterval = [referenceInterval copy];
        _resultValue = [resultValue copy];
        _resultUnit = [resultUnit copy];
        _pathological = pathological;
    }
    return self;
}

- (id)initWithReference:(DemoKlinKemReferenceValue *)referenceValue resultValue:(NSString *)resultValue pathological:(BOOL)pathological {
    NSString *referenceInterval = [NSString stringWithFormat:@"%@ - %@", referenceValue.lowestNormal, referenceValue.highestNormal];
    self = [self initWithAnalysisCode:referenceValue.analysisCode referenceInterval:referenceInterval resultValue:resultValue 
                           resultUnit:referenceValue.resultUnit pathological:pathological];
    return self;
}


+ (DemoKlinLabResult *)resultForAnalysisCode:(NSString *)analysisCode referenceInterval:(NSString *)referenceInterval
                         resultValue:(NSString *)resultValue resultUnit:(NSString *)resultUnit pathological:(BOOL)pathological {
    return [[[self alloc] initWithAnalysisCode:analysisCode referenceInterval:referenceInterval 
                                   resultValue:resultValue resultUnit:resultUnit pathological:pathological] autorelease];
}

+ (DemoKlinLabResult *)resultWithReference:(DemoKlinKemReferenceValue *)referenceValue resultValue:(NSString *)resultValue pathological:(BOOL)pathological {
    return [[[self alloc] initWithReference:referenceValue resultValue:resultValue pathological:pathological] autorelease];
}

#define LABRESULT(C,I,V,U,P) return[self resultForAnalysisCode:C referenceInterval:I resultValue:V resultUnit:U pathological:P]; break


- (void)dealloc {
    [_analysisCode release];
    [_referenceInterval release];
    [_resultValue release];
    [_resultUnit release];
    [super dealloc];
}


@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Demo Lab Report
// -----------------------------------------------------------

@implementation DemoKlinLabReport

@synthesize samplesTaken = _samplesTaken;
@synthesize resultReady = _resultReady;
@synthesize patientId = _patientId;
@synthesize analysisCodes = _analysisCodes;
@synthesize results = _results;

- (void)dealloc {
    [_samplesTaken release];
    [_resultReady release];
    [_patientId release];
    [_results release];
    [super dealloc];
}

- (id)initWithPatientId:(NSString *)patientId samplesTaken:(NSDate *)samplesTaken resultReady:(NSDate *)resultReady results:(NSArray *)results {
    if ((self = [super init])) {
        _samplesTaken = [samplesTaken copy];
        _resultReady = [resultReady copy];
        _patientId = [patientId copy];
        _results = [results copy];
    }
    return self;
}

+ (DemoKlinLabReport *)reportForPatientId:(NSString *)patientId samplesTaken:(NSDate *)samplesTaken resultReady:(NSDate *)resultReady
                                  results:(NSArray *)results {
    return [[[self alloc] initWithPatientId:patientId samplesTaken:samplesTaken resultReady:resultReady results:results] autorelease];
}

- (NSArray *)analysisCodes {
    NSMutableArray *codes = [[NSMutableArray alloc] initWithCapacity:[_results count]];
    for (id <KlinKemResult> result in _results)
        [codes addObject:result.analysisCode];
    return [codes autorelease];
}

- (id <KlinKemResult>)getResultForCode:(NSString *)analysisCode {
    for (id <KlinKemResult> result in _results)
        if ([result.analysisCode isEqualToString:analysisCode])
            return [[result retain] autorelease];
    return nil;
}


+ (DemoKlinLabReport *)getReportForPatientID:(NSString *)patientId reportNumber:(NSUInteger)reportNumber {
    return nil;
}

    


@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Demo Lab Reports
// -----------------------------------------------------------

#define PATIENTREPORTS(P) if ([patientId isEqualToString:P]) return [NSArray arrayWithObjects:
#define REPORT(T,R) [DemoKlinLabReport reportForPatientId:patientId samplesTaken:str2date(T) resultReady:str2date(R) results:[NSArray arrayWithObjects:
#define RESWREF(A,G,V,P) [DemoKlinLabResult resultWithReference:[DemoKlinKemReferenceValue referenceForAnalysisCode:A gender:G] resultValue:V pathological:P],
#define REPORTEND nil]],
#define PATIENTREPORTSEND nil];



@implementation DemoKlinLabReports

- (void)dealloc {
    [super dealloc];
}

+ (NSArray *)klinKemReportsForPatientId:(NSString *)patientId {
    
    
    PATIENTREPORTS(@"010101-0101")
    REPORT(@"2011-02-18 17:36", @"2011-02-19 09:34")
    RESWREF(@"Hb", @"F", @"112", YES)
    RESWREF(@"K", @"F", @"3.8", NO)
    REPORTEND
    
    REPORT(@"2011-03-14 11:32", @"2011-03-14 15:50")
    RESWREF(@"Hb", @"F", @"118", NO)
    RESWREF(@"K", @"F", @"4.2", NO)
    REPORTEND
    PATIENTREPORTSEND
    
    PATIENTREPORTS(@"121212-1212")
    REPORT(@"2011-02-18 17:36", @"2011-02-19 09:34")
    RESWREF(@"Hb", @"F", @"112", YES)
    RESWREF(@"K", @"F", @"3.8", NO)
    REPORTEND
    
    REPORT(@"2011-03-14 11:32", @"2011-03-14 15:50")
    RESWREF(@"Hb", @"F", @"118", NO)
    RESWREF(@"K", @"F", @"4.2", NO)
    REPORTEND
    PATIENTREPORTSEND
    
    PATIENTREPORTS(@"111111-1111")
    REPORT(@"2011-02-18 17:36", @"2011-02-19 09:34")
    RESWREF(@"Hb", @"F", @"112", YES)
    RESWREF(@"K", @"F", @"3.8", NO)
    RESWREF(@"Glukos", @"F", @"8.8", YES)
    RESWREF(@"HbA1c", @"F", @"7.4", YES)
    REPORTEND
    
    REPORT(@"2011-03-14 11:32", @"2011-03-14 15:50")
    RESWREF(@"Hb", @"F", @"118", NO)
    RESWREF(@"K", @"F", @"4.2", NO)
    RESWREF(@"Glukos", @"F", @"7.1", YES)
    RESWREF(@"HbA1c", @"F", @"7.8", YES)
    REPORTEND
    
    REPORT(@"2011-04-01 09:05", @"2011-04-02 18:54")
    RESWREF(@"Na", @"F", @"144", NO)
    RESWREF(@"K", @"F", @"5.2", YES)
    RESWREF(@"Glukos", @"F", @"12.5", YES)
    RESWREF(@"HbA1c", @"F", @"8.6", YES)
    REPORTEND
    PATIENTREPORTSEND
    
    PATIENTREPORTS(@"101010-1010")
    REPORT(@"2011-02-18 17:36", @"2011-02-19 09:34")
    RESWREF(@"Hb", @"F", @"112", YES)
    RESWREF(@"K", @"F", @"3.8", NO)
    REPORTEND
    
    REPORT(@"2011-03-14 11:32", @"2011-03-14 15:50")
    RESWREF(@"Hb", @"F", @"118", NO)
    RESWREF(@"K", @"F", @"4.2", NO)
    REPORTEND
    PATIENTREPORTSEND
    
    PATIENTREPORTS(@"090909-0909")
    REPORT(@"2011-02-18 17:36", @"2011-02-19 09:34")
    RESWREF(@"Hb", @"F", @"112", YES)
    RESWREF(@"K", @"F", @"3.8", NO)
    REPORTEND
    
    REPORT(@"2011-03-14 11:32", @"2011-03-14 15:50")
    RESWREF(@"Hb", @"F", @"118", NO)
    RESWREF(@"K", @"F", @"4.2", NO)
    REPORTEND
    PATIENTREPORTSEND
    
    PATIENTREPORTS(@"080808-0808")
    REPORT(@"2011-02-18 17:36", @"2011-02-19 09:34")
    RESWREF(@"Hb", @"F", @"112", YES)
    RESWREF(@"K", @"F", @"3.8", NO)
    REPORTEND
    
    REPORT(@"2011-03-14 11:32", @"2011-03-14 15:50")
    RESWREF(@"Hb", @"F", @"118", NO)
    RESWREF(@"K", @"F", @"4.2", NO)
    REPORTEND
    PATIENTREPORTSEND
    
    PATIENTREPORTS(@"070707-0707")
    REPORT(@"2011-02-18 17:36", @"2011-02-19 09:34")
    RESWREF(@"Hb", @"F", @"112", YES)
    RESWREF(@"K", @"F", @"3.8", NO)
    REPORTEND
    
    REPORT(@"2011-03-14 11:32", @"2011-03-14 15:50")
    RESWREF(@"Hb", @"F", @"118", NO)
    RESWREF(@"K", @"F", @"4.2", NO)
    REPORTEND
    PATIENTREPORTSEND
    
    
    return nil;
}

+ (NSUInteger)numberOfReportsForPatientId:(NSString *)patientId {
    NSArray *arr = [self klinKemReportsForPatientId:patientId];
    return [arr count];
}


@end