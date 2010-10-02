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

#import "AppDelegate.h"
#import "PreferencesWC.h"
#import "AboutPanelWC.h"
#import "OptionsPanelWC.h"
#import "Preferences.h"

@implementation AppDelegate

#pragma mark IB Actions

+ (void)initialize {
	[Preferences registerDefaultPreferences];
}

- (IBAction)showPreferencesPanel:(id)sender {
	if (! preferencesController) preferencesController = [[PreferencesWC alloc] init];	
	[preferencesController showWindow:self];
}

- (IBAction)orderFrontStandardAboutPanel:(id)sender {
	if (! aboutController) aboutController = [[AboutPanelWC alloc] init];
	[aboutController showWindow:self];
}

- (IBAction)showOrHideOptionsPanel:(id)sender {
	if (! optionsController) {
		optionsController = [[OptionsPanelWC alloc] init];
		[optionsController setShouldCascadeWindows:NO];
		[optionsController showWindow:self];
	}
	else {
		NSWindow *window = [optionsController window];
		if ([window isVisible]) [window orderOut:self];
		else [optionsController showWindow:self];
	}
}

- (IBAction)openDonateURL:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://olivierlabs.com/latte/index.html#donate"]];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	SEL action = [menuItem action];
	
	if (action == @selector(showOrHideOptionsPanel:)) {
		[menuItem setTitle:([[optionsController window] isVisible]) ?
		 NSLocalizedString(@"Hide Options", @"") :
		 NSLocalizedString(@"Show Options", @"")];
	}
	
	return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
