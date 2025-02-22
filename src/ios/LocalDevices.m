#import "LocalDevices.h"

@implementation LocalDevices

- (void)scan:(CDVInvokedUrlCommand*)command {
    // Reset previous scan if any
    [self cleanup];
    
    // Store callback ID
    self.callbackId = command.callbackId;
    
    // Initialize devices array
    self.devices = [NSMutableArray array];
    
    // Get parameters
    NSNumber *timeout = command.arguments.count > 0 ? command.arguments[0] : @(0);
    NSArray *deviceTypes = command.arguments.count > 1 ? command.arguments[1] : @[];
    
    // Initialize scanner
    self.lanScanner = [[MMLANScanner alloc] initWithDelegate:self];
    
    // Handle timeout
    if (timeout.doubleValue > 0) {
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout.doubleValue / 1000.0
                                                             target:self
                                                           selector:@selector(handleTimeout)
                                                           userInfo:nil
                                                            repeats:NO];
    }
    
    // Start scan
    [self.lanScanner start];
}

- (void)handleTimeout {
    [self.lanScanner stop];
}

- (void)cleanup {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    [self.lanScanner stop];
    self.lanScanner = nil;
    self.devices = nil;
    self.callbackId = nil;
}

#pragma mark - MMLANScanner Delegates

- (void)lanScanDidFindNewDevice:(MMDevice *)device {
    NSMutableDictionary *deviceInfo = [NSMutableDictionary dictionary];
    [deviceInfo setValue:device.ipAddress forKey:@"ip"];
    [deviceInfo setValue:device.hostname forKey:@"hostname"];
    [deviceInfo setValue:device.brand forKey:@"brand"];
    [deviceInfo setValue:device.macAddress forKey:@"mac"];
    
    [self.devices addObject:deviceInfo];
}

- (void)lanScanProgressPinged:(NSInteger)pingedHosts from:(NSInteger)overallHosts {
    NSDictionary *progressData = @{
        @"pinged": @(pingedHosts),
        @"total": @(overallHosts)
    };
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
        @"state": @"progress",
        @"data": progressData
    }];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)lanScanDidFinishScanningWithStatus:(MMLanScannerStatus)status {
    NSDictionary *resultData = @{@"devices": self.devices ?: @[]};
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
        @"state": @"finished",
        @"data": resultData
    }];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    [self cleanup];
}

- (void)lanScanDidFailedToScan {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Scan failed"];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    [self cleanup];
}

@end
