#import <Cordova/CDV.h>
#import <MMLanScan/MMLANScanner.h>

@interface LocalDevices : CDVPlugin <MMLANScannerDelegate>

@property (nonatomic, strong) MMLANScanner *lanScanner;
@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, strong) NSString *callbackId;
@property (nonatomic, strong) NSTimer *timeoutTimer;

- (void)scan:(CDVInvokedUrlCommand*)command;

@end
