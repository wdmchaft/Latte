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

#import <Quartz/Quartz.h>

#import "DocumentWC.h"
#import "Document.h"
#import "Error.h"
#import "OptionsConstants.h"
#import "NSColor+HexadecimalValue.h"

#define kPDFScalingFactor 2

@implementation DocumentWC

@synthesize imageView;
@synthesize inputView;
@synthesize statusField;
@synthesize progressIndicator;
@synthesize renderToolbarItem;

- (id)init {
	self = [super initWithWindowNibName:@"Document"];
	if (self) {
		connectionData = [NSMutableData new];
		currentlyShowing = currentlyShowingNone;
	}
	return self;
}

- (void)cancelHttpConnection {
	if (httpConnection) {
		[httpConnection cancel];
		[httpConnection release];
		httpConnection = nil;
	}
	
	[progressIndicator stopAnimation:self];
}

- (void)showImage {
	Document *doc = [self document];
	if (! doc.outputData || doc.outputType == outputTypeUndefined) return;

	NSImage *image;
	
	if (doc.outputType == outputTypePDF) {
		currentlyShowing = currentlyShowingPDF;
		
		NSPDFImageRep *rep = [[[NSPDFImageRep alloc] initWithData:doc.outputData] autorelease];
		image = [[[NSImage alloc] init] autorelease];
		
		// Check if we have room to scale the PDF by kPDFScalingFactor
		NSSize scaledSize = [rep size];
		scaledSize.width *= kPDFScalingFactor;
		scaledSize.height *= kPDFScalingFactor;
		
		if (scaledSize.width < [imageView bounds].size.width &&
			scaledSize.height < [imageView bounds].size.height)
		{
			[image setSize:scaledSize];
		}
		
		[image addRepresentation:rep];
	}
	else {
		currentlyShowing = currentlyShowingImage;
		image = [[[NSImage alloc] initWithData:doc.outputData] autorelease];
	}	

	[imageView setImage:image];
}

- (void)windowDidLoad {
	[super windowDidLoad];

	Document *doc = [self document];

	// Image
	[self showImage];
	imageView.pasteboardDelegate = self;
	
	// LaTeX input
	[inputView setFont:[NSFont fontWithName:@"Monaco" size:[NSFont systemFontSize] - 2]];
	[inputView setString:doc.latexInput];
	[[self window] makeFirstResponder:inputView];

	// Bottom bar status text
	[statusField setStringValue:@""];	
}

- (void)dealloc {
	[self cancelHttpConnection];
	if (connectionData) [connectionData release];
	[super dealloc];
}

#pragma mark -
#pragma mark IB Actions

- (IBAction)render:(id)sender {
	[renderToolbarItem setEnabled:NO];
	// This shouldn’t happen since the Render button is conditionally enabled
	if ([[inputView string] length] <= 0) return;
	
	NSURL *url = [self makeURL];
	if (!url) return;
	
	[progressIndicator startAnimation:self];
	[statusField setStringValue:NSLocalizedString(@"Obtaining formula…", @"")];
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	httpConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
}

#pragma mark -
#pragma mark URL connection methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		NSString *contentType = [[httpResponse allHeaderFields] objectForKey:@"Content-Type"];
		
		if (! [[NSSet setWithObjects:@"application/octet-stream", @"image/png", @"image/gif", nil]
			   containsObject:contentType])
		{
			[statusField setStringValue:[NSString stringWithFormat:@"%@ %@.",
										 [statusField stringValue],
										 NSLocalizedString(@"error", @"")]];
			[self cancelHttpConnection];
			
			NSError *error = [Error invalidContentTypeFor:[self makeURL] response:httpResponse];
			NSAlert *alert = [NSAlert alertWithError:error];
			[alert beginSheetModalForWindow:[self window]
							  modalDelegate:self
							 didEndSelector:@selector(dismissAlert:returnCode:contextInfo:)
								contextInfo:NULL];
		}
	}
    
	[connectionData setLength:0];
}

- (void) dismissAlert:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [connectionData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[statusField setStringValue:[NSString stringWithFormat:@"%@ %@.",
								 [statusField stringValue],
								 NSLocalizedString(@"error", @"")]];
	[self cancelHttpConnection];
	
	NSAlert *alert = [NSAlert alertWithError:error];
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:@selector(dismissAlert:returnCode:contextInfo:)
						contextInfo:NULL];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	BOOL isPDF = NO;
	NSInteger outputType = 0;
	Document *doc = [self document];
	
	if (doc.webEngine == kWebEngineCodeCogs) {
		outputType = doc.codeCogsOutputType;
		isPDF = (outputType == kCodeCogsOutputTypePDF);
	}

	if (isPDF) {
		PDFDocument *pdfDoc = [[[PDFDocument alloc] initWithData:connectionData] autorelease];
		if (pdfDoc) {
			doc.outputData = connectionData;
			doc.outputType = outputTypePDF;
			[self showImage];
		}
	}
	else {
		NSImage *image = [[[NSImage alloc] initWithData:connectionData] autorelease];
		if (image) {
			doc.outputData = connectionData;
			doc.outputType = outputTypePNG;
			if (doc.webEngine == kWebEngineCodeCogs && outputType == kCodeCogsOutputTypeGIF) {
				doc.outputType = outputTypeGIF;
			}
			[self showImage];
		}
	}

	[self cancelHttpConnection];
	[statusField setStringValue:[NSString stringWithFormat:@"%@ %@.",
								 [statusField stringValue],
								 NSLocalizedString(@"done", @"")]];
}

- (NSURL *)makeURL {
	Document *doc = [self document];
	NSURL *url = nil;
	NSString *input = nil;
	NSString *host = nil;
	NSString *scheme = @"http";
	NSString *path = nil;
	WebEngine engine = doc.webEngine;

	NSString *preinput = [inputView string];
	
	// Apply changes to LaTeX source if needed
	if (engine == kWebEngineCodeCogs) {
		NSInteger textColour = doc.codeCogsTextColour;
	
		// Enclose the input within {\color{COLOUR}} if it’s not the automatic colour
		if (textColour != kCodeCogsTextColourAutomatic) {
			char *colourCodes[] = { "red", "green", "blue" };
			preinput = [NSString stringWithFormat:@"{\\color{%s}%@}",
						colourCodes[textColour - 1], preinput];
		}

//		preinput = [NSString stringWithFormat:@"\\Large %@", preinput];
	}
	
	/*
	 theInput = [theInput stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	 stringByAddingPercentEscapesUsingEncoding won’t encode a few characters, e.g. '+'
	 We resort to http://simonwoodside.com/weblog/2009/4/22/how_to_really_url_encode/
	 */
	input = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																(CFStringRef)preinput,
																NULL,
																(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
																kCFStringEncodingUTF8);
	
	if (engine == kWebEngineCodeCogs) {
		NSInteger outputType = doc.codeCogsOutputType;

		host = @"latex.codecogs.com";
		
		switch (outputType) {
			case kCodeCogsOutputTypePDF:
				path = [NSString stringWithFormat:@"/pdf.download?%@", input];
				break;
				
			case kCodeCogsOutputTypePNG:
				path = [NSString stringWithFormat:@"/png.latex?%@", input];
				break;
				
			case kCodeCogsOutputTypeGIF:
				path = [NSString stringWithFormat:@"/gif.latex?%@", input];
				break;
		}
	}
	else if (engine == kWebEngineGoogleChart) {
		host = @"chart.apis.google.com";
		path = [NSString stringWithFormat:@"/chart?cht=tx&chf=bg,s,FFFFFF00&chco=%@&chl=%@",
				[doc.googleChartTextColour hexadecimalValueOfAnNSColor], input];
		
		if (doc.googleChartHeight) {
			path = [NSString stringWithFormat:@"%@&chs=%@", path, doc.googleChartHeight];	
		}
	}
	
	if (host && path) {
		/*
		 url = [[[NSURL alloc] initWithScheme:scheme host:host path:path] autorelease];
		 initWithScheme:host:path: will try to reencode the URL so don’t bother using it
		 Use initWithString: instead
		 */
		
		NSString *urlString = [NSString stringWithFormat:@"%@://%@%@", scheme, host, path];
		url = [[[NSURL alloc] initWithString:urlString] autorelease];
	}
	
	CFRelease(input);
	
	NSLog(@"Downloading from %@", url);
	
	return url;
}

#pragma mark User interface validation

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {
	SEL action = [item action];
	
	if (action == @selector(copy:)) {
		return currentlyShowing != currentlyShowingNone;
	}
	else if (action == @selector(render:)) {
		return ! httpConnection && [[inputView string] length] > 0;
	}
	
	// the default behaviour for user interface item validation
	return [self respondsToSelector:action];
}

#pragma mark NSTextViewDelegate methods

- (void)textDidChange:(NSNotification *)aNotification {
	[[self document] setLatexInput:[inputView string]];
	
	// Toolbar validation has been optimised so that under certain circumstances
	// validation is deferred for up to 0.85 seconds. We don’t want to wait for
	// that, so we force validation.
	//
	// See http://developer.apple.com/mac/library/releasenotes/Cocoa/AppKit.html
	// under ‘Live toolbar layout during customization (New since WWDC 2008)’

	[renderToolbarItem validate];
	[statusField setStringValue:@""];
}

- (BOOL)textView:(NSTextView *)textView
shouldChangeTextInRange:(NSRange)affectedCharRange
replacementString:(NSString *)replacementString {

	if ([Preferences autoPairBrackets]) {
		BOOL isBracket = NO;
		
		// Automatically close curly brackets
		if ([replacementString isEqualToString:@"{"]) {
			[textView replaceCharactersInRange:affectedCharRange withString:@"{}"];
			isBracket = YES;
		}
		// Automatically close square brackets
		else if ([replacementString isEqualToString:@"["]) {
			[textView replaceCharactersInRange:affectedCharRange withString:@"[]"];
			isBracket = YES;
		}
		// Automatically close parentheses
		else if ([replacementString isEqualToString:@"("]) {
			[textView replaceCharactersInRange:affectedCharRange withString:@"()"];
			isBracket = YES;		
		}
		
		if (isBracket) {
			// Place the insertion point between the brackets
			affectedCharRange.location++;
			[textView setSelectedRange:affectedCharRange];
			
			return NO;		
		}		
	}

	return YES;
}

#pragma mark TextViewDelegate methods

- (void)copyEmptySelection:(TextView *)sender {
	[self writeToPasteboard:[NSPasteboard generalPasteboard]];
}

- (BOOL)validateCopyEmptySelection:(TextView *)sender {
	return currentlyShowing != currentlyShowingNone;
}

#pragma mark PasteboardDelegate methods

- (void)writeToPasteboard:(NSPasteboard *)pasteboard {
	if (currentlyShowing == currentlyShowingPDF) {
		// As PDFDocument does not conform to the NSPasteboardWriting protocol,
		// we can’t use use -[NSPasteboard writeObjects:]. We use declareTypes:owner:
		// and setData:forType: instead
		// Ref. rdar://8402107
		Document *doc = [self document];
		[pasteboard clearContents];
		[pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypePDF] owner:self];
		[pasteboard setData:doc.outputData forType:NSPasteboardTypePDF];
	}
	else if (currentlyShowing == currentlyShowingImage) {
		NSImage *image = [imageView image];
		if (image) {
			[pasteboard clearContents];
			[pasteboard writeObjects:[NSArray arrayWithObject:image]];
		}
	}	
}

@end
