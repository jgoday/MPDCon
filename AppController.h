/* 
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-12 17:59:14 +0200 by flip
   
   Application Controller

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
 
#ifndef _PCAPPPROJ_APPCONTROLLER_H
#define _PCAPPPROJ_APPCONTROLLER_H

#include <AppKit/AppKit.h>
#include "PlayView.h"
#include "PreferencesController.h"
#include "PlaylistController.h"
#include "PlaylistItem.h"
#include "MPDController.h"
#include "PlaylistsManagerController.h"
#include "StatisticsController.h"
#include "CrossfadeController.h"
#include "Strings.h"

#define player_MPD 0
#define player_CD 1

@interface AppController : NSObject
{
  IBOutlet NSButton *playButton;
  IBOutlet NSButton *stopButton;
  IBOutlet NSButton *prevButton;
  IBOutlet NSButton *nextButton;
  IBOutlet NSButton *shuffleButton;
  IBOutlet NSButton *repeatButton;
  IBOutlet PlayView *playView;
  IBOutlet NSSlider *percentSlider;
  IBOutlet NSSlider *volumeSlider;

  IBOutlet NSWindow *window;

  IBOutlet NSMenuItem *statisticsItem;
  IBOutlet NSMenuItem *browseItem;
  IBOutlet NSMenuItem *updateItem;
  IBOutlet NSMenuItem *showItem;
  IBOutlet NSMenuItem *manageItem;
  

  NSTimer *anTimer;

  int player;
  int playedSong;
  int prevState;

  BOOL connected;
  BOOL didDisconnect;

  MPDController *mpdController;
}

// Gui Methods
- (void) showPrefPanel:(id)sender;
- (void) showPlaylist: (id)sender;
- (void) managePlaylists: (id)sender;
- (void) browseCollection: (id)sender;
- (void) serverStatistics: (id)sender;
- (void) showCrossfade: (id)sender;

- (void) connect: (id)sender;

- (void) updateCollection: (id)sender;

- (void) play: (id)sender;
- (void) stop: (id)sender;
- (void) prev: (id)sender;
- (void) next: (id)sender;
- (void) shuffle: (id)sender;
- (void) repeat: (id)sender;
- (void) percentChanged: (id)sender;
- (void) volumeChanged: (id)sender;

// Notification Methods

- (void) didDisconnect: (NSNotification *)notif;
- (void) didConnect: (NSNotification *)notif;
- (void) prefsChanged: (NSNotification *)notif;

// Service Methods
- (void) getPlaylist: (NSPasteboard*)pboard 
            userData: (NSString*)userData 
               error: (NSString**)error;

- (void) getAlbums: (NSPasteboard*)pboard 
          userData: (NSString*)userData 
             error: (NSString**)error;

@end

#endif
