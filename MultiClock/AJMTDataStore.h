//
//  AJMTDataStore.h
//  MultiClock
//
//  Created by Ajay Kumar Nadathur Sreenivasan on 1/11/14.
//  Copyright (c) 2014 Ajay Kumar Nadathur Sreenivasan. All rights reserved.
//

#import <Foundation/Foundation.h>
#define PREF_DISPLAY_SECS   @"prefs_displaySeconds"
#define PREF_FLASH_SEP      @"prefs_flashSeparator"
#define PREF_24HR_CLK       @"prefs_24hrClock"
#define PREF_SHOW_AM_PM     @"prefs_showAmPm"
#define PREF_SHOW_DAY_WEEK  @"prefs_showDayOfWeek"
#define PREF_SHOW_DATE      @"prefs_showDate"

@interface AJMTDataStore : NSObject
+(NSArray*) monitoredTimeZones;
+(void) removeMonitoredTimeZone:(NSString*)tz;
+(void) addMonitoredTimeZone:(NSString*)tz;
+(BOOL) boolForKey:(NSString*)key;
+(void) setBool:(BOOL)b forKey:(NSString*)k;
@end
