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

#ifndef _PCAPPPROJ_STATISTICSITEM_H_
#define _PCAPPPROJ_STATISTICSITEM_H_

#include <Foundation/Foundation.h>

@interface StatisticsItem : NSObject
{
  int numberOfSongs;
  int numberOfArtists;
  int numberOfAlbums;

  int uptime;
  int playtime;

  int dbUpdatetime;
  int dbPlaytime;
}

// Accessor Methods
- (int) getNumberOfSongs;
- (void) setNumberOfSongs: (int)newSongs;
- (int) getNumberOfArtists;
- (void) setNumberOfArtists: (int)newArtists;
- (int) getNumberOfAlbums;
- (void) setNumberOfAlbums: (int)newAlbums;
- (int) getUptime;
- (void) setUptime: (int)newUptime;
- (int) getPlaytime;
- (void) setPlaytime: (int)newPlaytime;
- (int) getDbUpdatetime;
- (void) setDbUpdatetime: (int)newDbUpdatetime;
- (int) getDbPlaytime;
- (void) setDbPlaytime: (int)newDbPlaytime;
@end

#endif

