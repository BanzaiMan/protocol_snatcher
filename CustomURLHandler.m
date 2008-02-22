//
//  CustomURLHandler.m
//  ProtocolSnatcher
//
//  Created by Hirotsugu Asari on 2/12/08.
//  Copyright 2008 Hirotsugu Asari. All rights reserved.
//

#import "CustomURLHandler.h"

@implementation MailApp(CustomURLHandler)
- (BOOL)_ha_handleClickOnURL:(id)url visibleText:(id)linkText message:(id)msg window:(id)containerWindow dontSwitch:(BOOL)fp24 {
	NSMutableString *string = [ NSMutableString stringWithString: [[url absoluteString] lowercaseString] ];
	
	OSStatus status;
	CFURLRef urlRef;
	FSVolumeRefNum *fs;
	
	NSMutableArray *rulesArray = [[NSUserDefaults standardUserDefaults] objectForKey: @"URLRewriteRules"];
	
	NSEnumerator *enumerator = [ rulesArray objectEnumerator];
	id aRewriteRule;
	/*
		TODO: Embed Perl interpreter to allow case changes in the replacement text (e.g., \u\1\E).  maybe.
	*/
	// go through the list and rewrite URL
	// first one that succeeds in match will trigger the real handleClickOnURL.
	while ( aRewriteRule = [enumerator nextObject]) {
		if (![aRewriteRule isKindOfClass: [NSDictionary class]]) {
			// there is a problem with this object in URLRewriteRules, so we just fall through to the original method
			NSLog(@"%s contains a non-dictionary object", @"URLRewriteRules");
			return [self _ha_handleClickOnURL:url visibleText:linkText message:msg window:containerWindow dontSwitch:fp24];
		}
		
		int matchCount = [string replaceOccurrencesOfRegularExpressionString: [aRewriteRule objectForKey:@"matchRegex"]
			withString: [aRewriteRule objectForKey:@"replaceText"]
			options:OgreNoneOption
			range:NSMakeRange(0, [string length])];

		if (matchCount > 0) {
			if ([[aRewriteRule objectForKey:@"shareToMount"] length] > 0 ) {
				
				if ((status = FSMountServerVolumeSync( CFURLCreateWithString(NULL, (CFStringRef)[aRewriteRule objectForKey:@"shareToMount"], urlRef), NULL, (CFStringRef)@"", (CFStringRef)@"",fs,(UInt32) NULL)) < 0 ) {
					; // it failed.
				} else {
					; // it succeeded.
				}

			}
			
			NSString *unescaped_url_str = [string stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
			
			if ( [[NSWorkspace sharedWorkspace] openFile: unescaped_url_str] ) {
				return YES;
			} else {
				// should alert user
				return NO;
			}
		}
	}

//	NSLog(@"calling the original handleClickOnURL method");
	return [self _ha_handleClickOnURL:url visibleText:linkText message:msg window:containerWindow dontSwitch:fp24];
	
}
@end
