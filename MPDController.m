/*
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-14 11:37:03 +0200 by flip

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

#include "MPDController.h"

/* ---------------------
   - Private Interface -
   ---------------------*/
@interface MPDController(Private)

- (BOOL) _doConnect;
- (BOOL) _checkConnection;

- (PlaylistItem *) _getPlaylistItemForSong: (mpd_Song *)anSong;

int _stringSort(id string1, id string2, void *context);
@end

@implementation MPDController

/* --------------------------
   - Initialization Methods -
   --------------------------*/

+ (id) sharedMPDController
{
  static MPDController *_sharedMPDController = nil;

  if (! _sharedMPDController) 
    {
      _sharedMPDController = [[MPDController allocWithZone: [self zone]] init];
    }

  return _sharedMPDController;
}

- (void) dealloc
{
  mpd_closeConnection(mpdConnection);

  RELEASE(host);
  RELEASE(port);
  RELEASE(password);

  [super dealloc];
}

/* ----------------------
   - Connection Methods -
   ----------------------*/

- (BOOL) connectToServer: (NSString *)hostName 
                    port: (NSString *)portNr 
                password: (NSString *)pword
{
  if ((hostName) && (portNr)) 
    {
      BOOL didConnect;

      if (host)
	{
	  RELEASE(host);
	}

      if (port) 
	{
	  RELEASE(port);
	}
      
      if (password)
	{
	  RELEASE(password);
	}
      
      host = [hostName copy];
      port = [portNr copy];
      password = [pword copy];
    
      didConnect = [self _doConnect];
      mpd_closeConnection(mpdConnection);
      return didConnect;
    } 
  else 
    {
      return NO;
    }
}

/* ----------------
   - Play Methods -
   ----------------*/

- (void) play
{
  [self playSong: MPD_PLAY_AT_BEGINNING];
}

- (void) playSong: (int)theSong
{
  mpd_Status *mpdStatus;

  if (![self _doConnect])
    {
      return;
    }
  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);
  
  if (theSong != MPD_PLAY_AT_BEGINNING) 
    {
      mpd_sendPlayCommand(mpdConnection, theSong);
    } 
  else 
    {
      if(mpdStatus->state == MPD_STATUS_STATE_STOP) 
	{
	  mpd_sendPlayCommand(mpdConnection, 0);
	} 
      else 
	{
	  mpd_sendPauseCommand(mpdConnection,3-mpdStatus->state);
	}
    }
  
  mpd_finishCommand(mpdConnection);
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);
}

- (void) stop
{
  mpd_Status *mpdStatus;

  if (! [self _doConnect]) 
    {
      return;
    }

  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);

  if((mpdStatus->state == MPD_STATUS_STATE_PLAY) || 
     (mpdStatus->state == MPD_STATUS_STATE_PAUSE)) 
    {
      mpd_sendStopCommand(mpdConnection);
      mpd_finishCommand(mpdConnection);
    }
  
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);
}

- (void) prev
{
  mpd_Status *mpdStatus;
  
  if (! [self _doConnect]) 
    {
      return;
    }
  
  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);

  if((mpdStatus->state == MPD_STATUS_STATE_PLAY) || 
     (mpdStatus->state == MPD_STATUS_STATE_PAUSE)) 
    {
      mpd_sendPrevCommand(mpdConnection);
      mpd_finishCommand(mpdConnection);
    }
  
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);
}

- (void) next
{
  mpd_Status *mpdStatus;
  
  if (! [self _doConnect]) 
    {
      return;
    }

  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);

  if((mpdStatus->state == MPD_STATUS_STATE_PLAY) || 
     (mpdStatus->state == MPD_STATUS_STATE_PAUSE)) 
    {
      mpd_sendNextCommand(mpdConnection);
      mpd_finishCommand(mpdConnection);
    }
  
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);
}

- (void) toggleShuffle
{
  mpd_Status *mpdStatus;
  
  if (! [self _doConnect]) 
    {
      return;
  }
    
  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);
  
  mpd_sendRandomCommand(mpdConnection, (mpdStatus->random == 0) ? 1 : 0);
  mpd_finishCommand(mpdConnection);
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);
}

- (void) toggleRepeat
{
  mpd_Status *mpdStatus;
  
  if (! [self _doConnect]) 
    {
      return;
    }

  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);
  
  mpd_sendRepeatCommand(mpdConnection, (mpdStatus->repeat == 0) ? 1 : 0);
  mpd_finishCommand(mpdConnection);
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);
}

- (void) seekToTime: (int)time
{
  mpd_Status *mpdStatus;
  
  if (! [self _doConnect]) 
    {
      return;
    }
  
  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);
  
  if ((mpdStatus->state == MPD_STATUS_STATE_PLAY) 
      || (mpdStatus->state == MPD_STATUS_STATE_PAUSE)) 
    {
      mpd_sendSeekCommand(mpdConnection, mpdStatus->song, time);
      mpd_finishCommand(mpdConnection);
    }
  
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);
}

- (void) setVolume: (int)volume
{
  if (! [self _doConnect]) 
    {
      return;
    }
  
  mpd_sendSetvolCommand(mpdConnection, volume);
  
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
}

- (void) setCrossfade: (int)cfTime
{
  if (! [self _doConnect])
    {
      return;
    }

  mpd_sendCrossfadeCommand(mpdConnection, cfTime);
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection;
}

/* -----------------------
   - Information Methods -
   -----------------------*/

- (int) getState
{
  int state;
  mpd_Status *mpdStatus;

  if (! [self _doConnect]) 
    {
      return state_NOCONN;
    }
  
  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);

  if (! [self _checkConnection]) 
    {
      return state_NOCONN;
    }

  switch (mpdStatus->state) 
    {
    case MPD_STATUS_STATE_STOP:
      state = state_STOP;
      break;
    case MPD_STATUS_STATE_PLAY:
      state = state_PLAY;
      break;
    case MPD_STATUS_STATE_PAUSE:
      state = state_PAUSE;
      break;
  }
  
  mpd_finishCommand(mpdConnection);
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);

  return state;
}

- (BOOL) isRandom
{
  BOOL random;
  mpd_Status *mpdStatus;

  if (! [self _doConnect]) 
    {
      return NO;
    }
  
  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);

  if (! [self _checkConnection]) 
    {
      return NO;
    }

  if ((mpdStatus->random) == 1)
    {
      random = YES;
    }
  else
    {
      random = NO;
    }

  mpd_finishCommand(mpdConnection);
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);

  return random;
}

- (BOOL) isRepeat
{
  BOOL repeat;
  mpd_Status *mpdStatus;

  if (! [self _doConnect]) 
    {
      return NO;
    }
  

  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);

  if (! [self _checkConnection]) 
    {
      return NO;
    }

  if ((mpdStatus->repeat) == 1) 
    {
      repeat = YES;
    }
  else
    {
      repeat = NO;
    }

  mpd_finishCommand(mpdConnection);
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);
  
  return repeat;
}

- (int) getVolume
{
  int volume;
  mpd_Status *mpdStatus;

  if (! [self _doConnect]) 
    {
      return 0.0;
    }

  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);

  if (! [self _checkConnection]) 
    {
      return 0;
    }

  volume = mpdStatus->volume;
  
  mpd_finishCommand(mpdConnection);
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);
  
  return volume;
}

- (int) getCrossfade
{
  int cfTime;
  mpd_Status *mpdStatus;

  if (! [self _doConnect])
    {
      return 0;
    }

  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);

  if (! [self _checkConnection]) 
    {
      return 0;
    }

  cfTime = mpdStatus->crossfade;

  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);
  
  return cfTime;
}

- (StatisticsItem *) getStatistics
{
  mpd_Stats *mpdStats;
  StatisticsItem *statItem;

  if (! [self _doConnect])
    {
      return nil;
    }

  mpd_sendStatsCommand(mpdConnection);
  mpdStats = mpd_getStats(mpdConnection);

  if (! [self _checkConnection]) 
    {
      return nil;
    }

  statItem = [[StatisticsItem alloc] init];

  [statItem setNumberOfArtists: mpdStats->numberOfArtists];
  [statItem setNumberOfAlbums: mpdStats->numberOfAlbums];
  [statItem setNumberOfSongs: mpdStats->numberOfSongs];
  [statItem setUptime: mpdStats->uptime];
  [statItem setDbUpdatetime: mpdStats->dbUpdateTime];
  [statItem setPlaytime: mpdStats->playTime];
  [statItem setDbPlaytime: mpdStats->dbPlayTime];

  mpd_freeStats(mpdStats);
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);

  return AUTORELEASE(statItem);
}

/* ---------------------
   - Playlist Commands -
   ---------------------*/

- (PlaylistItem *) getCurrentSong
{
  mpd_Status *mpdStatus;
  mpd_InfoEntity *mpdInfoEntity;
  PlaylistItem *currSong;

  if (! [self _doConnect]) 
    {
      return nil;
    }
  
  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);

  if (! [self _checkConnection]) 
    {
      return nil;
    }

  if(mpdStatus->state == MPD_STATUS_STATE_PLAY ||
     mpdStatus->state == MPD_STATUS_STATE_PAUSE) 
    {
      mpd_sendPlaylistInfoCommand(mpdConnection, mpdStatus->song);
    
      while((mpdInfoEntity = mpd_getNextInfoEntity(mpdConnection))) 
	{
	  mpd_Song *mpdSong;

	  if(mpdInfoEntity->type!=MPD_INFO_ENTITY_TYPE_SONG) 
	    {
	      mpd_freeInfoEntity(mpdInfoEntity);
	      continue;
	    }
	  
	  mpdSong = mpdInfoEntity->info.song;
	  
	  currSong = RETAIN([self _getPlaylistItemForSong: mpdSong]);
	  
	  [currSong setElapsedTime: mpdStatus->elapsedTime];
	  [currSong setTotalTime: mpdStatus->totalTime];
	  
	  mpd_freeInfoEntity(mpdInfoEntity);
	  break;
	}
      
      mpd_finishCommand(mpdConnection);
    } 
  
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);

  if (currSong)
    {
      return AUTORELEASE(currSong);
    }
  else
    {
      return nil;
    }
}

- (int) getCurrentSongNr
{
  int songNr;
  mpd_Status *mpdStatus;

  if (! [self _doConnect]) 
    {
      return -1;
    }

  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);
  
  if (! [self _checkConnection]) 
    {
      return -1;
    }
  
  songNr = mpdStatus->song+1;

  mpd_finishCommand(mpdConnection);
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);

  return songNr;
}

- (int) getPlaylistLength
{
  int length;
  mpd_Status *mpdStatus;

  if (! [self _doConnect]) 
    {
      return 0;
    }
  
  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);
  
  if (! [self _checkConnection]) 
    {
      return 0;
    }

  length = mpdStatus->playlistLength;

  mpd_finishCommand(mpdConnection);
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);
  
  return length;
}

- (NSArray *) getPlaylist
{
  NSMutableArray *playlist;
  mpd_InfoEntity *mpdInfoEntity;

  if (! [self _doConnect]) 
    {
      return nil;
    }
  
  mpd_sendPlaylistInfoCommand(mpdConnection, -1);

  if (! [self _checkConnection]) 
    {
      mpd_finishCommand(mpdConnection);
      mpd_closeConnection(mpdConnection);
      return nil;
    }
  
  playlist = [[NSMutableArray alloc] init];
  
  while((mpdInfoEntity = mpd_getNextInfoEntity(mpdConnection))) 
    {
      if(mpdInfoEntity->type=MPD_INFO_ENTITY_TYPE_SONG) 
	{
	  mpd_Song *mpdSong;
	  PlaylistItem *tmpSong;

	  mpdSong = mpdInfoEntity->info.song;

	  tmpSong = RETAIN([self _getPlaylistItemForSong: mpdSong]);

	  [playlist addObject: tmpSong];

	  RELEASE(tmpSong);	
	}
      
      mpd_freeInfoEntity(mpdInfoEntity);
    }
  
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);

  return AUTORELEASE(playlist);
}

- (BOOL) playlistChanged
{
  BOOL changed;
  mpd_Status *mpdStatus;

  if (! [self _doConnect]) 
    {
      return NO;
    }

  changed = NO;
  mpd_sendStatusCommand(mpdConnection);
  mpdStatus = mpd_getStatus(mpdConnection);
  
  if (! [self _checkConnection]) 
    {
      return NO;
    }

  if (mpdStatus->playlist != currPlaylist) 
    {
      currPlaylist = mpdStatus->playlist;
      changed = YES;
    }

  mpd_finishCommand(mpdConnection);
  mpd_freeStatus(mpdStatus);
  mpd_closeConnection(mpdConnection);
  
  return changed;
}

- (void) shuffleList
{
  if (! [self _doConnect])
    {
      return;
    }

  mpd_sendShuffleCommand(mpdConnection);
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
}

- (void) clearPlaylist
{
  if (! [self _doConnect]) 
    {
      return;
    }

  mpd_sendClearCommand(mpdConnection);
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
}

- (void) removeSong: (int)song
{
  if (! [self _doConnect]) 
    {
      return;
    }

  mpd_sendDeleteCommand(mpdConnection, song);
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
}

- (void) addTrack: (NSString *)file
{
  if (! [self _doConnect]) 
    {
      return;
    }
  
  mpd_sendAddCommand(mpdConnection, [file UTF8String]);
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
}

- (void) moveSongNr: (int)song1 to: (int)song2
{
  if (! [self _doConnect])
    {
      return;
    }
  
  mpd_sendMoveCommand(mpdConnection, song1, song2);
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
}

- (void) moveSongWithID: (int)song1 to: (int)song2
{
  if (! [self _doConnect])
    {
      return;
    }
  
  mpd_sendMoveIdCommand(mpdConnection, song1, song2);
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
}

- (NSArray *) getAllPlaylists
{
  NSMutableArray *tmpArray;
  mpd_InfoEntity *mpdInfoEntity;

  if (! [self _doConnect]) 
    {
      return nil;
    }


  mpd_sendLsInfoCommand(mpdConnection, "");

  if (! [self _checkConnection]) 
    {
      return nil;
    }
  
  tmpArray = [[NSMutableArray alloc] init];

  while((mpdInfoEntity = mpd_getNextInfoEntity(mpdConnection))) 
    {
      if(mpdInfoEntity->type==MPD_INFO_ENTITY_TYPE_PLAYLISTFILE) 
	{
	  mpd_PlaylistFile *mpdPlaylistFile = mpdInfoEntity->info.playlistFile;
	  [tmpArray addObject: [NSString stringWithUTF8String: mpdPlaylistFile->path]];
	}
      mpd_freeInfoEntity(mpdInfoEntity);
    }
  
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
  
  return AUTORELEASE(tmpArray);
  
}

- (void) loadPlaylist: (NSString *)title
{
  if (! [self _doConnect]) 
    {
      return;
    }

  mpd_sendLoadCommand(mpdConnection, [title cString]);
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
}

- (void) savePlaylist: (NSString *)title
{
  if (! [self _doConnect]) 
    {
      return;
    }

  mpd_sendSaveCommand(mpdConnection, [title cString]);
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
}

- (void) removePlaylist: (NSString *)title
{
  if (! [self _doConnect]) 
    {
      return;
    }
  
  mpd_sendRmCommand(mpdConnection, [title cString]);
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
}


/* -----------------------
   - Collection Commands -
   -----------------------*/

- (NSArray *) getAllArtists
{
  NSMutableArray *allArtists;
  char *artistName;

  if (! [self _doConnect]) 
    {
      return nil;
    }

  mpd_sendListCommand(mpdConnection, MPD_TABLE_ARTIST, NULL);

  if (! [self _checkConnection]) 
    {
      return nil;
    }

  allArtists = [[NSMutableArray alloc] init];

  while ((artistName = mpd_getNextArtist(mpdConnection)) != NULL) 
    {
      [allArtists addObject: [NSString stringWithUTF8String: artistName]];
      free(artistName);
    }

  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
  
  return [AUTORELEASE(allArtists) sortedArrayUsingFunction: _stringSort 
		                                   context: NULL];
}

- (NSArray *) getAllAlbums
{
  NSMutableArray *allAlbums;
  char *albumName;

  if (! [self _doConnect]) 
    {
      return nil;
    }
  
  mpd_sendListCommand(mpdConnection, MPD_TABLE_ALBUM,NULL);

  if (! [self _checkConnection]) 
    {
      return nil;
    }

  allAlbums = [[NSMutableArray alloc] init];

  while ((albumName = mpd_getNextAlbum(mpdConnection)) != NULL) 
    {
      [allAlbums addObject: [NSString stringWithUTF8String: albumName]];
      free(albumName);
    }

  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);

  return [AUTORELEASE(allAlbums) sortedArrayUsingFunction: _stringSort 
		                                  context: NULL];
}

- (NSArray *) getAllTracks
{
  NSMutableArray *allTracks;
  mpd_InfoEntity *mpdInfoEntity;

  if (! [self _doConnect]) 
    {
      return nil;
    }

  mpd_sendListallInfoCommand(mpdConnection, "");

  if (! [self _checkConnection]) 
    {
      return nil;
    }
  
  allTracks = [[NSMutableArray alloc] init];

  while((mpdInfoEntity = mpd_getNextInfoEntity(mpdConnection))) 
    {
      if(mpdInfoEntity->type == MPD_INFO_ENTITY_TYPE_SONG) 
	{
	  mpd_Song *mpdSong;
	  PlaylistItem *tmpSong;

	  mpdSong = mpdInfoEntity->info.song;

	  tmpSong = RETAIN([self _getPlaylistItemForSong: mpdSong]);

	  [allTracks addObject: tmpSong];
	  
	  RELEASE(tmpSong);
	}
      mpd_freeInfoEntity(mpdInfoEntity);
    }
  
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
  
  return AUTORELEASE(allTracks);
}

- (NSArray *) getAlbumsForArtist: (NSString *)artist
{
  NSMutableArray *allAlbums;
  char *albumName;

  if (! [self _doConnect]) 
    {
      return nil;
    }

  mpd_sendListCommand(mpdConnection, MPD_TABLE_ALBUM, [artist UTF8String]);

  if (! [self _checkConnection]) 
    {
      return nil;
    }

  allAlbums = [[NSMutableArray alloc] init];

  while ((albumName = mpd_getNextAlbum(mpdConnection)) != NULL) 
    {
      [allAlbums addObject: [NSString stringWithUTF8String: albumName]];
      free(albumName);
    }
  
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);

  return [AUTORELEASE(allAlbums) sortedArrayUsingFunction: _stringSort 
		                                  context:NULL];
}

- (NSArray *) getAllTracksForArtist: (NSString *)artist
{
  NSMutableArray *allTracks;
  mpd_InfoEntity *mpdInfoEntity;
  
  if (! [self _doConnect]) 
    {
      return nil;
    }

  mpd_sendFindCommand(mpdConnection, MPD_TABLE_ARTIST, [artist UTF8String]);

  if (! [self _checkConnection]) 
    {
      return nil;
    }

  allTracks = [[NSMutableArray alloc] init];

  while((mpdInfoEntity = mpd_getNextInfoEntity(mpdConnection))) 
    {
      if(mpdInfoEntity->type == MPD_INFO_ENTITY_TYPE_SONG) 
	{
	  mpd_Song *mpdSong;
	  PlaylistItem *tmpSong;
	  
	  mpdSong = mpdInfoEntity->info.song;

	  tmpSong = RETAIN([self _getPlaylistItemForSong: mpdSong]);
      
	  [allTracks addObject: tmpSong];

	  RELEASE(tmpSong);
	}
      mpd_freeInfoEntity(mpdInfoEntity);
    }
  
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
  
  return AUTORELEASE(allTracks);
}

- (NSArray *) getAllTracksForArtist: (NSString *)artist 
                              album: (NSString *)album
{
  NSArray *tmpArray;
  NSMutableArray *allTracks;
  int i;

  tmpArray = RETAIN([self getAllTracksForArtist: artist]);

  if (! tmpArray)
    {
      return nil;
    }

  allTracks = [[NSMutableArray alloc] init];

  for (i = 0; i < [tmpArray count]; i++) 
    {
      if ([[[tmpArray objectAtIndex: i] getAlbum] isEqual: album])
	{
	  [allTracks addObject: [tmpArray objectAtIndex: i]];
	}
    }
  
  RELEASE(tmpArray);
  
  return AUTORELEASE(allTracks);
}

- (NSArray *) getAllTracksForAlbum: (NSString *)album
{
  NSMutableArray *allTracks;
  mpd_InfoEntity *mpdInfoEntity;

  if (! [self _doConnect])
    {
      return nil;
    }

  mpd_sendFindCommand(mpdConnection, MPD_TABLE_ALBUM, [album UTF8String]);

  if (! [self _checkConnection]) 
    {
      return nil;
    }

  allTracks = [[NSMutableArray alloc] init];

  while((mpdInfoEntity = mpd_getNextInfoEntity(mpdConnection))) 
    {
      if(mpdInfoEntity->type == MPD_INFO_ENTITY_TYPE_SONG) 
	{
	  mpd_Song *mpdSong;
	  PlaylistItem *tmpSong;
	  
	  mpdSong = mpdInfoEntity->info.song;

	  tmpSong = RETAIN([self _getPlaylistItemForSong: mpdSong]);

	  [allTracks addObject: tmpSong];
	  
	  RELEASE(tmpSong);
	}
      mpd_freeInfoEntity(mpdInfoEntity);
    }
  
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);

  return AUTORELEASE(allTracks);;
}

- (void) updateCollection
{
  if (! [self _doConnect])
    {
      return;
    }

  mpd_sendUpdateCommand(mpdConnection, "");
  mpd_finishCommand(mpdConnection);
  mpd_closeConnection(mpdConnection);
}
@end

/* -------------------
   - Private Methods -
   -------------------*/

@implementation MPDController(Private)
- (BOOL) _doConnect 
{
  char *mpdHost;
  int mpdPort;

  mpdHost = (char *)[host cString];
  mpdPort = (int) [port floatValue];
  
  mpdConnection = mpd_newConnection(mpdHost, mpdPort, 10);
  
  if (password) 
    {
      mpd_sendPasswordCommand(mpdConnection, (char *)[password cString]);
      mpd_finishCommand(mpdConnection);
    }

  if (mpdConnection->error != 0) 
    {
    [[NSNotificationCenter defaultCenter] postNotification: 
	     [NSNotification notificationWithName: DidNotConnectNotification 
					   object: [NSString stringWithUTF8String: 
							       mpdConnection->errorStr]]];

    return NO;
    } 
  else 
    {
      [[NSNotificationCenter defaultCenter] postNotification: 
	     [NSNotification notificationWithName: DidConnectNotification object: nil]];

    return YES;
    }
}

- (BOOL) _checkConnection
{
  if (mpdConnection->error != 0) 
    {
      [[NSNotificationCenter defaultCenter] postNotification: 
	     [NSNotification notificationWithName: DidNotConnectNotification 
			                   object: [NSString stringWithUTF8String: 
							       mpdConnection->errorStr]]];

    mpd_finishCommand(mpdConnection);
    mpd_closeConnection(mpdConnection);

    return NO;
    } 
  else
    {
      return YES;
    }
}

- (PlaylistItem *) _getPlaylistItemForSong: (mpd_Song *)anSong
{
  PlaylistItem *plItem;

  plItem = [[PlaylistItem alloc] init];

  if (anSong->artist == NULL)
    {
      [plItem setArtist: _(@"Unknown Artist")];
    }
  else
    {
      [plItem setArtist: [NSString stringWithUTF8String: anSong->artist]];
    }

  if (anSong->title == NULL) 
    {
      [plItem setTitle: _(@"Unknown Title")];
    }
  else
    {
      [plItem setTitle: [NSString stringWithUTF8String: anSong->title]];
    }
  
  if (anSong->album == NULL)
    {
      [plItem setAlbum: _(@"Unknown Album")];
    }
  else
    {
      [plItem setAlbum: [NSString stringWithUTF8String: anSong->album]];
    }
  
  [plItem setPath: [NSString stringWithUTF8String: anSong->file]];

  if (anSong->track == NULL) 
    {
      [plItem setTrackNr: @""];
    }
  else
    {
      [plItem setTrackNr: [NSString stringWithUTF8String: anSong->track]];
    }

  [plItem setTotalTime: anSong->time];

  [plItem setID: anSong->id];
  [plItem setPos: anSong->pos];
  return AUTORELEASE(plItem);
}

int _stringSort(id string1, id string2, void *context)
{
  NSString *str1, *str2;

  str1 = (NSString *) string1;
  str2 = (NSString *) string2;

  return [str1 caseInsensitiveCompare: str2];
}
@end
