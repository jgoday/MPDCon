/* 
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-12 17:59:14 +0200 by flip
   
   Collection Controller

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

#ifndef _PCAPPPROJ_COLLECTIONCONTROLLER_H
#define _PCAPPPROJ_COLLECTIONCONTROLLER_H

#include <AppKit/AppKit.h>
#include "MPDController.h"
#include "PlaylistItem.h"
#include "Strings.h"
#include "BoldFormatter.h"
#include "NormalFormatter.h"


@interface CollectionController : NSWindowController
{
  IBOutlet NSBrowser *collectionView;
  IBOutlet NSTableView *trackView;
  IBOutlet NSWindow *window;
  IBOutlet NSTextField *filterField;

  NSArray *allArtists;
  NSArray *allAlbums;
  NSArray *allSongs;
  NSArray *filteredTracks;
}



// Initialization Methods
+ (id) sharedCollectionController;

// Playlist Methods
- (void) addSelected: (id)sender;

// Gui Methods
- (void) updateCollection: (id)sender;
- (void) doubleClicked: (id)sender;
- (void) filterCollection: (id)sender;
- (void) clearFilter: (id)sender;

// TableView dataSource Methods
- (int) numberOfRowsInTableView: (NSTableView *)tableView;

-            (id) tableView: (NSTableView *)tableView 
  objectValueForTableColumn: (NSTableColumn *)tableColumn 
                        row:(int) row;


// Browser delegate Methods
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell
          atRow:(int)row
         column:(int)column;
- (NSString *)browser:(NSBrowser *)sender
        titleOfColumn:(int)column;

- (void) selectionChanged: (id)sender;


// TableView dragging Methods
- (BOOL) tableView: (NSTableView *)tv 
         writeRows: (NSArray *)rows 
      toPasteboard: (NSPasteboard*)pboard;
      
// Notification Methods
- (void) didNotConnect: (NSNotification *)aNotif;
@end

#endif
