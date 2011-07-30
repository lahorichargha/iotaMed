//
//  Soap12.m
//  iotaPad6
//
//  Created by Martin on 2011-03-18.
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

#import "Soap12.h"
#import "IotaContext.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface Soap12 ()
@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) id target;
@end


@implementation Soap12

@synthesize url = _url;
@synthesize soapAction = _soapAction;
@synthesize requestBody = _requestBody;
@synthesize webData = _webData;
@synthesize connection = _connection;
@synthesize target = _target;

- (void)dealloc {
    self.url = nil;
    self.soapAction = nil;
    self.requestBody = nil;
    self.webData = nil;
    self.connection = nil;
    self.target = nil;
    [super dealloc];
}

static NSString *soapRequestWrapper = 
            @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
            "<soap12:Envelope xmlns:xsi="
            "\"http://www.w3.org/2001/XMLSchema-instance\" "	 
            "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
            "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"	 
            "<soap12:Body>"	 
            "%@"
            "</soap12:Body>"
            "</soap12:Envelope>";


+ (NSString *)httpUrlString {
    NSString *ip = [IotaContext crossServerIPNumber];
    NSString *str = [NSString stringWithFormat:@"http://%@/NPOIntegrationService/LocalWSI_tp.asmx", ip];
    return str;
}

- (void)executeRequestWithTarget:(id<SoapClientObject>)target {
    self.target = target;

    NSString *requestString = [NSString stringWithFormat:soapRequestWrapper, self.requestBody];
//    NSLog(@"...requestString: %@", requestString);
    NSString *msgLength = [NSString stringWithFormat:@"%d", [requestString length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:self.soapAction forHTTPHeaderField:@"SOAPAction"];
//    NSLog(@"soapAction: %@", self.soapAction);
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[requestString dataUsingEncoding:NSUTF8StringEncoding]];
//    NSLog(@"%@", [request description]);
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    
    if (self.connection)
        self.webData = [[[NSMutableData alloc] init] autorelease];
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    NSLog(@"...did receive response...");
    [self.webData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    NSLog(@"...did receive data");
    [self.webData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", [error localizedDescription]);
    self.webData = nil;
    self.connection = nil;
    [self.target soapSuccess:NO result:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    NSLog(@"...finished loading, got %d bytes", [self.webData length]);
    NSString *theXML = [[NSString alloc] initWithBytes:[self.webData mutableBytes] length:[self.webData length] encoding:NSUTF8StringEncoding];
//    NSLog(@"...XML: %@", theXML);
    [self.target soapSuccess:YES result:[theXML autorelease]];
    self.webData = nil;
    self.connection = nil;
}




@end
