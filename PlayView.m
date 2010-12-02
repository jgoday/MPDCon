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

#include <AppKit/AppKit.h>
#include "PlayView.h"


/* ---------------------
   - Private Interface -
   ---------------------*/

@interface PlayView(Private)
- (NSString *) _getTime;

- (void) _drawTrack;
- (void) _drawArtist;
- (void) _drawAlbum;
- (void) _drawTitle;
- (void) _drawTime;
@end

@implementation PlayView

/* --------------------------
   - Initialization Methods -
   --------------------------*/

+ (id) init
{
  self = [super init];
  

  return self;
}

- (void) dealloc
{
  RELEASE(dispSong);

  [super dealloc];
}

/* -------------------
   - Display Methods -
   -------------------*/


- (void) drawRect: (NSRect)rect
{
  NSRect myBounds;
  NSData *colorData;
  NSColor *displayColor;
  
  if (! notificationAdded) 
    {
      notificationAdded = YES;
      [[NSNotificationCenter defaultCenter] 
	addObserver: self
	   selector: @selector(songChanged:)
	       name: SongChangedNotification
             object: nil];
      
            [[NSNotificationCenter defaultCenter] 
	addObserver: self
	   selector: @selector(songChanged:)
	       name: PreferencesChangedNotification
             object: nil];
    }
  
  colorData = [[NSUserDefaults standardUserDefaults] dataForKey: @"displayColor"];
  
  if (! colorData)
    {
      displayColor = [NSColor grayColor];
    }
  else
    {
      displayColor = [NSUnarchiver unarchiveObjectWithData: colorData];
    }
    
  [displayColor set];
  

  myBounds = [self bounds];
  [NSBezierPath fillRect: myBounds];
  [[NSColor blackColor] set];
  
  NSRect strokeRect = NSMakeRect(myBounds.origin.x, myBounds.origin.y+1, myBounds.size.width-1, myBounds.size.height-1);
  [NSBezierPath strokeRect: strokeRect];

  if (displayEnabled) 
    {
      [self _drawTrack];
      [self _drawArtist];
      [self _drawAlbum];
      [self _drawTitle];
      [self _drawTime];
    } 
  else 
    {
      NSImage *gnustepImage;
      int bWidth, bHeight, iWidth, iHeight;
      
      bWidth = myBounds.size.width;
      bHeight = myBounds.size.height;
      
      gnustepImage = [NSImage imageNamed: @"GNUstep.tiff"];
      
      iWidth = [gnustepImage size].width;
      iHeight = [gnustepImage size].height;

      [gnustepImage compositeToPoint: NSMakePoint((bWidth/2.0) - (iWidth/2.0), (bHeight/2.0) - (iHeight/2.0)) 
		            fromRect: myBounds 
		           operation: NSCompositeSourceOver];
  }
}

- (void) setDisplaySong: (PlaylistItem *)newSong
{
  RELEASE(dispSong);

  dispSong = RETAIN(newSong);
  [self setNeedsDisplay: YES];
}

- (void) setCurrentSong: (int)newSong
{
  currentSong = newSong;
}

- (void) setTotalSongs: (int)newSong
{
  totalSongs = newSong;
}

- (void) setElapsedTime: (int)newTime
{
  if (dispSong)
    {
      [dispSong setElapsedTime: newTime];
    }
  
  [self setNeedsDisplay: YES];
}

- (void) setReversedTime: (BOOL)reversed
{
  reversedTime = reversed;
}

- (void) enableDisplay: (BOOL)enabled
{
  displayEnabled = enabled;
  [self setNeedsDisplay: YES];
}

/* ------------------------
   - Notification Methods -
   ------------------------*/

- (void) songChanged: (NSNotification *)aNotif
{
  artistScroll = 0;
  titleScroll = 0;
  albumScroll = 0;
  artistScrollForward = YES;
  titleScrollForward = YES;
  albumScrollForward = YES;
  
  [self setNeedsDisplay: YES];
}

/* --------------------
   - Delegate Methods -
   --------------------*/

- (void) mouseUp: (NSEvent *)anEvent
{
  if (reversedTime) 
    {
      reversedTime = NO;
    }
  else 
    {
      reversedTime = YES;
    }

  [[NSUserDefaults standardUserDefaults] setBool: reversedTime 
					  forKey: @"reversedTime"];
}

@end
/* -------------------
   - Private Methods -
   -------------------*/

@implementation PlayView(Private)
- (NSString *) _getTime
{
  int totalTime, elapsedTime;

  int tSecs, eSecs;
  int tMin, eMin;


  totalTime = [dispSong getTotalTime];
  elapsedTime = [dispSong getElapsedTime];
  tSecs = (totalTime % 60);
  tMin = (int)totalTime/60;
  
  eSecs = 0;
  eMin = 0;

  if (! reversedTime) 
    {
      eSecs = (elapsedTime % 60);
      eMin = (int)elapsedTime/60;
      return [NSString stringWithFormat: @"%d:%02d/%d:%02d"
		       , eMin, eSecs, tMin, tSecs];
    } 
  else 
    {
      eSecs = ((totalTime - elapsedTime) % 60);
      eMin = (int) (totalTime - elapsedTime) / 60;
      return [NSString stringWithFormat: @"- %d:%02d/%d:%02d"
		       , eMin, eSecs, tMin, tSecs];
    }
}

- (void) _drawTrack
{
  [[NSString stringWithFormat: _(@"Playing Track %d of %d")
	     , currentSong, totalSongs] 
    drawAtPoint: NSMakePoint(5, 60) withAttributes: nil];
}

- (void) _drawArtist
{
  NSString *theArtist;
  NSRect myBounds;

  NSMutableDictionary *attributes;
  NSFont *theFont;

  int enableScroll;


  theArtist = [dispSong getArtist];
  myBounds = [self bounds];
  
  attributes = [NSMutableDictionary dictionary];
  
  enableScroll =  [[NSUserDefaults standardUserDefaults] 
		    integerForKey: @"enableScroll"];
  
  theFont = [NSFont boldSystemFontOfSize: 18];
  [attributes setObject: theFont forKey: NSFontAttributeName];
  
  if (([theArtist sizeWithAttributes: attributes].width 
       > myBounds.size.width-10) && enableScroll) 
    {
      if ([theArtist sizeWithAttributes: attributes].width-artistScroll 
	  < myBounds.size.width - 20) 
	{
	  artistScrollForward=NO;
	}
      
      if (artistScroll == 0) 
	{
	  artistScrollForward=YES;
	}
      
      if (artistScrollForward)
	{
	  artistScroll+=5;
	}
      else
	{
	  artistScroll-=5;
	}
    }
  
  [theArtist drawAtPoint: NSMakePoint(10-artistScroll, 37) 
	  withAttributes: attributes];
}

- (void) _drawAlbum
{
  NSString *theAlbum;
  NSRect myBounds;

  NSMutableDictionary *attributes;
  NSFont *theFont;

  int enableScroll;


  myBounds = [self bounds];
  
  attributes = [NSMutableDictionary dictionary];
  
  enableScroll =  [[NSUserDefaults standardUserDefaults] 
		    integerForKey: @"enableScroll"];
  
  theAlbum = [dispSong getAlbum];
  
  theFont = [NSFont systemFontOfSize: 11];

  [attributes setObject: theFont forKey: NSFontAttributeName];
  
  if (([theAlbum sizeWithAttributes: attributes].width 
       > myBounds.size.width-3) && enableScroll) 
    {
      if ([theAlbum sizeWithAttributes: attributes].width-albumScroll 
	  < myBounds.size.width - 10) 
	{
	  albumScrollForward=NO;
	}
      
      if (albumScroll == 0) 
	{
	  albumScrollForward=YES;
	}
    
      if (albumScrollForward)
	{
	  albumScroll+=5;
	}
      else
	{
	  albumScroll-=5;
	}
    }
  
  [theAlbum drawAtPoint: NSMakePoint(5-albumScroll, 2) 
	 withAttributes: attributes];
}

- (void) _drawTitle
{
  NSString *theTitle;
  NSString *theTrack;
  NSRect myBounds;

  NSMutableDictionary *attributes;
  NSFont *theFont;

  int enableScroll;


  myBounds = [self bounds];
  
  attributes = [NSMutableDictionary dictionary];
  
  enableScroll =  [[NSUserDefaults standardUserDefaults] integerForKey: @"enableScroll"];
  
  theTrack = [dispSong getTrackNr];
  
  if ([theTrack compare: @""] != NSOrderedSame) 
    {
      theTitle = [theTrack stringByAppendingString: 
        			 [@" - " stringByAppendingString: 
	        		     [dispSong getTitle]]];
    }
  else
    {
      theTitle = [dispSong getTitle];
    }
  
  
  theFont = [NSFont boldSystemFontOfSize: 13];
  
  [attributes setObject: theFont forKey: NSFontAttributeName];
  
  if (([theTitle sizeWithAttributes: attributes].width 
       > myBounds.size.width-10) && enableScroll) 
    {
      if ([theTitle sizeWithAttributes: attributes].width-titleScroll 
	  < myBounds.size.width - 10) 
	{
	  titleScrollForward=NO;
	}
    
      if (titleScroll == 0) 
	{
	  titleScrollForward=YES;
	}
    
      if (titleScrollForward)
	{
	  titleScroll+=5;
	}
      else
	{
	  titleScroll-=5;
	}
    }
  
  [theTitle drawAtPoint: NSMakePoint(10-titleScroll, 22) 
         withAttributes: attributes];
}

- (void) _drawTime
{
  NSRect myBounds;

  NSMutableDictionary *attributes;
  NSFont *theFont;

  
  myBounds = [self bounds];
  
  attributes = [NSMutableDictionary dictionary];
  
  theFont = [NSFont boldSystemFontOfSize: 12];

  [attributes setObject: theFont forKey: NSFontAttributeName];
  
  NSString *timeString = [self _getTime];
  NSSize timeSize = [timeString sizeWithAttributes: attributes];
  [timeString drawAtPoint: NSMakePoint(myBounds.size.width-timeSize.width-2
				       , 60) 
	   withAttributes: attributes];
}

/*NSColor *colorFromDict(NSDictionary *dict)
{
  if(dict != nil)
    {
      return [NSColor colorWithCalibratedRed: [[dict objectForKey: @"red"] floatValue]
                      green: [[dict objectForKey: @"green"] floatValue]
                      blue: [[dict objectForKey: @"blue"] floatValue]
                      alpha: [[dict objectForKey: @"alpha"] floatValue]];
    }
  return nil;
}*/
@end
