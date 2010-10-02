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

#import <Cocoa/Cocoa.h>
#import "ImageView.h"
#import "TextView.h"
#import "TextViewDelegate.h"
#import "PasteboardDelegate.h"

typedef enum {
	currentlyShowingNone,
	currentlyShowingPDF,
	currentlyShowingImage
} CurrentlyShowing;

@interface DocumentWC : NSWindowController
<NSWindowDelegate, NSUserInterfaceValidations, TextViewDelegate, PasteboardDelegate> {
	IBOutlet ImageView *imageView;
	IBOutlet TextView *inputView;
	IBOutlet NSTextField *statusField;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSToolbarItem *renderToolbarItem;
	
	NSMutableData *connectionData;
	CurrentlyShowing currentlyShowing;
	NSURLConnection *httpConnection;
}

@property (assign) ImageView *imageView;
@property (assign) TextView *inputView;
@property (assign) NSTextField *statusField;
@property (assign) NSProgressIndicator *progressIndicator;
@property (assign) NSToolbarItem *renderToolbarItem;

- (IBAction)render:(id)sender;

- (NSURL *)makeURL;


@end
