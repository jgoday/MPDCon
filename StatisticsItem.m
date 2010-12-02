/*
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-17 23:17:38 +0200 by flip

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

#include "StatisticsItem.h"

@implementation StatisticsItem

/* --------------------
   - Accessor Methods -
   --------------------*/

- (int) getNumberOfSongs
{
  return numberOfSongs;
}

- (void) setNumberOfSongs: (int)newSongs
{
  numberOfSongs = newSongs;
}

- (int) getNumberOfArtists
{
  return numberOfArtists;
}

- (void) setNumberOfArtists: (int)newArtists;
{
  numberOfArtists = newArtists;
}

- (int) getNumberOfAlbums
{
  return numberOfAlbums;
}

- (void) setNumberOfAlbums: (int)newAlbums
{
  numberOfAlbums = newAlbums;
}

- (int) getUptime
{
  return uptime;
}

- (void) setUptime: (int)newUptime
{
  uptime = newUptime;
}

- (int) getPlaytime
{
  return playtime;
}

- (void) setPlaytime: (int)newPlaytime
{
  playtime = newPlaytime;
}

- (int) getDbUpdatetime
{
  return dbUpdatetime;
}

- (void) setDbUpdatetime: (int)newDbUpdatetime
{
  dbUpdatetime = newDbUpdatetime;
}

- (int) getDbPlaytime
{
  return dbPlaytime;
}

- (void) setDbPlaytime: (int)newDbPlaytime
{
  dbPlaytime = newDbPlaytime;
}

@end
