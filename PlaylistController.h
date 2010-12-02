/* 
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-12 17:59:14 +0200 by flip
   
   Playlist Controller

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

#ifndef _PCAPPPROJ_PLAYLISTCONTROLLER_H
#define _PCAPPPROJ_PLAYLISTCONTROLLER_H

#include <AppKit/AppKit.h>
#include "MPDController.h"
#include "PlaylistItem.h"
#include "CollectionController.h"
#include "PlaylistsManagerController.h"
#include "Strings.h"

@interface PlaylistController : NSWindowController
{
  IBOutlet NSTableView *playlistTable;
  IBOutlet NSTextField *lengthView;
  IBOutlet NSPopUpButton *playlistSelector;
  IBOutlet NSPopUpButton *removeSelector;
  IBOutlet NSWindow *window;
  IBOutlet NSTextField *filterField;

  MPDController *mpdController;

  NSArray *playlist;
  NSMutableArray *playlistTimes;
  
  int currentSong;
}



// Initialization Methods
+ (id) sharedPlaylistController;

// GUI Methods
- (void) removeSongs: (id)sender;
- (void) managePlaylists: (id)sender;
- (void) doubleClicked: (id)sender;
- (void) showCurrentSong: (id)sender;
- (void) shuffleList: (id)sender;
- (void) browseCollection: (id)sender;
- (void) filterList: (id)sender;
- (void) clearFilter: (id)sender;

// TableView dataSource Methods
- (int) numberOfRowsInTableView: (NSTableView *)tableView;

-           (id) tableView: (NSTableView *)tableView 
 objectValueForTableColumn: (NSTableColumn *)tableColumn 
                       row:(int) row;

// TableView dragging Methods
- (NSDragOperation) tableView: (NSTableView *)tv 
                 validateDrop: (id <NSDraggingInfo>)info 
                  proposedRow: (int)row 
        proposedDropOperation: (NSTableViewDropOperation)dropOperation;

- (BOOL) tableView: (NSTableView *)tv 
        acceptDrop: (id <NSDraggingInfo>)info 
               row: (int)row 
     dropOperation: (NSTableViewDropOperation)dropOperation;

- (BOOL) tableView: (NSTableView *)tv 
         writeRows: (NSArray *)rows 
      toPasteboard: (NSPasteboard*)pboard;

// Notification Methods
- (void) songChanged: (NSNotification *)aNotif;
- (void) playlistChanged: (NSNotification *)aNotif;
- (void) didNotConnect: (NSNotification *)aNotif;
@end

#endif
