//
//  AJMTPrefsController.m
//  MultiClock
//
//  Created by Ajay Kumar Nadathur Sreenivasan on 1/11/14.
//  Copyright (c) 2014 Ajay Kumar Nadathur Sreenivasan. All rights reserved.
//

#import "AJMTPrefsController.h"
#import "AJMTDataStore.h"
#import "AJMTAppDelegate.h"


#define TZ_COL_NAME         @"timeZoneColumn"

@implementation AJMTPrefsController

- (id)initWithNibName:(NSString *)nibNameOrNil appDelegate:(AJMTAppDelegate*)delegate {
  self = [super initWithNibName:nibNameOrNil bundle:nil];
  if (self){
    self.appDelegate = delegate;
    _selectedImg = [NSImage imageNamed:@"selected.png"];
    _notSelectedImg = nil;//[NSImage imageNamed:@""];
    _tzMappings = [NSTimeZone abbreviationDictionary];
    _allTimeZones = [_tzMappings allKeys];
    /*
    NSDictionary *dict = [NSTimeZone abbreviationDictionary];
    for(NSString *key in [dict allKeys]){
      NSLog(@"%@ -> %@", key, [dict objectForKey:key]);
    }*/
  }
  return self;
}

-(void) awakeFromNib {
  [self.tableView setTarget:self];
  [NSApp activateIgnoringOtherApps:YES];
  [self.tableView setDoubleAction:@selector(cellClicked:)];
}

-(int) prefForKey:(NSString*)key {
  return [AJMTDataStore boolForKey:key] ? NSOnState : NSOffState;
}

-(void) openPrefs {
  [self view];
  self.timeSecs.state       = [self prefForKey:PREF_DISPLAY_SECS];
  self.flashSeps.state      = [self prefForKey:PREF_FLASH_SEP];
  self.militaryClock.state  = [self prefForKey:PREF_24HR_CLK];
  self.showAmPm.state       = [self prefForKey:PREF_SHOW_AM_PM];
  self.showDayOfWeek.state  = [self prefForKey:PREF_SHOW_DAY_WEEK];
  self.showDate.state       = [self prefForKey:PREF_SHOW_DATE];
  
  [self.window setIsVisible:YES];
  NSLog(@"Opening preferences with window: %@", self.window);
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  NSSet *selectedTz = [NSSet setWithArray:[AJMTDataStore monitoredTimeZones]];

  if([tableColumn.identifier isEqualToString:TZ_COL_NAME]){
    NSString *tzKey = [_allTimeZones objectAtIndex:row];
    NSString *tzAbbrev = [_tzMappings objectForKey:tzKey];
    BOOL selected = [selectedTz containsObject:tzKey];
    
    cellView.textField.stringValue = [NSString stringWithFormat:@"%@ (%@)", tzAbbrev, tzKey];
    cellView.imageView.image = selected ? _selectedImg : _notSelectedImg;
    return cellView;
  }
  
  return cellView;
}

- (void) cellClicked:(id)sender{
  long selectedRow = [self.tableView clickedRow];
  NSString *selectedTz = [_allTimeZones objectAtIndex:selectedRow];
  NSUInteger index = [[AJMTDataStore monitoredTimeZones] indexOfObject:selectedTz];
  if(index == NSNotFound){ //new item.
    [AJMTDataStore addMonitoredTimeZone:selectedTz];
  } else {
    [AJMTDataStore removeMonitoredTimeZone:selectedTz];
  }
  
    //call into app delegate for further processing...
  [self.appDelegate timeZone:selectedTz atIndex:(int)index added:(index == NSNotFound)];
  [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (void) buttonClick:(id)sender {
  NSString *sid = [sender identifier];
  BOOL isOn = ([sender state] == NSOnState);
  [AJMTDataStore setBool:isOn forKey:sid];
}

  //////////////////////// Utility functions ///////////////////////////
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [_allTimeZones count];
}

@end
