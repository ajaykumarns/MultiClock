//
//  AJMTDataStore.m
//  MultiClock
//
//  Created by Ajay Kumar Nadathur Sreenivasan on 1/11/14.
//  Copyright (c) 2014 Ajay Kumar Nadathur Sreenivasan. All rights reserved.
//

#import "AJMTDataStore.h"
#define TZ_KEY @"timeZones"

static NSUserDefaults *_prefs;
@implementation AJMTDataStore

+(void) initialize{
  [[NSUserDefaults standardUserDefaults] registerDefaults:@{TZ_KEY: @[@"IST"]}];
  _prefs = [NSUserDefaults standardUserDefaults];
}

+(NSArray*) monitoredTimeZones{
  return [_prefs arrayForKey:TZ_KEY];
}

+(void) removeMonitoredTimeZone:(NSString*)tz{
  NSMutableArray* zones = [NSMutableArray arrayWithArray:[self monitoredTimeZones]];
  [zones removeObject: tz];
  [_prefs setObject:zones forKey:TZ_KEY];
}

+(void) addMonitoredTimeZone:(NSString*)tz{
  NSMutableArray* zones = [NSMutableArray arrayWithArray:[self monitoredTimeZones]];
  [zones addObject: tz];
  [_prefs setObject:zones forKey:TZ_KEY];
}

@end
