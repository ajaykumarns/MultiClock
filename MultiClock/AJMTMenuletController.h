//
//  AJMTMenuletController.h
//  MultiClock
//
//  Created by Ajay Kumar Nadathur Sreenivasan on 1/11/14.
//  Copyright (c) 2014 Ajay Kumar Nadathur Sreenivasan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AJMTAppDelegate;

@interface AJMTMenuletController : NSViewController{
  __strong NSStatusItem *statusItem;
  __strong NSTimer *_dateTimer;
  BOOL _blinked;
  __strong NSMenu *_menu;
  int totalTz;
  BOOL _shouldBlink;
  NSString *_timeTemplate;
  NSString *_timeTemplate2;
}
@property (strong) IBOutlet NSMenu *menu;
@property (weak) AJMTAppDelegate* appDelegate;


- (IBAction)quickApp:(id)sender;
- (IBAction)openDateTimePrefs:(id)sender;
- (IBAction)openPrefs:(id)sender;
- (IBAction)openCalendar:(id)sender;
- (void)timeZone:(NSString*)tz atIndex:(int)indx added:(BOOL)added;
- (id)initWithNibName:(NSString *)nibNameOrNil appDelegate:(AJMTAppDelegate*)appDel;
- (void) loadSelf;
@end
