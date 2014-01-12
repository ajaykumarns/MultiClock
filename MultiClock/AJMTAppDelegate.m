//
//  AJMTAppDelegate.m
//  MultiClock
//
//  Created by Ajay Kumar Nadathur Sreenivasan on 1/11/14.
//  Copyright (c) 2014 Ajay Kumar Nadathur Sreenivasan. All rights reserved.
//

#import "AJMTAppDelegate.h"
#import "AJMTPrefsController.h"

@implementation AJMTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  NSLog(@"applicationDidFinishLaunching called. Calling Controller.init");
  [self createPrefsController];
  [self openPrefs];
}

-(void) windowWillClose:(NSNotification *)notification {
  NSLog(@"Close event being captured!");
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.prefsController = nil;
}

- (IBAction)createClicked:(id)sender {
  [self openPrefs];
}

- (void) createPrefsController {
  self.prefsController = [[AJMTPrefsController alloc] initWithNibName:@"AJMTPrefsController" appDelegate:self];
  NSLog(@"Finished calling controller.init at (%@), calling show now", [self prefsController]);
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(windowWillClose:)
                                               name:NSWindowWillCloseNotification
                                             object:self.prefsController.window];
}

- (void) openPrefs {
  if(!self.prefsController){
    [self createPrefsController];
  }
  
  [self.prefsController openPrefs];
}
@end
