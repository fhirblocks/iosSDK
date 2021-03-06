//
//  ServerSingleton.m
//  mHealthDApp
//
/*
 * Copyright 2018 BBM Health, LLC - All rights reserved
 * Confidential & Proprietary Information of BBM Health, LLC - Not for disclosure without written permission
 * FHIR is registered trademark of HL7 Intl
 *
 */

#import "ServerSingleton.h"
#import "Constants.h"

@implementation ServerSingleton

+ (id) sharedServerSingleton {
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    if (self = [super init]) {
       
    }
    return self;
}

- (void)checkTimeWithDate:(NSString *)serverTime
{
    DebugLog(@"");
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    dateformatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    
    self.timeOffset = (time_t)[[dateformatter dateFromString:serverTime]timeIntervalSince1970] - (time_t)[[NSDate date]timeIntervalSince1970];
}

- (time_t)time{
    DebugLog(@"");
    return (time_t)[[NSDate date]timeIntervalSince1970] - self.timeOffset;
}

@end
