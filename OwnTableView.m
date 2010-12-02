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

#include <AppKit/AppKit.h>
#include "OwnTableView.h"

@implementation OwnTableView

/* --------------------
   - Delegate Methods -
   --------------------*/

 - (NSImage*) dragImageForRows: (NSArray*)dragRows 
			 event: (NSEvent*)dragEvent 
	       dragImageOffset: (NSPoint*)dragImageOffset
{
  return [NSImage imageNamed: @"MoveSong"];
}

- (void) selectAll: (id) sender
{
  [super selectAll: sender];
  [self setNeedsDisplay: YES];
}

- (void) keyDown: (NSEvent *) theEvent
{
  NSString *characters = [theEvent characters];
  unichar character = 0;
  
  if ([characters length] > 0)
    {
      character = [characters characterAtIndex: 0];
    }
    
  switch (character)
    {
      case NSUpArrowFunctionKey:
        {
          int row = [self selectedRow];
        
          if (row > 0)
            {
              [self selectRow: row-1 byExtendingSelection: NO];
              [self scrollRowToVisible: row-1];
            }
          break;
        }
      case NSDownArrowFunctionKey:
        {
          int row = [self selectedRow];
          int maxRow = [self numberOfRows];
        
          if (row < maxRow-1)
            {
              [self selectRow: row+1 byExtendingSelection: NO];
              [self scrollRowToVisible: row+1];
            }
          break;
        }
      case NSHomeFunctionKey:
        {
          if ([self numberOfRows] > 0)
            {
              [self selectRow: 0 byExtendingSelection: NO];
              [self scrollRowToVisible: 0];
            }
          break;
        }
      case NSEndFunctionKey:
        {
          int rows = [self numberOfRows];
          
          if (rows > 0)
            {
              [self selectRow: rows-1 byExtendingSelection: NO];
              [self scrollRowToVisible: rows-1];
            }
          break;
        }
      case '\r':
        {
          [[self target] performSelector: [self doubleAction]];
          break;
        }
      default:
        [super keyDown: theEvent];
        break;
    }
}
@end
