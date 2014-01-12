//
//  AJMTPrefsController.m
//  MultiClock
//
//  Created by Ajay Kumar Nadathur Sreenivasan on 1/11/14.
//  Copyright (c) 2014 Ajay Kumar Nadathur Sreenivasan. All rights reserved.
//

#import "AJMTPrefsController.h"
#import "AJMTDataStore.h"
#define TZ_COL_NAME @"timeZoneColumn"

@implementation AJMTPrefsController

- (id)initWithNibName:(NSString *)nibNameOrNil appDelegate:(AJMTAppDelegate*)delegate {
  self = [super initWithNibName:nibNameOrNil bundle:nil];
  if (self){
    self.delegate = delegate;
    _selectedImg = [NSImage imageNamed:@"selected.png"];
    _notSelectedImg = nil;//[NSImage imageNamed:@""];
    _tzMappings = [NSTimeZone abbreviationDictionary];
    _allTimeZones = [_tzMappings allKeys];
    
    NSDictionary *dict = [NSTimeZone abbreviationDictionary];
    for(NSString *key in [dict allKeys]){
      NSLog(@"%@ -> %@", key, [dict objectForKey:key]);
    }
  }
  return self;
}

-(void) awakeFromNib {
  [self.tableView setTarget:self];
  [self.tableView setDoubleAction:@selector(cellClicked:)];
}

-(void) openPrefs {
  [self view];
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

  //////////////////////// Utility functions ///////////////////////////
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [_allTimeZones count];
}

- (NSArray*) availableTimezones {
  NSMutableSet *set = [NSMutableSet setWithArray:[[NSTimeZone abbreviationDictionary] allValues]];
  for (NSString* tz in [AJMTDataStore monitoredTimeZones]) {
    [set removeObject:tz];
  }
  NSMutableArray *result = [NSMutableArray arrayWithArray:[set allObjects]];
  return [result sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (void) cellClicked:(id)sender{
  long selectedRow = [self.tableView clickedRow];
  NSLog(@"Clicked row is: %ld", selectedRow);
  NSSet *savedTzs = [NSSet setWithArray:[AJMTDataStore monitoredTimeZones]];
  NSString *selectedTz = [_allTimeZones objectAtIndex:selectedRow];
  if([savedTzs containsObject:selectedTz]){
    [AJMTDataStore removeMonitoredTimeZone:selectedTz];
  } else {
    [AJMTDataStore addMonitoredTimeZone:selectedTz];
  }
  
  [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

@end
