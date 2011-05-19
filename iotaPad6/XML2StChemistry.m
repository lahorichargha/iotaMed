//
//  XML2StChemistry.m
//  iotaPad6
//
//  Created by Martin on 2011-03-22.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "XML2StChemistry.h"
#import "StUndersokningsresultat.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------



@implementation XML2StChemistry




- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"undersokningsresultat"]) {
        NSLog(@"UndersokningsResultat");
        StUndersokningsresultat *stur = [[[StUndersokningsresultat alloc] init] autorelease];
        stur.elementName = elementName;
        [self pushElement:stur];
    }
    [self.charBuffer setString:@""];
    
    
}

- (NSString *)getAndClearBuffer {
    NSString *rv = [self.charBuffer copy];
    [self.charBuffer setString:@""];
    return [rv autorelease];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    //    NSLog(@"elementname, charsfound: %@ - %@", elementName, self.charBuffer);
    
    if ([elementName isEqualToString:@"atgardskod_text"]) {
        StUndersokningsresultat *stur = [self topOfStackElement];
        stur.atgardskodText = [self getAndClearBuffer];
        NSLog(@"   atgardskodText: %@", stur.atgardskodText);
    }
    else if ([elementName isEqualToString:@"atgardstid"]) {
        StUndersokningsresultat *stur = [self topOfStackElement];
        stur.atgardstid = [self getAndClearBuffer];
        NSLog(@"   atgardstid: %@", stur.atgardstid);
    }
    else if ([elementName isEqualToString:@"varde"]) {
        StUndersokningsresultat *stur = [self topOfStackElement];
        stur.varde = [self getAndClearBuffer];
        NSLog(@"   varde: %@", stur.varde);
    }
    else if ([elementName isEqualToString:@"varde_enhet"]) {
        StUndersokningsresultat *stur = [self topOfStackElement];
        stur.vardeEnhet = [self getAndClearBuffer];
        NSLog(@"   vardeEnhet: %@", stur.vardeEnhet);
    }
    else if ([elementName isEqualToString:@"patologiskmarkerad"]) {
        StUndersokningsresultat *stur = [self topOfStackElement];
        stur.patologiskmarkerad = ([[self getAndClearBuffer] isEqualToString:@"True"]) ? YES : NO;
        NSLog(@"   patologiskmarkerad: %d", stur.patologiskmarkerad);
    }
    else if ([elementName isEqualToString:@"referensintervall"]) {
        StUndersokningsresultat *stur = [self topOfStackElement];
        stur.referensintervall = [self getAndClearBuffer];
        NSLog(@"   referensinterval: %@", stur.referensintervall);
    }
    else {
        StBase *tos = [self topOfStackElement];
        if ([tos.elementName isEqualToString:elementName])
            [self popElement];
    }
}



@end
