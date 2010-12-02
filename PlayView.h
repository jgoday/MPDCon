/* 
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-12 17:59:14 +0200 by flip
   
   Custom View : Shows Trackinfos etc.

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

#ifndef _PCAPPPROJ_PLAYVIEW_H
#define _PCAPPPROJ_PLAYVIEW_H

#include <AppKit/AppKit.h>
#include "PlaylistItem.h"
#include "Strings.h"

@interface PlayView : NSView
{
  PlaylistItem *dispSong;
  int currentSong, totalSongs;
  BOOL displayEnabled;

  int artistScroll, titleScroll, albumScroll;
  BOOL artistScrollForward, titleScrollForward, albumScrollForward;
  BOOL reversedTime;
  BOOL notificationAdded;
}

// Display Methods
- (void) setDisplaySong: (PlaylistItem *)newSong;
- (void) setCurrentSong: (int)newSong;
- (void) setTotalSongs: (int)newSong;
- (void) setElapsedTime: (int)newTime;
- (void) setReversedTime: (BOOL)reversed;
- (void) enableDisplay: (BOOL)enable;

// Notification Methods
- (void) songChanged: (NSNotification *)aNotif;

//NSColor *colorFromDict(NSDictionary *dict);
@end

#endif
