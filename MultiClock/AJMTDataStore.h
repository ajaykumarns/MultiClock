//
//  AJMTDataStore.h
//  MultiClock
//
//  Created by Ajay Kumar Nadathur Sreenivasan on 1/11/14.
//  Copyright (c) 2014 Ajay Kumar Nadathur Sreenivasan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AJMTDataStore : NSObject
+(NSArray*) monitoredTimeZones;
+(void) removeMonitoredTimeZone:(NSString*)tz;
+(void) addMonitoredTimeZone:(NSString*)tz;
@end
