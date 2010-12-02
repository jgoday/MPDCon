/* 
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-12 17:59:14 +0200 by flip
   
   PlaylistsManager Controller

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
#include "PlaylistsManagerController.h"

@implementation PlaylistsManagerController

/* --------------------------
   - Initialization Methods -
   --------------------------*/

+ (id) sharedPLManagerController
{
  static PlaylistsManagerController *_sharedPLManagerController = nil;

  if (! _sharedPLManagerController) 
    {
      _sharedPLManagerController = [[PlaylistsManagerController allocWithZone: [self zone]] init];
    }
  
  return _sharedPLManagerController;
}

- (id) init
{
  self = [self initWithWindowNibName: @"PlaylistsManager"];

  if (self) 
    {
      [self setWindowFrameAutosaveName: @"PlaylistsManager"];
    }

  mpdController = [MPDController sharedMPDController];

  return self;
}

- (void) dealloc
{
  RELEASE(playlists);

  [super dealloc];
}

/* ---------------
   - Gui Methods -
   ---------------*/

- (void) awakeFromNib
{
  [listView setTarget: self];
  [listView setDoubleAction: @selector(loadList:)];

  [[NSNotificationCenter defaultCenter] addObserver: self
					   selector: @selector(didNotConnect:)
					       name: DidNotConnectNotification
					     object: nil];

  [self updateLists: self];
}

- (void) updateLists: (id)sender
{
  RELEASE(playlists);

  playlists = RETAIN([mpdController getAllPlaylists]);

  [listView deselectAll: self];
  [listView reloadData];
}


- (void) loadList: (id)sender
{
  if ([listView selectedRow] >= 0) 
    {
      [mpdController loadPlaylist: [playlists objectAtIndex: [listView selectedRow]]];
    }
}


- (void) saveList: (id)sender
{
  NSString *name;

  name = [saveField stringValue];
  
  if ([name isEqual: @""]) 
    {
      return;
    }

  if ([playlists containsObject: name]) 
    {
      int answer;

      answer = NSRunAlertPanel(_(@"Playlist exists"), _(@"Overwrite it?"), 
			       _(@"Ok"), _(@"Cancel"), nil);

      if (answer != NSAlertDefaultReturn) 
	{
	  return;
	}
    }

  [mpdController removePlaylist: name];
  [mpdController savePlaylist: name];

  [saveField setStringValue: @""];
  
  [self updateLists: self];

}

- (void) removeList: (id)sender
{
  if ([listView selectedRow] >= 0) 
    {
      [mpdController removePlaylist: [playlists objectAtIndex: [listView selectedRow]]];
    }
  
  [self updateLists: self];
}

/* --------------------------------
   - TableView dataSource Methods -
   --------------------------------*/

- (int) numberOfRowsInTableView: (NSTableView *)tableView
{
  return [playlists count];
}

- (id) tableView: (NSTableView *)tableView objectValueForTableColumn: (NSTableColumn *)tableColumn 
	     row:(int)row
{
  return [playlists objectAtIndex: row];
}

/* ------------------------
   - Notification Methods -
   ------------------------*/

- (void) tableViewSelectionDidChange: (NSNotification *)aNotif
{
  if ([listView selectedRow] == -1)
    {
      [saveField setStringValue: @""];
    }
  else
    {
      [saveField setStringValue: [playlists objectAtIndex: [listView selectedRow]]];
    }
}

- (void) didNotConnect: (NSNotification *)aNotif
{
  [[self window] performClose: self];
}
@end
