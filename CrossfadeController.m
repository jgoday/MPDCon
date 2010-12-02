/* 
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-12 17:59:14 +0200 by flip
   
   Crossfade Controller

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
#include "CrossfadeController.h"

/* ---------------------
   - Private Interface -
   ---------------------*/
@interface CrossfadeController(Private)
- (void) _getValues;
@end

@implementation CrossfadeController

/* --------------------------
   - Initialization Methods -
   --------------------------*/

+ (id) sharedCrossfadeController
{
  static CrossfadeController *_sharedCrossfadeController = nil;

  if (! _sharedCrossfadeController) 
    {
      _sharedCrossfadeController = [[CrossfadeController allocWithZone: [self zone]] init];
    }
  
  return _sharedCrossfadeController;
}

- (id) init
{
  self = [self initWithWindowNibName: @"CrossfadeView"];
  
  if (self)
    {
      [self setWindowFrameAutosaveName: @"CrossfadeView"];
    }

  return self;
}

/* ---------------
   - Gui Methods -
   ---------------*/

- (void) awakeFromNib
{
  [self _getValues];

}
  
- (void) valueChanged: (id)sender
{
  [valueField setIntValue: [valueStepper intValue]];

}


- (void) apply: (id)sender
{
  [[MPDController sharedMPDController] setCrossfade: [valueStepper intValue]];
  [[self window] performClose: self];
}

- (void) revert: (id)sender
{
  [self _getValues];
}
@end

/* -------------------
   - Private Methods -
   -------------------*/
@implementation CrossfadeController(Private)
- (void) _getValues
{
  [valueStepper setIntValue: [[MPDController sharedMPDController] 
			       getCrossfade]];

  [self valueChanged: self];
}

@end
