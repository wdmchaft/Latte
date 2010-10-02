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

#import "Error.h"

@implementation Error

+ (NSError *)noLatexInput {
	NSString *desc = NSLocalizedString(@"The document cannot be saved because the LaTeX source text is empty.", @"");
	NSString *failureDesc = NSLocalizedString(@"The LaTeX source text is empty.", @"");
	NSString *recovery = NSLocalizedString(@"Enter some LaTeX source text in order to save the document.", @"");
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:desc, NSLocalizedDescriptionKey,
							  failureDesc, NSLocalizedFailureReasonErrorKey,
							  recovery, NSLocalizedRecoverySuggestionErrorKey,
							  nil];
	NSError *error = [NSError errorWithDomain:kErrorDomain
										 code:kNoLatexInputErrorCode
									 userInfo:userInfo];
	return error;
}

+ (NSError *)invalidContentTypeFor:(NSURL *)url response:(NSHTTPURLResponse *)httpResponse {
	NSString *desc = NSLocalizedString(@"The Web server has returned invalid contents.", @"");
	NSString *failureDesc = desc;
	NSString *recovery = [NSString stringWithFormat:NSLocalizedString(@"Wait a few moments and try "
		"again. If the error persists, contact Olivier Labs and provide the following information:"
		"\n\nURL: %@"
		"\n\nContent type: %@.", @""),
						  [url absoluteString],
						  [[httpResponse allHeaderFields] objectForKey:@"Content-Type"]];
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:desc, NSLocalizedDescriptionKey,
							  failureDesc, NSLocalizedFailureReasonErrorKey,
							  recovery, NSLocalizedRecoverySuggestionErrorKey,
							  nil];
	NSError *error = [NSError errorWithDomain:kErrorDomain
										 code:kInvalidContentTypeErrorCode
									 userInfo:userInfo];
	return error;
}

+ (NSError *)corruptedDocumentWithReason:(NSString *)reason {
	NSString *desc = NSLocalizedString(@"The document is corrupted.", @"");
	NSString *failureDesc = reason;
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:desc, NSLocalizedDescriptionKey,
							  failureDesc, NSLocalizedFailureReasonErrorKey,
							  nil];
	NSError *error = [NSError errorWithDomain:kErrorDomain
										 code:kCorruptedDocumentErrorCode
									 userInfo:userInfo];
	return error;	
}

@end
