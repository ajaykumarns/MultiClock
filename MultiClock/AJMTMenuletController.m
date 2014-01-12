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

#define TIME_ZONE_UPDATE_INTERVAL 15
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
    //[statusItem setToolTip:@"IP Address"];
	[statusItem setTarget:self];
  [statusItem setMenu:self.menu];
  _dateTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                target:self
                                              selector:@selector(updateTime)
                                              userInfo:nil
                                               repeats:YES];
  [_dateTimer fire];

  //update all time zones when the menu opens, otherwise don't do it.
  NSTimer *timer = [NSTimer timerWithTimeInterval:TIME_ZONE_UPDATE_INTERVAL
                                           target:self
                                         selector:@selector(updateTheMenu)
                                         userInfo:nil
                                          repeats:YES];
  
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
  
  int beginIndex = 0;
  NSArray *tzs = [AJMTDataStore monitoredTimeZones];
  totalTz = (int)[tzs count];
  
  for(NSString *zone in tzs){
    NSMenuItem *item = [NSMenuItem new];
    [item setTitle:zone];
    [self.menu insertItem:item atIndex:++beginIndex];
  }
  
    //NSLog(@"Configured time zones = %@", [AJDataStore timeZones]);
  [self updateTheMenu]; //call it once during startup
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferenceChanged:) name:nil object:[AJMTDataStore class]];
}

  /////////////////////////////////////// Action calls /////////////////////////////

- (void) preferenceChanged:(NSNotification*)notification {
  NSLog(@"Preference \"%@\" changed!", [notification name]);
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
  NSString *template = _blinked ? @"HH:mm" : @"HH mm";
  _blinked = !_blinked;
  [statusItem setTitle:[self formatWith:template usingTz:nil]];
}

-(void) updateTheMenu {
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
