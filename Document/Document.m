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

#import "Document.h"
#import "DocumentWC.h"
#import "Error.h"
#import "OptionsConstants.h"
#import "Preferences.h"

#define kInputFileName @"LaTeX Source.txt"
#define kOptionsFileName @"Options.plist"
#define kOutputFileNamePrefix @"Formula"
#define kInvalidOptions NSLocalizedString(@"Invalid options.", @"")

@implementation Document

@synthesize latexInput;
@synthesize outputType;
@synthesize outputData;

@synthesize webEngine;
@synthesize codeCogsOutputType;
@synthesize codeCogsTextColour;
@synthesize googleChartTextColour;
@synthesize googleChartHeight;

- (id)init {
	if (self = [super init]) {
		latexInput = [NSString new];
		outputType = outputTypeUndefined;
		outputData = [NSData new];
		
		// Copy user defaults into document options
		webEngine = [Preferences webEngine];
		codeCogsOutputType = [Preferences codeCogsOutputType];
		codeCogsTextColour = [Preferences codeCogsTextColour];
		googleChartTextColour = [[Preferences googleChartTextColour] copy];
	}

	return self;
}

- (void)dealloc {
	self.latexInput = nil;
	self.outputData = nil;
	
	[super dealloc];
}

+ (BOOL)canConcurrentlyReadDocumentsOfType:(NSString *)typeName {
	return YES;
}

- (void)makeWindowControllers {
	DocumentWC *controller = [[[DocumentWC alloc] init] autorelease];
	[self addWindowController:controller];
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)dirWrapper ofType:(NSString *)typeName error:(NSError **)outError {
	NSFileWrapper *wrapper = nil;
	NSData *data = nil;
	
	@try {
		// LaTeX source
		wrapper = [[dirWrapper fileWrappers] objectForKey:kInputFileName];
		if (! wrapper) @throw NSLocalizedString(@"The document does not contain LaTeX source text.", @"");
		
		data = [wrapper regularFileContents];
		self.latexInput = [[[NSString alloc] initWithBytes:[data bytes]
												   length:[data length]
												 encoding:NSUTF8StringEncoding]
						   autorelease];
		
		// Options
		wrapper = [[dirWrapper fileWrappers] objectForKey:kOptionsFileName];
		if (! wrapper) @throw NSLocalizedString(@"The document does not contain options.", @"");
		
		data = [wrapper regularFileContents];
		NSPropertyListFormat plistFormat;
		NSError *error = nil;
		id plist = nil;
		plist = [NSPropertyListSerialization propertyListWithData:data
														  options:0
														   format:&plistFormat
															error:&error];
		if (! plist) @throw kInvalidOptions;
		if (error) @throw [NSString stringWithFormat:@"%@: %@",
						   kInvalidOptions,
						   [error localizedFailureReason]];
		if (! [plist isKindOfClass:[NSDictionary class]]) @throw kInvalidOptions;
		NSDictionary *options = (NSDictionary *)plist;
		self.webEngine = [[options objectForKey:kWebEngineKey] intValue];
		self.codeCogsOutputType = [[options objectForKey:kCodeCogsOutputTypeKey] intValue];
		self.codeCogsTextColour = [[options objectForKey:kCodeCogsTextColourKey] intValue];
		self.googleChartTextColour = [NSUnarchiver unarchiveObjectWithData:[options objectForKey:kGoogleChartTextColourKey]];
		self.googleChartHeight = [options objectForKey:kGoogleChartHeightKey];
		
		// Output data
		for (NSString *extension in [NSArray arrayWithObjects:@"pdf", @"png", @"gif", nil]) {
			NSString *outputFileName = [NSString stringWithFormat:@"%@.%@",
										kOutputFileNamePrefix,
										extension];
			wrapper = [[dirWrapper fileWrappers] objectForKey:outputFileName];
			if (wrapper) {
				self.outputData = [wrapper regularFileContents];
				self.outputType = [Document extensionToType:extension];
				break;
			}
		}
	}
	@catch (NSString *reason) {
		if (outError) *outError = [Error corruptedDocumentWithReason:reason];
		return NO;
	}

	return YES;
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError {
	NSData *inputData = nil;
	NSData *optionsData = nil;
	NSString *outputFileName = nil;
	NSFileWrapper *dirWrapper = nil;
	
	if ([latexInput length] == 0) {
		if (outError) *outError = [Error noLatexInput];
		return nil;	
	}

	inputData = [latexInput dataUsingEncoding:NSUTF8StringEncoding];

	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithInt:webEngine], kWebEngineKey,
							 [NSNumber numberWithInt:codeCogsOutputType], kCodeCogsOutputTypeKey,
							 [NSNumber numberWithInt:codeCogsTextColour], kCodeCogsTextColourKey,
							 [NSArchiver archivedDataWithRootObject:googleChartTextColour], kGoogleChartTextColourKey,
							 googleChartHeight, kGoogleChartHeightKey,
							 nil];
	optionsData = [NSPropertyListSerialization dataWithPropertyList:options
															 format:NSPropertyListXMLFormat_v1_0
															options:0
															  error:NULL];	

	outputFileName = [NSString stringWithFormat:@"%@.%@",
					  kOutputFileNamePrefix,
					  [Document typeToExtension:outputType]];

	dirWrapper = [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil] autorelease];
	[dirWrapper addRegularFileWithContents:inputData preferredFilename:kInputFileName];
	[dirWrapper addRegularFileWithContents:optionsData preferredFilename:kOptionsFileName];
	[dirWrapper addRegularFileWithContents:outputData preferredFilename:outputFileName];

	return dirWrapper;
}

+ (NSString *)typeToExtension:(OutputType)type {
	return
	(type == outputTypePDF) ? @"pdf" :
	(type == outputTypePNG) ? @"png" :
	(type == outputTypeGIF) ? @"gif" :
	NSLocalizedString(@"unknown", @"Unknown file type/extension");
}

+ (OutputType)extensionToType:(NSString *)extension {
	return
	([extension isEqualToString:@"pdf"]) ? outputTypePDF :
	([extension isEqualToString:@"png"]) ? outputTypePNG :
	([extension isEqualToString:@"gif"]) ? outputTypeGIF :
	outputTypeUndefined;
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {
	SEL action = [item action];
	
	if (action == @selector(saveDocument:) || action == @selector(saveDocumentAs:)) {
		return [latexInput length] > 0 && [super validateUserInterfaceItem:item];
	}
	
	return [super validateUserInterfaceItem:item];
}

@end
