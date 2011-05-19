//
//  ServerListener.m
//  iotaPad6
//
//  Created by Martin on 2011-05-07.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "ServerListener.h"
#import "iotaPad6AppDelegate.h"
#include <CFNetwork/CFNetwork.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface ServerListener ()

@property (nonatomic, readonly) BOOL                isStarted;
@property (nonatomic, readonly) BOOL                isReceiving;
@property (nonatomic, retain)   NSNetService *      netService;
@property (nonatomic, assign)   CFSocketRef         listeningSocket;
@property (nonatomic, retain)   NSInputStream *     inputStream;
@property (nonatomic, retain)   NSOutputStream *    outputStream;
@property (nonatomic, copy)     NSString *          filePath;

@end


@implementation ServerListener

@synthesize listeningSocket = _listeningSocket;
@synthesize netService = _netService;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize filePath = _filePath;


- (BOOL)isStarted {
    return (self.netService != nil);
}

- (BOOL)isReceiving {
    return (self.inputStream != nil);
}

- (void)setListeningSocket:(CFSocketRef)newValue {
    if (newValue != self->_listeningSocket) {
        if (self->_listeningSocket != NULL) {
            CFRelease(self->_listeningSocket);
        }
        self->_listeningSocket = newValue;
        if (self->_listeningSocket != NULL) {
            CFRetain(self->_listeningSocket);
        }
    }
}

- (void)_startReceive:(int)fd {
    // CFReadStreamRef readStream;
    assert(fd >= 0);
    assert(self.inputStream == nil);
    assert(self.outputStream == nil);
    assert(self.filePath == nil);
    
    self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Receive"];
    assert(self.filePath != nil);
    
    
}

- (void)_acceptConnection:(int)fd {
    int junk;
    // we only handle one connection at a time
    if (self.isReceiving) {
        junk = close(fd);
        assert (junk == 0);
    }
    else {
        [self _startReceive:fd];
    }
}

static void AcceptCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    assert(type == kCFSocketAcceptCallBack);
    assert(data != NULL);

    ServerListener *me = (ServerListener *)info;
    assert(me != nil);
    assert(s == me->_listeningSocket);
}

- (void)createListeningPort {
    BOOL                success;
    int                 err;
    int                 port = 0;
    int                 fd;
    struct sockaddr_in  addr;
    
    fd = socket(AF_INET, SOCK_STREAM, 0);
    success = (fd != -1);
    
    if (success) {
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_port = 0;
        addr.sin_addr.s_addr = INADDR_ANY;
        err = bind(fd, (const struct sockaddr *) &addr, sizeof(addr));
        success = (err == 0);
    }
    
    if (success) {
        err = listen(fd, 5);
        success = (err == 0);
    }
    
    if (success) {
        socklen_t   addrLen;
        
        addrLen = sizeof(addr);
        err = getsockname(fd, (struct sockaddr *) &addr, &addrLen);
        success = (err == 0);
        
        if (success) {
            assert(addrLen == sizeof(addr));
            port = ntohs(addr.sin_port);
        }
    }
    
    if (success) {
        CFSocketContext context = {0, self, NULL, NULL, NULL };
        self.listeningSocket = CFSocketCreateWithNative(NULL, fd, kCFSocketAcceptCallBack, AcceptCallback, &context);
        success = (self.listeningSocket != NULL);
        if (success) {
            CFRunLoopSourceRef rls;
            fd = -1;
            rls = CFSocketCreateRunLoopSource(NULL, self.listeningSocket, 0);
            assert(rls != NULL);
            CFRelease(self.listeningSocket);
            CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
            CFRelease(rls);
        }
    }
    
}


- (void)setupListener {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    //        CFStreamCreateBoundPair(CFAllocatorRef alloc, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream, CFIndex transferBufferSize);
    
    
    NSInputStream *inputStream = (NSInputStream *)readStream;
    NSOutputStream *outputStream = (NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Stream delegate
// -----------------------------------------------------------

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
}

@end
