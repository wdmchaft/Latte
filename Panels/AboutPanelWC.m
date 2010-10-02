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

#import "AboutPanelWC.h"

@implementation AboutPanelWC

@synthesize iconField;
@synthesize appNameField;
@synthesize appVersionField;
@synthesize creditsField;

- (id)init {
	self = [super initWithWindowNibName:@"AboutPanel"];
	return self;
}

- (id)objectForKey:(NSString *)key {
	id result = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
	if (! result) result = [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
	return result;
}

- (void)awakeFromNib {
	// Show icon
	NSImage *iconImage = nil;
    NSString *iconFileStr = [self objectForKey:@"CFBundleIconFile"];
    if (iconFileStr && [iconFileStr length] > 0) iconImage = [NSImage imageNamed:iconFileStr];
    else iconImage = [NSImage imageNamed:@"NSApplicationIcon"];
    [iconField setImage:iconImage];
	
	// Show application name
	NSString *appName = [self objectForKey:@"CFBundleName"];
	
	NSFont *font = [appNameField font];
	font = [[NSFontManager sharedFontManager] convertFont:font toSize:16.0];
	font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSBoldFontMask];
	
	NSMutableParagraphStyle *pstyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[pstyle setAlignment:NSCenterTextAlignment];
	
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,
						   pstyle, NSParagraphStyleAttributeName,
						   nil];
	NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:appName
																	  attributes:attrs]
									  autorelease];
	
	[appNameField setAttributedStringValue:attrString];
	
	// Show application version
	NSString *appVersion = [self objectForKey:@"CFBundleVersion"];
	if (! appVersion) appVersion = @"0.0";
	appVersion = [NSString stringWithFormat:@"%@ %@",
				  NSLocalizedString(@"Version", @""),
				  appVersion];
	[appVersionField setStringValue:appVersion];
	
	// Show credits
	NSString *creditsFilePath = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"];
	if (creditsFilePath) {
		NSAttributedString *credits = [[[NSAttributedString alloc] initWithPath:creditsFilePath
															 documentAttributes:NULL]
									   autorelease];
		if (credits) [[creditsField textStorage] setAttributedString:credits];
	}
}

@end
