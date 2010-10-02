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

/*
 * Inspired by an example at http://homepage.mac.com/mmalc/CocoaExamples/controllers.html
 */

#import "OptionsPanelWC.h"
#import "OptionsConstants.h"
#import "Document.h"
#import "DocumentWC.h"
#import "BuildCodeCogsTextColourMenu.h"

#define kDocumentKeyPath @"mainWindow.windowController.document"

@implementation OptionsPanelWC

@synthesize webEngineField;
@synthesize tabView;
@synthesize codeCogsTextColourButton;
@synthesize inspectedDocument;

- (id)init {
	self = [super initWithWindowNibName:@"OptionsPanel"];
	return self;
}

- (void)awakeFromNib {
	buildCodeCogsTextColourMenu([codeCogsTextColourButton menu]);
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	// Once the UI is loaded, we start observing the panel itself to commit editing
	// when it becomes inactive (loses key state)
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(inspectorPanelDidResignKey:)
												 name:NSWindowDidResignKeyNotification
											   object:[self window]];
	
	// We need to observe changes to the main window and its corresponding document
	[self activeDocumentChanged];
	[NSApp addObserver:self
			forKeyPath:kDocumentKeyPath
			   options:0
			   context:[OptionsPanelWC class]];	
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSWindowDidResignKeyNotification
												  object:[self window]];
	[NSApp removeObserver:self forKeyPath:kDocumentKeyPath];
	[super dealloc];
}

/*
 Whenever the properties panel loses key status, we want to commit editing
 */
- (void)inspectorPanelDidResignKey:(NSNotification *)notification {
    [docController commitEditing];
}

/*
 We're observing mainWindow.windowController.document. If we get a KVO notification, check
 whether the document we consider to be active has been changed
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
					   context:(void *)context {
    if (context == [OptionsPanelWC class]) [self activeDocumentChanged];
	else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

/*
 inspectedDocument is a KVO-compliant property, which this method manages. Anytime we hear about
 the mainWindow, or the mainWindow's document change, we check to see what changed
 */
- (void)activeDocumentChanged {
    id mainDocument = [[[NSApp mainWindow] windowController] document];
	
    if (mainDocument != inspectedDocument) {
		if (inspectedDocument) [docController commitEditing];
		
		self.inspectedDocument = (mainDocument && [mainDocument isKindOfClass:[Document class]]) ? mainDocument : nil;
		[self webEngineChanged:self];
    }
}

/*
 When controls in the panel start editing, register it with the inspected document
 */
- (void)objectDidBeginEditing:(id)editor {
    [inspectedDocument objectDidBeginEditing:editor];
}

- (void)objectDidEndEditing:(id)editor {
    [inspectedDocument objectDidEndEditing:editor];
}

- (IBAction)webEngineChanged:(id)sender {
	[tabView selectTabViewItemAtIndex:[webEngineField selectedTag]];
}

@end
