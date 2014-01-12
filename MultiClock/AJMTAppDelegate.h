//
//  AJMTAppDelegate.h
//  MultiClock
//
//  Created by Ajay Kumar Nadathur Sreenivasan on 1/11/14.
//  Copyright (c) 2014 Ajay Kumar Nadathur Sreenivasan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AJMTPrefsController;
@class AJMTMenuletController;
@interface AJMTAppDelegate : NSObject <NSApplicationDelegate>
- (IBAction)createClicked:(id)sender;
@property (nonatomic,strong) AJMTPrefsController *prefsController;
@property (nonatomic,strong) AJMTMenuletController *menuController;

- (void)openPrefs;
@end
