//
//  SysTeamNPO.m
//  iotaPad6
//
//  Created by Martin on 2011-03-20.
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

#import "SysTeamNPO.h"
#import "Soap12.h"
#import "Funcs.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface SysTeamNPO ()
@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;
@end


@implementation SysTeamNPO

@synthesize patientId = _patientId;
@synthesize fromDate = _fromDate;
@synthesize toDate = _toDate;
@synthesize serverIp = _serverIp;
@synthesize target = _target;
@synthesize action = _action;

static NSString *getChemistryRequest = 
@"<GetChemistry xmlns=\"http://Cross/NPOIntegrationService/\">"
"<request_Information xmlns=\"http://Cross/NPOIntegrationService/ReqInformation\">"
"<patientId>%@</patientId>"
"<franDatum>%@</franDatum>"
"<tillDatum>%@</tillDatum>"
"</request_Information>"
"</GetChemistry>";

static NSString *getDiagnosisRequest = 
@"<GetDiagnosis xmlns=\"http://Cross/NPOIntegrationService/\">"
"<request_Information xmlns=\"http://Cross/NPOIntegrationService/ReqInformation\">"
"<patientId>%@</patientId>"
"<franDatum>%@</franDatum>"
"<tillDatum>%@</tillDatum>"
"</request_Information>"
"</GetDiagnosis>";


+ (NSString *)formRequestForPatientId:(NSString *)patientId fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate reqFmtStr:(NSString *)reqFmtStr {
    NSString *fD = [dateFormatterDate() stringFromDate:fromDate];
    NSString *tD = [dateFormatterDate() stringFromDate:toDate];
    NSString *reqstr = [NSString stringWithFormat:reqFmtStr, patientId, fD, tD];
    return reqstr;
}

+ (NSString *)formChemistryRequestForPatientId:(NSString *)patientId fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    return [self formRequestForPatientId:patientId fromDate:fromDate toDate:toDate reqFmtStr:getChemistryRequest];
}

+ (NSString *)formDiagnosisRequestForPatientId:(NSString *)patientId fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    return [self formRequestForPatientId:patientId fromDate:fromDate toDate:toDate reqFmtStr:getDiagnosisRequest];
}

- (void)dealloc {
    self.patientId = nil;
    self.fromDate = nil;
    self.toDate = nil;
    self.serverIp = nil;
    self.target = nil;
    self.action = nil;
    [super dealloc];
}

- (void)deliverChemistryToTarget:(id)target action:(SEL)action {
    self.target = target;
    self.action = action;
    NSString *urlString = [NSString stringWithFormat:@"http://%@/NPOIntegrationService/LocalWSI_tp.asmx", self.serverIp];
    NSURL *url = [NSURL URLWithString:urlString];
    Soap12 *soap12 = [[Soap12 alloc] init];
    soap12.url = url;
    soap12.soapAction = @"http://Cross/NPOIntegrationService/GetChemistry";
    soap12.requestBody = [[self class] formChemistryRequestForPatientId:self.patientId fromDate:self.fromDate toDate:self.toDate];
    [soap12 executeRequestWithTarget:self];
    [soap12 release];
}

- (void)deliverDiagnosesToTarget:(id)target action:(SEL)action {
    self.target = target;
    self.action = action;
    NSString *urlString = [NSString stringWithFormat:@"http://%@/NPOIntegrationService/LocalWSI_tp.asmx", self.serverIp];
    NSURL *url = [NSURL URLWithString:urlString];
    Soap12 *soap12 = [[Soap12 alloc] init];
    soap12.url = url;
    [url release];
    soap12.soapAction = @"http://Cross/NPOIntegrationService/GetDiagnosis";
    soap12.requestBody = [[self class] formDiagnosisRequestForPatientId:self.patientId fromDate:self.fromDate toDate:self.toDate];
    [soap12 executeRequestWithTarget:self];
    [soap12 release];
}

- (void)soapSuccess:(BOOL)success result:(NSString *)result {
    [self.target performSelector:self.action withObject:result];
}


@end
