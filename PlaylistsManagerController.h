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

#ifndef _PCAPPPROJ_PLAYLISTSMANAGERCONTROLLER_H
#define _PCAPPPROJ_PLAYLISTSMANAGERCONTROLLER_H

#include <AppKit/AppKit.h>
#include "MPDController.h"
#include "Strings.h"

@interface PlaylistsManagerController : NSWindowController
{
  IBOutlet NSTableView *listView;
  IBOutlet NSTextField *saveField;
  IBOutlet NSWindow *window;
  MPDController *mpdController;

  NSArray *playlists;
}
// Initialization Methods
+ (id) sharedPLManagerController;

// Gui Methods
- (void) updateLists: (id)sender;
- (void) loadList: (id)sender;
- (void) saveList: (id)sender;
- (void) removeList: (id)sender;

// TableView dataSource Methods
- (int) numberOfRowsInTableView: (NSTableView *)tableView;

-            (id) tableView: (NSTableView *)tableView 
  objectValueForTableColumn: (NSTableColumn *)tableColumn 
                        row:(int)row;

// Notification Methods
- (void) tableViewSelectionDidChange: (NSNotification *)aNotif;
- (void) didNotConnect: (NSNotification *)aNotif;

@end

#endif
