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

#import "TextView.h"
#import "TextViewDelegate.h"

@implementation TextView

@dynamic delegate;

- (BOOL)hasEmptySelection {
	// A selection is empty iff -selectedRanges: returns an array containing exactly one
	// range whose length is 0
	NSArray *ranges = [self selectedRanges];
	if ([ranges count] == 1) {
		NSRange range = [[ranges objectAtIndex:0] rangeValue];
		if (range.length == 0) return YES;
	}
	
	return NO;
}

- (IBAction)copy:(id)sender {
	if ([self hasEmptySelection]) {
		[[self delegate] copyEmptySelection:self];
		return;
	}
	
	[super copy:sender];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(copy:) && [self hasEmptySelection]) {
		return [[self delegate] validateCopyEmptySelection:self];
	}
			 
	return [super validateMenuItem:menuItem];
}

// If LaTeX source has been dragged to the text view, automatically render it
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
	[[self delegate] render:self];
}

// Disable completion
- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
	return nil;
}

@end
