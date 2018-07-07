/**
 * @file listens for USB device connections matching a PID and VID
 * @author Oliver Kuckertz <oliver.kuckertz@mologie.de>
 *
 * The control flow of this class is from Apple's "Another USB Notification Example", though most of it has been
 * adapted to Objective-C and the requirements of this application.
 */

#import "FLUSBDeviceEnumerator.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/IOMessage.h>
#import <IOKit/usb/IOUSBLib.h>
#import <mach/mach.h>

@interface FLUSBDeviceEnumerator () {
    io_iterator_t _deviceIter;
}
@property (assign, nonatomic) UInt16 VID;
@property (assign, nonatomic) UInt16 PID;
@property (assign, nonatomic) IONotificationPortRef notifyPort;
- (void)handleDevicesAdded:(io_iterator_t)iterator;
- (void)handleDeviceNotification:(FLUSBDevice *)device
                      forService:(io_service_t)service
                     messageType:(natural_t)messageType
                      messageArg:(void *)messageArg;
@end

static void bridgeDevicesAdded(void *u, io_iterator_t iterator) {
    FLUSBDeviceEnumerator *deviceEnum = (__bridge FLUSBDeviceEnumerator *)u;
    [deviceEnum handleDevicesAdded:iterator];
}

static void bridgeDeviceNotification(void *u, io_service_t service, natural_t messageType, void *messageArg) {
    FLUSBDevice *device = (__bridge FLUSBDevice *)u;
    FLUSBDeviceEnumerator *deviceEnum = device.parentEnum;
    [deviceEnum handleDeviceNotification:device forService:service messageType:messageType messageArg:messageArg];
}

@implementation FLUSBDeviceEnumerator

- (void)dealloc {
    [self stop];
}

- (void)addFilterForVendorID:(UInt16)vendorID productID:(UInt16)productID {
    // TODO maintain a list once/if we support multiple VIDs/PIDs
    self.VID = vendorID;
    self.PID = productID;
}

- (void)start {
    kern_return_t kr;
    NSMutableDictionary *matchingDict = nil;

    // clean up previous run before starting a new one
    [self stop];

    // Note we're searching for IOUSBHostDevice kernel objects, which only works on macOS 10.11+ and iOS 9+.
    // macOS has backwards-compatibility for IOUSBDevice, but iOS does not.
    matchingDict = (__bridge_transfer NSMutableDictionary *)IOServiceMatching("IOUSBHostDevice");
    if (!matchingDict) {
        NSLog(@"ERR: Could not create service matching dict");
        return;
    }
    [matchingDict setValue:@(self.VID) forKey:@(kUSBVendorID)];
    [matchingDict setValue:@(self.PID) forKey:@(kUSBProductID)];

    self.notifyPort = IONotificationPortCreate(kIOMasterPortDefault);
    if (!self.notifyPort) {
        NSLog(@"ERR: Could not create notification port");
        return;
    }

    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                       IONotificationPortGetRunLoopSource(self.notifyPort),
                       kCFRunLoopDefaultMode);

    kr = IOServiceAddMatchingNotification(self.notifyPort,
                                          kIOFirstMatchNotification,
                                          (__bridge_retained CFDictionaryRef)matchingDict,
                                          bridgeDevicesAdded,
                                          (__bridge void *)self,
                                          &_deviceIter);
    if (kr) {
        NSLog(@"ERR: Could not add matching service notification (%08x)", kr);
        return;
    }

    NSLog(@"USB: OK, listening for devices matching VID:%04x PID:%04x", self.VID, self.PID);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleDevicesAdded:self->_deviceIter];
        NSLog(@"USB: Done processing initial device list");
    });
}

- (void)stop {
    if (self.notifyPort) {
        IONotificationPortDestroy(self.notifyPort);
    }
    if (_deviceIter) {
        IOObjectRelease(_deviceIter);
        _deviceIter = 0;
    }
}

#pragma mark - IOKit Notifications

- (void)handleDevicesAdded:(io_iterator_t)iterator {
    kern_return_t kr;
    io_service_t service;

    NSLog(@"USB: Processing new devices");

    while ((service = IOIteratorNext(iterator))) {
        FLUSBDevice *device = [[FLUSBDevice alloc] init];
        device.parentEnum = self;

        // retrieve service name as device name
        io_name_t ioDeviceName;
        kr = IORegistryEntryGetName(service, ioDeviceName);
        if (kr) {
            ioDeviceName[0] = '\0';
        }
        device.name = [NSString stringWithCString:ioDeviceName encoding:NSASCIIStringEncoding];
        NSLog(@"USB: Device added: 0x%08x `%@'", service, device.name);

        // load the device interface implementation bundle
        IOCFPlugInInterface **plugInInterface = NULL;
        SInt32 plugInScore;
        kr = IOCreatePlugInInterfaceForService(service,
                                               kIOUSBDeviceUserClientTypeID,
                                               kIOCFPlugInInterfaceID,
                                               &plugInInterface,
                                               &plugInScore);
        if (kr || !plugInInterface) {
            NSLog(@"ERR: Could not create USB device plugin instance (%08x)", kr);
            goto cleanup;
        }
        kr = (*plugInInterface)->QueryInterface(plugInInterface,
                                                CFUUIDGetUUIDBytes(kFLUSBDeviceInterfaceUUID),
                                                (void*)&device->_intf);
        FLCOMCall(plugInInterface, Release);
        plugInInterface = NULL;
        if (kr || !device->_intf) {
            NSLog(@"ERR: Could not get USB device interface (%08x)", kr);
            goto cleanup;
        }

        // fetch location ID
        kr = FLUSBCall(device, GetLocationID, &device->_locationID);
        if (kr != KERN_SUCCESS) {
            NSLog(@"ERR: GetLocationID failed with code %08x, skipping device\n", kr);
            goto cleanup;
        }
        NSLog(@"USB: Device location ID: 0x%lx\n", (unsigned long)device->_locationID);

        // register for device events
        kr = IOServiceAddInterestNotification(self.notifyPort,
                                              service,
                                              kIOGeneralInterest,
                                              bridgeDeviceNotification,
                                              (__bridge_retained void *)device,
                                              &device->_notification);
        if (kr != KERN_SUCCESS) {
            NSLog(@"ERR: IOServiceAddInterestNotification failed with code 0x%08x", kr);
            goto cleanup;
        }

        // notify delegate
        [self.delegate usbDeviceEnumerator:self deviceConnected:device];

    cleanup:
        kr = IOObjectRelease(service);
    }
}

- (void)handleDeviceNotification:(FLUSBDevice *)device
                      forService:(io_service_t)service
                     messageType:(natural_t)messageType
                      messageArg:(void *)messageArgument
{
    NSLog(@"USB: Device 0x%08x received message 0x%x", service, messageType);

    switch (messageType) {
        case kIOMessageServiceIsTerminated: {
            NSLog(@"USB: Device 0x%08x removed", service);
            [device invalidate];
            [self.delegate usbDeviceEnumerator:self deviceDisconnected:device];
            device = (__bridge_transfer FLUSBDevice *)(__bridge void *)device;
            break;
        }
    }
}

@end
