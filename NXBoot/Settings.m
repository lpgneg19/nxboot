#import "Settings.h"
#import "PayloadStorage.h"

@import AppCenterAnalytics;
@import AppCenterCrashes;

static NSString *const NXBootRememberPayload = @"NXBootRememberPayload";
static NSString *const NXBootLastPayload = @"NXBootLastPayload";

@implementation Settings

+ (BOOL)rememberPayload {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:NXBootRememberPayload]) {
        return [defaults boolForKey:NXBootRememberPayload];
    } else {
        return YES;
    }
}

+ (void)setRememberPayload:(BOOL)rememberPayload {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:rememberPayload forKey:NXBootRememberPayload];
}

+ (nullable NSString *)lastPayloadFileName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:NXBootLastPayload];
}

+ (void)setLastPayloadFileName:(nullable NSString *)lastPayloadFileName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (lastPayloadFileName) {
        [defaults setObject:lastPayloadFileName forKey:NXBootLastPayload];
    } else {
        [defaults removeObjectForKey:NXBootLastPayload];
    }
}

+ (BOOL)appCenterSupported {
    // Microsoft retire AppCenter at 2025-03-31.
    // Automatically disable AppCenter if the process is launched after that date.
    static dispatch_once_t onceToken;
    static BOOL supported;
    dispatch_once(&onceToken, ^{
        NSDateComponents *dc = [[NSDateComponents alloc] init];
        dc.year = 2025;
        dc.month = 3;
        dc.day = 31;
        NSDate *targetDate = [[NSCalendar currentCalendar] dateFromComponents:dc];
        supported = [[NSDate date] compare:targetDate] == NSOrderedAscending;
    });
    return supported;
}

+ (BOOL)allowCrashReports {
    return self.appCenterSupported && [MSACCrashes isEnabled];
}

+ (void)setAllowCrashReports:(BOOL)enableCrashReports {
    [MSACCrashes setEnabled:enableCrashReports];
}

+ (BOOL)allowUsagePings {
    return self.appCenterSupported && [MSACAnalytics isEnabled];
}

+ (void)setAllowUsagePings:(BOOL)enableUsagePings {
    [MSACAnalytics setEnabled:enableUsagePings];
}

@end
