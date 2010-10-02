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

#import "NSMenu+AddItemWithColour.h"

NSImage *smallSquareWithColour(NSColor *colour);

@implementation NSMenu (NSMenuAddItemWithColour)

- (NSMenuItem *) addItemWithTitle:(NSString *)title colour:(NSColor *)colour {
	NSMenuItem *item = [self addItemWithTitle:title action:NULL keyEquivalent:@""];
	[item setImage:smallSquareWithColour(colour)];
	return item;
}

NSImage *smallSquareWithColour(NSColor *colour) {
	const CGFloat width = 15;
	const CGFloat height = 10;
	const NSRect rect = NSMakeRect(0, 0, width, height);
	NSBitmapImageRep* rep = nil;
	
	rep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
												   pixelsWide:width
												   pixelsHigh:height
												bitsPerSample:8
											  samplesPerPixel:4
													 hasAlpha:YES
													 isPlanar:NO
											   colorSpaceName:NSCalibratedRGBColorSpace
												 bitmapFormat:0
												  bytesPerRow:(4 * width)
												 bitsPerPixel:32]
		   autorelease];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext
										  graphicsContextWithBitmapImageRep:rep]];
	
	[colour set];
	NSRectFill(rect);
	
	[NSGraphicsContext restoreGraphicsState];
	
	NSImage *image = [[[NSImage alloc] init] autorelease];
	[image addRepresentation:rep];
	
	return image;
}


@end
