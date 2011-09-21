//
//  iotaPad6AppDelegate.m
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

#import "iotaPad6AppDelegate.h"
#import "IotaContext.h"
#import "Notifications.h"

#import "TestFlight.h"

@implementation iotaPad6AppDelegate


@synthesize window=_window;
@synthesize issueListController = _issueListController;
@synthesize splitViewController = _splitViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [TestFlight takeOff:@"67bd577cfab746ffedee1557d8d72cd0_MjYyMTUyMDExLTA5LTIxIDA2OjQ2OjU3LjA5Nzk1MA"];
    [self.window addSubview:_splitViewController.view];
    [self.window makeKeyAndVisible];
    NSString *loc = NSLocalizedString(@"LocalizedLanguage", @"Just checking");
    NSLog(@"Current language string file: %@", loc);
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [IotaContext saveCurrentPatientContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [IotaContext saveCurrentPatientContext];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // subscribing to the UIApplicationDidReceiveMemoryWarningNotification makes the debugger stop working
    // go figure...
    [[NSNotificationCenter defaultCenter] postNotificationName:kLowMemoryNotification object:nil];
}

- (void)dealloc {
    [_issueListController release];
    [_splitViewController release];
    [_window release];
    [super dealloc];
}

@end
