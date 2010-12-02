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

#ifndef _PCAPPPROJ_PREFERENCESCONTROLLER_H
#define _PCAPPPROJ_PREFERENCESCONTROLLER_H

#include <AppKit/AppKit.h>
#include "Strings.h"

@interface PreferencesController : NSWindowController
{
  IBOutlet NSTextField *mpdHost;
  IBOutlet NSTextField *mpdPort;
  IBOutlet NSSecureTextField *password;
  IBOutlet NSButton *scrollSwitch;
  IBOutlet NSButton *usePassword;
  IBOutlet NSColorWell *colorWell;

  NSUserDefaults *defaults;
}

// Initialization Methods
+ (id) sharedPreferencesController;

// Gui Methods
- (void) apply: (id)sender;
- (void) revert: (id)sender;
- (void) usePasswordChanged: (id)sender;

@end

#endif
