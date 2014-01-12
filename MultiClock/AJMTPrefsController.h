//
//  AJMTPrefsController.h
//  MultiClock
//
//  Created by Ajay Kumar Nadathur Sreenivasan on 1/11/14.
//  Copyright (c) 2014 Ajay Kumar Nadathur Sreenivasan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AJMTAppDelegate;

@interface AJMTPrefsController : NSViewController{
  __strong NSImage *_selectedImg;
  __strong NSImage *_notSelectedImg;
  __strong NSArray *_allTimeZones;
  __strong NSDictionary* _tzMappings;
  __strong NSTableView *_tableView;
  NSButton *_timeSecs;
  NSButton *_flashSeps;
  NSButton *_militaryClock;
  NSButton *_showAmPm;
  NSButton *_showDayOfWeek;
  NSButton *_showDate;
}
@property (weak) AJMTAppDelegate *appDelegate;
@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSButton *timeSecs;
@property (strong) IBOutlet NSButton *flashSeps;
@property (strong) IBOutlet NSButton *militaryClock;
@property (strong) IBOutlet NSButton *showAmPm;
@property (strong) IBOutlet NSButton *showDayOfWeek;
@property (strong) IBOutlet NSButton *showDate;

- (void) openPrefs;
- (void) cellClicked:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil appDelegate:(AJMTAppDelegate*)delegate;
- (IBAction) buttonClick:(id)sender;
@end
