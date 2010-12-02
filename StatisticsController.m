/* 
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-12 17:59:14 +0200 by flip
   
   Statistics Controller

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#include <AppKit/AppKit.h>
#include "StatisticsController.h"

@implementation StatisticsController

/* --------------------------
   - Initialization Methods -
   --------------------------*/

+ (id) sharedStatisticsController
{
  static StatisticsController *_sharedStatisticsController = nil;

  if (! _sharedStatisticsController) 
    {
//      _sharedStatisticsController = [[StatisticsController allocWithZone: [self zone]] init];
        _sharedStatisticsController = [[StatisticsController alloc] init];
    }

  return _sharedStatisticsController;
}

- (id) init
{
  self = [self initWithWindowNibName: @"StatisticsViewer"];
  
  if (self) 
    {
      [self setWindowFrameAutosaveName: @"StatisticsViewer"];
    }

  return self;
}

/* ---------------
   - Gui Methods -
   ---------------*/

- (void) closeWindow: (id)sender
{
  [[self window] performClose: self];
}


- (void) updateStatistics: (id)sender
{
  StatisticsItem *statItem;

  int secs, mins, hours;

  statItem = RETAIN([[MPDController sharedMPDController] getStatistics]);

  [songs setIntValue: [statItem getNumberOfSongs]];
  [artists setIntValue: [statItem getNumberOfArtists]];
  [albums setIntValue: [statItem getNumberOfAlbums]];
  
  secs = [statItem getUptime] % 60;
  mins = ((int) [statItem getUptime] / 60) % 60;
  hours = (int) [statItem getUptime] / 3600;

  [uptime setStringValue: [NSString stringWithFormat: @"%d:%02d:%02d", hours, mins, secs]];

  [dbUpdatetime setStringValue: [[NSDate dateWithTimeIntervalSince1970: 
					   [statItem getDbUpdatetime]] description]];

  secs = [statItem getPlaytime] % 60;
  mins = ((int) [statItem getPlaytime] / 60) % 60;
  hours = (int) [statItem getPlaytime] / 3600;

  [playtime setStringValue: [NSString stringWithFormat: @"%d:%02d:%02d", hours, mins, secs]];

  secs = [statItem getDbPlaytime] % 60;
  mins = ((int) [statItem getDbPlaytime] / 60) % 60;
  hours = (int) [statItem getDbPlaytime] / 3600;

  [dbPlaytime setStringValue: [NSString stringWithFormat: @"%d:%02d:%02d", hours, mins, secs]];

  RELEASE(statItem);
}


- (void) awakeFromNib
{
  
  [[NSNotificationCenter defaultCenter] addObserver: self
					selector: @selector(didNotConnect:)
					name: DidNotConnectNotification
					object: nil];
  [self updateStatistics: self];
}


/* ------------------------
   - Notification Methods -
   ------------------------*/

- (void) didNotConnect: (NSNotification *)aNotif
{
  [[self window] performClose: self];
}
@end
