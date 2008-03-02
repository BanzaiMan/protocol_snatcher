//
//  CustomURLHandler.m
//  ProtocolSnatcher
//
//  Created by Hirotsugu Asari on 2/12/08.
//  Copyright 2008 Hirotsugu Asari. All rights reserved.
//

#import "CustomURLHandler.h"

@implementation MailApp(CustomURLHandler)

- (BOOL)_ha_handleClickOnURL:(id)url
				 visibleText:(id)linkText
					 message:(id)msg
					  window:(id)containerWindow
				  dontSwitch:(BOOL)fp24 {
    // we return YES for the most part, since we will handle most errors ourselves
	/* Assume that url is UTF8-encoded. */
	NSMutableString *string = [ NSMutableString stringWithString: [url absoluteString] ];	
	NSMutableArray *rulesArray = [[NSUserDefaults standardUserDefaults] objectForKey: @"URLRewriteRules"];
    BOOL result;
    
	id aRewriteRule;
	// go through the list and rewrite URL
	// first one that succeeds in match will trigger
	for ( aRewriteRule in rulesArray) {
		if (![aRewriteRule isKindOfClass: [NSDictionary class]]) {
			// there is a problem with this object in URLRewriteRules, so we just fall through to the original method
			NSLog(@"%s contains a non-dictionary object", @"URLRewriteRules");
			return [self _ha_handleClickOnURL:url
								  visibleText:linkText
									  message:msg
									   window:containerWindow
								   dontSwitch:fp24];
		}
		
		NSString *matchRegex   = [aRewriteRule objectForKey:@"matchRegex"];
		NSString *replaceText  = [aRewriteRule objectForKey:@"replaceText"];
		NSString *shareToMount = [aRewriteRule objectForKey:@"shareToMount"];
		
		if ([string replaceOccurrencesOfRegularExpressionString: matchRegex
													 withString: replaceText
														options: OgreNoneOption
														  range: NSMakeRange(0, [string length])] > 0) {
			
			NSString *unescaped_url_str = [string stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];

			if ([shareToMount length] > 0 ) {
				OSStatus status;
				FSVolumeRefNum *fs = malloc(sizeof(FSVolumeRefNum));

				NSURL *shareURL = [NSURL URLWithString: shareToMount];
				if ((status = FSMountServerVolumeSync( (CFURLRef) shareURL,
													  NULL, // use system default mount dir
													  NULL, // user name; let underlying filesystem handle authentication
													  NULL, // password
													  fs,
													  0 // options
													  )) < 0 ) {
					/* unable to mount volume--this could take a while
					 perhaps FSMountServerVolumeASync() might be faster when it fails */
					free(fs);
                    [[NSAlert alertWithMessageText: [NSString stringWithFormat: @"Unable to mount %@", shareURL]
                                     defaultButton: @"OK"
                                   alternateButton: nil
                                       otherButton: nil
                         informativeTextWithFormat: @"Original URL: %@\nRegular expression: %@\nReplacement Text: %@\nURL after replacement: %@",
                      url, matchRegex, replaceText, string ] runModal];
                    return YES;
                } else {
                    // this portion should be inside FSVolumeMountProcPtr
					if ( [[NSWorkspace sharedWorkspace] openFile: unescaped_url_str] ) {
						free(fs);
						return YES;
					} else {
						// should alert user
						free(fs);
                        [[NSAlert alertWithMessageText: [NSString stringWithFormat: @"Unable to open %@", unescaped_url_str]
                                         defaultButton: @"OK"
                                       alternateButton: nil
                                           otherButton: nil
                             informativeTextWithFormat: @"Original URL: %@\nRegular expression: %@\nReplacement Text: %@\nURL after replacement: %@",
                          url, matchRegex, replaceText, string ] runModal];
						return YES;
					}
				} // FSMountServerVolumeSync
			} // there is a volume to mount
			else {
				result = [self _ha_handleClickOnURL:unescaped_url_str
                                        visibleText:linkText
                                            message:msg
                                             window:containerWindow
                                         dontSwitch:fp24];
                if (!result){
                    [[NSAlert alertWithMessageText: [NSString stringWithFormat: @"Unable to open %@", unescaped_url_str]
                                     defaultButton: @"OK"
                                   alternateButton: nil
                                       otherButton: nil
                         informativeTextWithFormat: @"Original URL: %@\nRegular expression: %@\nReplacement Text: %@\nURL after replacement: %@",
                      url, matchRegex, replaceText, string ] runModal];
                }
                return YES;
			}
		} // URL matched this rule...
	} // looping over rules array

	// none of the rewrite rules matched, so we'll
	// just hand this request off to the original method
	return [self _ha_handleClickOnURL:url
                            visibleText:linkText
                                message:msg
                                 window:containerWindow
                             dontSwitch:fp24];
}

@end
