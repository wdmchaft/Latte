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

#import "NSColor+HexadecimalValue.h"

// Adapted from Q&A QA1576: 'How do I get the hexadecimal value of an NSColor object?'
// http://developer.apple.com/mac/library/qa/qa2007/qa1576.html

@implementation NSColor(NSColorHexadecimalValue)

- (NSString *)hexadecimalValueOfAnNSColor {
	CGFloat redFloatValue, greenFloatValue, blueFloatValue;
	NSInteger redIntValue, greenIntValue, blueIntValue;
	const CGFloat maxComponentValue = 255.99999f;
		
	//Convert the NSColor to the RGB colour space before we can access its components
	NSColor *convertedColour = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

	if (! convertedColour) return nil;
	
	// Get the red, green, and blue components of the colour
	[convertedColour getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];
		
	// Convert the components to numbers (unsigned decimal integer) between 0 and 255
	redIntValue = redFloatValue * maxComponentValue;
	greenIntValue = greenFloatValue * maxComponentValue;
	blueIntValue = blueFloatValue * maxComponentValue;
		
	// Concatenate the red, green, and blue components' hex strings
	return [NSString stringWithFormat:@"%02x%02x%02x", redIntValue, greenIntValue, blueIntValue];
}

@end
