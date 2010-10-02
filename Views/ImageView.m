/*
 Copyright (c) 2010, Olivier Labs. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS' AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER AND CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ImageView.h"
#import <Quartz/Quartz.h>

@implementation ImageView

@synthesize pasteboardDelegate;

// Accept mouse events without the window being key. Useful for dragging
- (BOOL)acceptsFirstMouse:(NSEvent *)event {
	return YES;
}

- (void)mouseDown:(NSEvent *)event {
	NSEventType type;
	
	// We don't care about mouse events if no image is being shown
	if (! [self image]) return [super mouseDown:event];
	
    while (true) {
        event = [[self window] nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask];
	
		type = [event type];

		if (type == NSLeftMouseUp) break;
		
		if (type == NSLeftMouseDragged) {
			[self mouseDragged:event];
			break;
		}
    }
}

- (void)mouseDragged:(NSEvent *)event {
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	NSPoint imageLocation;
	NSSize imageSize = [[self image] size];
	NSRect viewBounds = [self bounds];
	
	if (imageSize.width > viewBounds.size.width) imageSize.width = viewBounds.size.width;
	if (imageSize.height > viewBounds.size.height) imageSize.height = viewBounds.size.height;
	
	if ([[self cell] hitTestForEvent:event inRect:viewBounds ofView:self] == NSCellHitContentArea) {
		// Bottom left corner
		imageLocation.x = (viewBounds.size.width - imageSize.width) / 2;
		imageLocation.y = (viewBounds.size.height - imageSize.height) / 2;
	}
	else {
		// User clicked outside of the image, so we centre the image on the drag pointer
		imageLocation = [self convertPoint:[event locationInWindow] fromView:nil];
		imageLocation.x -= imageSize.width / 2;
		imageLocation.y -= imageSize.height / 2;
	}

	[pasteboardDelegate writeToPasteboard:pasteboard];
	
	// Start dragging
	[self dragImage:[self image]
				 at:imageLocation
			 offset:NSZeroSize
			  event:event
		 pasteboard:pasteboard
			 source:self
		  slideBack:YES];
}

@end
