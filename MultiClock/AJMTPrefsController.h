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
}
@property (strong) IBOutlet NSWindow *window;
@property (weak) AJMTAppDelegate *delegate;
- (void) openPrefs;
- (void) cellClicked:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil appDelegate:(AJMTAppDelegate*)delegate;
@property (strong) IBOutlet NSTableView *tableView;
@end
