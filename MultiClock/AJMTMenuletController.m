//
//  AJMTMenuletController.m
//  MultiClock
//
//  Created by Ajay Kumar Nadathur Sreenivasan on 1/11/14.
//  Copyright (c) 2014 Ajay Kumar Nadathur Sreenivasan. All rights reserved.
//

#import "AJMTMenuletController.h"
#import "AJMTAppDelegate.h"
#import "AJMTDataStore.h"

#define TIME_ZONE_UPDATE_INTERVAL 5
#define ZONE_TEMPLATE @"HH:mm MMM d, yyyy"
static NSString *const _zoneTemplate = @"HH:mm MMM d, yyyy";
@implementation AJMTMenuletController

- (id)initWithNibName:(NSString *)nibNameOrNil appDelegate:(AJMTAppDelegate*)appDel{
  self = [super initWithNibName:nibNameOrNil bundle:nil];
  if (self) {
    self.appDelegate = appDel;
    _blinked = NO;
    totalTz = 0;
  }
  return self;
}

- (void) loadSelf {
  [self loadView];
  NSLog(@"Returning after loading view...");
}

- (void) awakeFromNib {
  NSLog(@"awake called in AJMTMenuletController...");
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setHighlightMode:NO];
	[statusItem setEnabled:YES];
	[statusItem setTarget:self];
  [statusItem setMenu:self.menu];
  
  _shouldBlink = [AJMTDataStore boolForKey:PREF_FLASH_SEP];
  [self updateTimeTemplate];
  [self changeTimeUpdaterToSeconds:[AJMTDataStore boolForKey:PREF_DISPLAY_SECS] || _shouldBlink];

    //update all time zones when the menu opens, otherwise don't do it.
  NSTimer *timer = [NSTimer timerWithTimeInterval:TIME_ZONE_UPDATE_INTERVAL target:self selector:@selector(updateTheMenu) userInfo:nil repeats:YES];
  
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
  int beginIndex = 0;
  NSArray *tzs = [AJMTDataStore monitoredTimeZones];
  totalTz = (int)[tzs count];
  
  for(NSString *zone in tzs){
    NSMenuItem *item = [NSMenuItem new];
    [item setTitle:zone];
    [self.menu insertItem:item atIndex:++beginIndex];
  }
  [self updateTheMenu]; //call it once during startup
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferenceChanged:) name:nil object:[AJMTDataStore class]];
}

  /////////////////////////////////////// Action calls /////////////////////////////

- (void) preferenceChanged:(NSNotification*)notification {
  NSString *name = [notification name];
  BOOL enabled = [AJMTDataStore boolForKey:name];
  NSLog(@"Preference \"%@\" changed!", [notification name]);
  
  [self updateTimeTemplate];
  
    //special use case for updating timer.
  if([PREF_DISPLAY_SECS isEqualToString:name]){
    [self changeTimeUpdaterToSeconds:enabled || _shouldBlink];
  } else if([PREF_FLASH_SEP isEqualToString:name]) {
    [self changeTimeUpdaterToSeconds:enabled || [AJMTDataStore boolForKey:PREF_DISPLAY_SECS]];
  }
  
    //finally update the time being displayed.
  [self updateTime];
}

- (void) changeTimeUpdaterToSeconds:(BOOL)perSecond {
  int interval = perSecond ? 1 : 60;
  if(_dateTimer){
    [_dateTimer invalidate];
    _dateTimer = nil;
  }
  
  NSLog(@"Updating the timer to use : %is", interval);
  _dateTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
  [_dateTimer fire];
}

- (void) updateTimeTemplate {
  BOOL showDay    = [AJMTDataStore boolForKey:PREF_SHOW_DAY_WEEK];
  BOOL showMonth  = [AJMTDataStore boolForKey:PREF_SHOW_DATE];
  _shouldBlink    = [AJMTDataStore boolForKey:PREF_FLASH_SEP];
  BOOL showSecs   = [AJMTDataStore boolForKey:PREF_DISPLAY_SECS];
  BOOL showAmpm   = [AJMTDataStore boolForKey:PREF_SHOW_AM_PM];
  BOOL militaryC  = [AJMTDataStore boolForKey:PREF_24HR_CLK];
  
  NSMutableArray *templates = [NSMutableArray new];
  
  if(showDay) {
    [templates addObject:@"E"];
  }
  
  if(showMonth){
    [templates addObject:@"MMM dd"];
  }
  
  NSString *timeF;
  if(militaryC){
    timeF = showSecs ? @"HH:mm:ss" : @"HH:mm";
  } else {
    if(showAmpm){
      timeF = showSecs ? @"h:mm:ss a" : @"h:mm a";
    } else {
      timeF = showSecs ? @"h:mm:ss" : @"h:mm";
    }
  }
  
  [templates addObject:timeF];
  
  _timeTemplate = [templates componentsJoinedByString:@" "];
  if(_shouldBlink){
    [templates removeLastObject];
    [templates addObject:[timeF stringByReplacingOccurrencesOfString:@":" withString:@" "]];
    _timeTemplate2 = [templates componentsJoinedByString:@" "];
  } else {
    _timeTemplate2 = nil;
  }
  
  NSLog(@"Updating time templates, for non-blinking = %@, blinking = %@", _timeTemplate, _timeTemplate2);
}

- (void) timeZone:(NSString *)tz atIndex:(int)indx added:(BOOL)added {
  NSLog(@"timeZone: %@, atIndex: %i, added: %@", tz, indx, (added ? @"added" : @"removed"));
  if(added){
    NSMenuItem *newItem = [NSMenuItem new];
    [newItem setTitle:tz];
    [self.menu insertItem:newItem atIndex:totalTz + 1];
    [self updateItemAtIndex:totalTz + 1 zone:tz usingDict:[NSTimeZone abbreviationDictionary]];
    ++totalTz;
  } else {
    totalTz -= 1;
    NSLog(@"Removing item at index: %i", indx + 1);
    [self.menu removeItemAtIndex:indx + 1];
  }
}

-(void) updateTime{
  NSString *template = (_shouldBlink && !_blinked) ? _timeTemplate2 : _timeTemplate;
  [statusItem setTitle:[self formatWith:template usingTz:nil]];
  _blinked = !_blinked;
}

-(void) updateTheMenu {
  [self updateTime];
  [self changeTimeUpdaterToSeconds:[AJMTDataStore boolForKey:PREF_DISPLAY_SECS] || [AJMTDataStore boolForKey:PREF_FLASH_SEP]];
  NSMutableArray *arr = [NSMutableArray arrayWithArray:[AJMTDataStore monitoredTimeZones]];
  [arr insertObject:[[NSTimeZone defaultTimeZone] name] atIndex:0];
  
  NSDictionary *aliasDict = [NSTimeZone abbreviationDictionary];
  int beginIndx = 0;
  for(NSString *zone in arr){
    [self updateItemAtIndex:beginIndx++ zone:zone usingDict:aliasDict];
  }
}

- (IBAction)quickApp:(id)sender {
  NSLog(@"Quit app called!");
  [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
  [NSApp terminate:self];
}

- (IBAction)openDateTimePrefs:(id)sender {
  NSLog(@"Opening global date and time preferences");
  system("open /System/Library/PreferencePanes/DateAndTime.prefPane");
}

- (IBAction)openPrefs:(id)sender {
  NSLog(@"Opening preferences...");
  [self.appDelegate openPrefs];
}

- (IBAction)openCalendar:(id)sender {
  NSLog(@"Opening calendar");
  system("open /Applications/Calendar.app");
}


  ///////////////////////////////// Utility methods //////////////////////

-(void) updateItemAtIndex:(int)indx zone:(NSString*)zone usingDict:(NSDictionary*)dict {
  NSString *tzAbbrev = [dict objectForKey:zone];
  if(!tzAbbrev){
    tzAbbrev = zone;
  }
  
  NSMenuItem *item = [self.menu itemAtIndex:indx];
  NSTimeZone *tz = [NSTimeZone timeZoneWithName:tzAbbrev];
  NSString *date = [self formatWith:_zoneTemplate usingTz:tz];
  [item setTitle:[NSString stringWithFormat:@"%@ (%@)", date, tzAbbrev]];
}

-(NSString*) formatWith:(NSString*)template usingTz:(NSTimeZone*)tz {
  NSDateFormatter *formatter = [NSDateFormatter new];
  if(!tz){
    tz = [NSTimeZone defaultTimeZone];
  }
  
  [formatter setDateFormat: template];
  [formatter setTimeZone:tz];
  return [formatter stringFromDate:[NSDate date]];
}

@end
