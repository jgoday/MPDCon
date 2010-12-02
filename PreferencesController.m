/* 
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-12 17:59:14 +0200 by flip
   
   Preferences Controller

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
#include "PreferencesController.h"

@implementation PreferencesController

/* --------------------------
   - Initialization Methods -
   --------------------------*/

+ (id) sharedPreferencesController
{
  static PreferencesController *_sharedPrefsController = nil;

  if (! _sharedPrefsController) 
    {
      _sharedPrefsController = [[PreferencesController 
				  allocWithZone: [self zone]] init];
    }
  
  return _sharedPrefsController;
}

- (id) init
{
  self = [self initWithWindowNibName: @"Preferences"];
  
  if (self)
    {
      [self setWindowFrameAutosaveName: @"Preferences"];
      defaults = [NSUserDefaults standardUserDefaults];
    }

  return self;
}

/* ---------------
   - Gui Methods -
   ---------------*/

- (void) awakeFromNib
{
  [self revert: nil];
}

- (void) apply: (id)sender
{
  NSNotification *aNotif;

  if ([mpdHost stringValue] != nil)
    {
      [defaults setObject: [mpdHost stringValue] forKey: @"mpdHost"];
    }

  if ([mpdPort stringValue] != nil)
    {
      [defaults setObject: [mpdPort stringValue] forKey: @"mpdPort"];
    }

  if (([password stringValue] != nil) && ([usePassword state] != 0))
    {
      [defaults setObject: [password stringValue] forKey: @"mpdPassword"];
    }
  else
    {
      [defaults removeObjectForKey: @"mpdPassword"];
    }

  [defaults setInteger: [usePassword state] forKey: @"usePassword"];

  [defaults setInteger: [scrollSwitch state] forKey: @"enableScroll"];
  
  [defaults setObject: [NSArchiver archivedDataWithRootObject: [colorWell color]] forKey: @"displayColor"];
  
  [defaults synchronize];

  [[self window] close];

  aNotif = [NSNotification notificationWithName: 
			     PreferencesChangedNotification
			                 object: nil];

  [[NSNotificationCenter defaultCenter] postNotification: aNotif];
  
  
}


- (void) revert: (id)sender
{
  NSData *colorData;
  
  [mpdHost setStringValue: [defaults objectForKey: @"mpdHost"]];

  [mpdPort setStringValue: [defaults objectForKey: @"mpdPort"]];

  [password setStringValue: [defaults objectForKey: @"mpdPassword"]];

  [scrollSwitch setState: [defaults integerForKey: @"enableScroll"]];

  [usePassword setState: [defaults integerForKey: @"usePassword"]];
  
  colorData = [defaults dataForKey: @"displayColor"];
  
  if (colorData != nil)
    {
      [colorWell setColor: [NSUnarchiver unarchiveObjectWithData: colorData]];
    }
  
  [self usePasswordChanged: sender];
}

- (void) usePasswordChanged: (id)sender
{
  if ([usePassword state] != 0) 
    {
      [password setEditable: YES];
      [password setEnabled: YES];
      [password setBackgroundColor: [NSColor whiteColor]];
      [password setSelectable: YES];
    } 
  else 
    {
      [password setEditable: NO];
      [password setEnabled: NO];
      [password setBackgroundColor: [NSColor lightGrayColor]];
      [password setSelectable: NO];
    }
}
@end


