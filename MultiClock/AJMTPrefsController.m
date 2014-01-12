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
    _tzMappings = [NSTimeZone abbreviationDictionary];
    _allTimeZones = [_tzMappings allKeys];
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
  
  if(self.militaryClock.state == NSOnState){
    [self.showAmPm setEnabled:NO];
    [self setPrefToNo:PREF_SHOW_AM_PM];
  } else if(self.showAmPm.state == NSOnState){
    [self.militaryClock setEnabled:NO];
    [self setPrefToNo:PREF_24HR_CLK];
  }
  
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
    cellView.imageView.image = selected ? _selectedImg : nil;
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
  
  if ([PREF_SHOW_AM_PM isEqualToString:sid]) {
    if(isOn){
      [self.militaryClock setState:NSOffState];
      [self setPrefToNo:PREF_24HR_CLK];
    }
    [self.militaryClock setEnabled:!isOn];
  } else if([PREF_24HR_CLK isEqualToString:sid]){
    if(isOn){
      [self.showAmPm setState:NSOffState];
      [self setPrefToNo:PREF_SHOW_AM_PM];
    }
    [self.showAmPm setEnabled:!isOn];
  }
}

  //////////////////////// Utility functions ///////////////////////////
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [_allTimeZones count];
}

-(void) setPrefToNo:(NSString*)str {
  if([AJMTDataStore boolForKey:str]){
    [AJMTDataStore setBool:NO forKey:str];
  }
}

@end
