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

#define TIME_ZONE_UPDATE_INTERVAL 30
#define ZONE_TEMPLATE @"HH:mm MMM d, yyyy"
static NSString *const _zoneTemplate = @"HH:mm MMM d, yyyy";

@implementation AJMTMenuletController

- (id)initWithNibName:(NSString *)nibNameOrNil appDelegate:(AJMTAppDelegate*)appDel{
  self = [super initWithNibName:nibNameOrNil bundle:nil];
  if (self) {
    self.appDelegate = appDel;
  }
  _blinked = NO;
  _dateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                              selector:@selector(updateTime) userInfo:nil repeats:YES];
  return self;
}

- (void) awakeFromNib {
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setHighlightMode:NO];
	[statusItem setEnabled:YES];
    //[statusItem setToolTip:@"IP Address"];
	[statusItem setTarget:self];
  [statusItem setMenu:self.menu];
  [_dateTimer fire];

//  NSDictionary * tzDict = [NSTimeZone abbreviationDictionary];
//  for(NSString *key in [tzDict allKeys]){
//    NSLog(@"%@ : %@", key, [tzDict objectForKey:key]);
//  }
//  
    //update all time zones when the menu opens, otherwise don't do it.
  NSTimer *timer = [NSTimer timerWithTimeInterval:TIME_ZONE_UPDATE_INTERVAL
                                           target:self
                                         selector:@selector(updateTheMenu)
                                         userInfo:nil
                                          repeats:YES];
  
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
  
  int beginIndex = 0;
  for(NSString *zone in [AJMTDataStore monitoredTimeZones]){
    NSMenuItem *item = [NSMenuItem new];
    [item setTitle:zone];
    [self.menu insertItem:item atIndex:++beginIndex];
  }
  
    //NSLog(@"Configured time zones = %@", [AJDataStore timeZones]);
  [self updateTheMenu]; //call it once during startup
}

  ///////////////////////////////// Utility methods //////////////////////

-(void) updateTime{
  NSString *template = _blinked ? @"HH:mm" : @"HH mm";
  _blinked = !_blinked;
  [statusItem setTitle:[self formatWith:template usingTz:nil]];
}

-(void) updateTheMenu {
  NSMutableArray *arr = [NSMutableArray arrayWithArray:[AJMTDataStore monitoredTimeZones]];
  [arr insertObject:[[NSTimeZone defaultTimeZone] name] atIndex:0];
  
  int beginIndx = 0;
  for(NSString *zone in arr){
    NSMenuItem *item = [self.menu itemAtIndex:beginIndx++];
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:zone];
    NSString *date = [self formatWith:_zoneTemplate usingTz:tz];
    [item setTitle:[NSString stringWithFormat:@"%@ (%@)", date, [tz name]]];
      //NSLog(@"Modifying menu %i with timezone = %@", beginIndx, tz);
  }
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

  /////////////////////////////////////// Action calls /////////////////////////////

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
  system("open /Application/Calendar.app");
}
@end
