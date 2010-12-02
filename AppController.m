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

#include "AppController.h"

/* ---------------------
   - Private Interface -
   ---------------------*/

@interface AppController(Private)

- (void) _updateView: (id)sender;

@end

@implementation AppController

/* --------------------------
   - Initialization Methods -
   --------------------------*/

- (void) dealloc
{
  RELEASE(mpdController);
  RELEASE(anTimer);

  [super dealloc];

}

/* ---------------
   - Gui Methods -
   ---------------*/

- (void) awakeFromNib
{
  NSNotificationCenter *defCenter;
  BOOL reversedTime;

  defCenter = [NSNotificationCenter defaultCenter];

  [[NSApp mainMenu] setTitle:@"MPDCon"];

  [window setFrameAutosaveName: @"PlayerWindow"];

  mpdController = [MPDController sharedMPDController];

  prevState = state_NOCONN;



  [defCenter addObserver: self
		selector: @selector(didDisconnect:)
		    name: DidNotConnectNotification
		  object: nil];

  [defCenter addObserver: self
		selector: @selector(didConnect:)
		    name: DidConnectNotification
		  object: nil];
  
  [defCenter addObserver: self
		selector: @selector(prefsChanged:)
		    name: PreferencesChangedNotification
		  object: nil];

  didDisconnect = NO;

  [self connect: self];

  reversedTime = [[NSUserDefaults standardUserDefaults] 
		   boolForKey: @"reversedTime"];

  [playView setReversedTime: reversedTime];
}

- (void) showPrefPanel: (id)sender
{
  [[PreferencesController sharedPreferencesController] showWindow: sender];
}

- (void) showPlaylist: (id)sender
{
  if (! connected)
    {
      return;
    }

  [[PlaylistController sharedPlaylistController] showWindow: sender];

}

- (void) managePlaylists: (id)sender
{
  if (! connected)
    {
      return;
    }

  [[PlaylistsManagerController sharedPLManagerController] showWindow: sender];
}

- (void) browseCollection: (id)sender
{
  if (! connected)
    {
      return;
    }

  [[CollectionController sharedCollectionController] showWindow: self];
}

- (void) serverStatistics: (id)sender
{
  if (! connected)
    {
      return;
    }

  [[StatisticsController sharedStatisticsController] showWindow: sender];
}

- (void) showCrossfade: (id)sender
{
  if (! connected)
    {
      return;
    }

  [[CrossfadeController sharedCrossfadeController] showWindow: sender];
}

- (void) connect: (id)sender
{
  NSString *host;
  NSString *port;
  NSString *pword;

  host = [[NSUserDefaults standardUserDefaults] 
	   objectForKey: @"mpdHost"];
  port = [[NSUserDefaults standardUserDefaults] 
	   objectForKey: @"mpdPort"];

  pword = nil;

  if ([[NSUserDefaults standardUserDefaults] 
	integerForKey: @"usePassword"] != 0)
    {
      pword = [[NSUserDefaults standardUserDefaults] 
		objectForKey: @"mpdPassword"];
    }
  
  if ((host == nil) || (port == nil))
    {
      [self showPrefPanel: self];
    }
  else 
    {
      didDisconnect = NO;
      [mpdController connectToServer: host port: port password: pword];
    }
}

- (void) updateCollection: (id) sender
{
  [mpdController updateCollection];
}

- (void) play: (id)sender
{ 
  if (! connected)
    {
    return;
    }

  [mpdController play];
}

- (void) stop: (id)sender
{
  if (! connected)
    {
      return;
    }
  
  [mpdController stop];
}

- (void) prev: (id)sender
{
  if (! connected)
    {
      return;
    }
  
  [mpdController prev];
}

- (void) next: (id)sender
{
  if (! connected)
    {
      return;
    }
  
  [mpdController next];
}

- (void) shuffle: (id)sender
{
  if (! connected)
    return;
  [mpdController toggleShuffle];
}

- (void) repeat: (id)sender
{
  if (! connected)
    {
      return;
    }
  
  [mpdController toggleRepeat];
}

- (void) percentChanged: (id)sender
{
  int seekTime;

  if (! connected) 
    {
      [percentSlider setFloatValue: 0.0];
      return;
    }
  
  if ([mpdController getState] == state_NOCONN) 
    {
      [percentSlider setFloatValue: 0.0];
      return;
    }
  
  seekTime = (int) [percentSlider floatValue];
  
  [mpdController seekToTime: seekTime];
  
  [playView setElapsedTime: seekTime];
}

- (void) volumeChanged: (id)sender
{
  if ((! connected) || ([mpdController getState] == state_NOCONN) 
      || ([mpdController getVolume] == MPD_STATUS_NO_VOLUME)) 
    {
      [volumeSlider setFloatValue: 0.0];
      return;
    }
  
  [mpdController setVolume: [volumeSlider floatValue]];
}

/* ------------------------
   - Notification Methods -
   ------------------------*/

- (void) didDisconnect: (NSNotification *)notif
{
  if (!didDisconnect) 
    {
      didDisconnect = YES;
      if (connected) 
	{
	  if (anTimer) 
	    {
	      [anTimer invalidate];
	    }
	}
      
      connected = NO;

      [playView enableDisplay: NO];

      [playButton setImage: [NSImage imageNamed: @"Play.tiff"]];

      [percentSlider setFloatValue: 0.0];

      NSRunAlertPanel(_(@"Server Problems"), [notif object], nil, nil, nil);
    }
}

- (void) didConnect: (NSNotification *)aNotif
{
  if (! connected) 
    {
      connected = YES;
      anTimer = [NSTimer scheduledTimerWithTimeInterval: 1 
			                         target: self 
                                               selector: 
			                            @selector(_updateView:) 
			                       userInfo: nil 
			                        repeats: YES];
    }
  
  didDisconnect = NO;
}


- (void) prefsChanged: (NSNotification *)notif
{
  [self connect: self];
}

/* -------------------
   - Service Methods -
   -------------------*/

- (void) getPlaylist: (NSPasteboard*)pboard
	    userData: (NSString*)userData
	       error: (NSString**)error
{
  NSMutableString *allSongsString;
  NSString *formString;
  NSArray *playlist;
  int length;
  int totaltime, tMin, tSecs, tHour;

  int i, j;

  allSongsString = [[NSMutableString alloc] init];
  
  playlist = [mpdController getPlaylist];

  length = [[NSString stringWithFormat: @"%d", [playlist count]] length];

  formString = [NSString stringWithFormat: @"Track %s%d%s - ", 
		 "%", length, "d/%d"];

  j = [playlist count];

  totaltime = 0;
  for (i = 0; i < j; i++) 
    {
      int time;
      
      [allSongsString appendString: 
			[NSString stringWithFormat: formString, i+1, j]];
      [allSongsString appendString: [[playlist objectAtIndex: i] getArtist]];
      [allSongsString appendString: @" - "];
      [allSongsString appendString: [[playlist objectAtIndex: i] getTitle]];
      [allSongsString appendString: @" - "];
      
      time = [[playlist objectAtIndex: i] getTotalTime];

      totaltime += time;

      tSecs = (time % 60);
      tMin = (int) time/60;
      
      [allSongsString appendString: 
			[NSString stringWithFormat: @"%d:%02d\n", 
				  tMin, tSecs]];
    }

  tSecs = (totaltime % 60);
  tMin = (int) (totaltime/60) % 60;
  tHour = (int) totaltime/3600;

  [allSongsString appendString: 
		    [NSString stringWithFormat: 
			      @"\nTotal Playtime: %d:%02d:%02d\n", 
			      tHour, tMin, tSecs]];
   
  [pboard declareTypes: [NSArray arrayWithObject: NSStringPboardType]
	         owner: nil];
  
  [pboard setString: allSongsString forType: NSStringPboardType];

  return;
}

- (void) getAlbums: (NSPasteboard*)pboard
	  userData: (NSString*)userData
	     error: (NSString**)error
{
  NSMutableString *allAlbumsString;
  NSArray *artists;

  int i;

  allAlbumsString = [[NSMutableString alloc] init];
  
  artists = [mpdController getAllArtists];

  for (i = 0; i < [artists count]; i++) 
    {
      NSString *artist;
      NSArray *albums;

      int j;

      artist = [artists objectAtIndex: i];
      
      albums = [mpdController getAlbumsForArtist: artist];

      for (j = 0; j < [albums count]; j++) 
	{
	  NSString *album;

	  album = [albums objectAtIndex: j];
	  
	  [allAlbumsString appendString: 
			     [NSString stringWithFormat: @"%@ - %@\n", 
				       artist, album]];
	}
    }
  
  [pboard declareTypes: [NSArray arrayWithObject: NSStringPboardType]
	         owner: nil];
  
  [pboard setString: allAlbumsString forType: NSStringPboardType];
  return;
}

/* --------------------------------
   - Application Delegate Methods -
   --------------------------------*/

- (void) applicationDidFinishLaunching: (NSNotification *)not
{
  [NSApp setServicesProvider: self];
}



 - (BOOL) validateMenuItem: (id<NSMenuItem>)menuItem
{
  
  switch ([menuItem tag]) 
    {
    case 10:
    case 14:
    case 15:
    case 16:
    case 17:
    case 18:
      return connected;
      break;
    case 13:
      return didDisconnect;
      break;
    default:
      return YES;
      break;
    }
  
}

@end


/* -------------------
   - Private Methods -
   -------------------*/
 @implementation AppController(Private)
 
- (void) _updateView: (id)sender
{
  int volume;
  int state;

  if (! connected)
    {
      return;
    }

  if ([mpdController getState] == state_NOCONN) 
    {
      return;
    }
  
  if ([mpdController playlistChanged]) 
    {
      NSNotification *aNotif;

      aNotif = [NSNotification notificationWithName: 
				      PlaylistChangedNotification
			                     object: nil];
      
      [[NSNotificationCenter defaultCenter] 
	postNotification: aNotif];
    }

  if ([mpdController isRandom]) 
    {
      [shuffleButton highlight: YES];
    }
  else 
    {
      [shuffleButton highlight: NO];
    }
  
  if ([mpdController isRepeat])
    {
      [repeatButton highlight: YES];
    }
  else
    {
      [repeatButton highlight: NO];
    }

  volume = [mpdController getVolume];

  if (volume == MPD_STATUS_NO_VOLUME) 
    {
      [volumeSlider setIntValue: 0];
    }
  else
    {
      [volumeSlider setIntValue: [mpdController getVolume]];
    }

  state = [mpdController getState];

  if((state == state_PLAY) || (state == state_PAUSE))
    {
      PlaylistItem *currSong;
      
      int currentSongNr;
      int playlistLength;
      
      
      currentSongNr = [mpdController getCurrentSongNr];
      
      playlistLength = [mpdController getPlaylistLength];
      
      currSong = RETAIN([mpdController getCurrentSong]);
      
      if (currentSongNr != playedSong) 
	{
	  playedSong = currentSongNr;
	  if ([currSong getTotalTime] != 0) 
	    {
	      [percentSlider setMaxValue: (double) [currSong getTotalTime]];
	    }
	  
	  [[NSNotificationCenter defaultCenter] 
	    postNotification: [NSNotification 
				notificationWithName: SongChangedNotification 
				              object: nil]];
	}
      
      [playView enableDisplay: YES];
      
      [playView setCurrentSong: currentSongNr];
      [playView setTotalSongs: playlistLength];
      
      if((state == state_PAUSE) && (prevState != state_PAUSE)) 
	{
	  NSImage *pImage;
	  
	  prevState = state_PAUSE;
	  
	  pImage = [NSImage imageNamed: @"Play.tiff"];
	  
	  [playButton setImage: pImage];
	  
	} 
      else if ((state == state_PLAY) &&(prevState != state_PLAY)) 
	{
	  NSImage *pImage;

	  prevState = state_PLAY;
	  
	  pImage = [NSImage imageNamed: @"Pause.tiff"];
	  
	  [playButton setImage: pImage];
	  
	  [[NSNotificationCenter defaultCenter] 
	    postNotification: [NSNotification 
				notificationWithName: SongChangedNotification 
				              object: nil]];
	}
      
      [playView setDisplaySong: currSong];
      
      if ([currSong getTotalTime] != 0) 
	{
	  [percentSlider setDoubleValue: (double)[currSong getElapsedTime]];
	}
      
      RELEASE(currSong);
    } 
  else if (prevState != state_STOP) 
    {
      NSImage *pImage;

      prevState = state_STOP;
      
      pImage = [NSImage imageNamed: @"Play.tiff"];
      [playButton setImage: pImage];
      
      [playButton setTitle: @"Play"];
      
      [percentSlider setFloatValue: 0.0];
      
      [playView enableDisplay: NO];
      
      [[NSNotificationCenter defaultCenter] 
	postNotification: [NSNotification 
			    notificationWithName: SongChangedNotification 
			                  object: nil]];
    }  
  
}


@end
