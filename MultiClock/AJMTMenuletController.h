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
  bool _blinked;
  __strong NSMenu *_menu;
}
- (IBAction)quickApp:(id)sender;
- (IBAction)openDateTimePrefs:(id)sender;
- (IBAction)openPrefs:(id)sender;
- (IBAction)openCalendar:(id)sender;


- (id)initWithNibName:(NSString *)nibNameOrNil appDelegate:(AJMTAppDelegate*)appDel;
@property (strong) IBOutlet NSMenu *menu;
@property (weak) AJMTAppDelegate* appDelegate;

@end
