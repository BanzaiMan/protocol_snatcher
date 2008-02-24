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
	/* Assume that url is UTF8-encoded.
	 * If the boot disk's filesystem is case-sensitive, it is quite significant
	 * to get the mount points right.
	 * Unfortunately, CIFS is _probably_ on NTFS on the file server end, so
	 * the links we click on is not guaranteed to have the same case for the
	 * same share.
	 */
	NSMutableString *string = [ NSMutableString stringWithString: [url absoluteString] ];
	NSString *unescapedString = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableArray *rulesArray = [[NSUserDefaults standardUserDefaults] objectForKey: @"URLRewriteRules"];
	
	NSEnumerator *enumerator = [ rulesArray objectEnumerator];
	id aRewriteRule;
	// go through the list and rewrite URL
	// first one that succeeds in match will trigger
	while ( aRewriteRule = [enumerator nextObject]) {
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
		
		NSTask *perlTask = [[NSTask alloc] init];
		NSPipe *perlPipe = [NSPipe pipe];
		[perlTask setStandardOutput:perlPipe];

		NSFileHandle *perlOutputFH = [perlPipe fileHandleForReading];
		NSData *inputData = nil;
		NSString *perlCommand = [NSString stringWithFormat: @"$s = '%@'; $s =~ s#%@#%@#; print $s;", unescapedString, matchRegex, replaceText];
		
		[perlTask setLaunchPath: @"/usr/bin/perl"];
		[perlTask setArguments:[NSArray arrayWithObjects:@"-e",perlCommand, nil]];
		
		[perlTask launch];
		[perlTask waitUntilExit];
		
		if ([perlTask terminationStatus] != 0) {
			NSLog(@"perl string replacement failed.");
			NSLog(@"string: %@",string);
			NSLog(@"matchRegex: %@",matchRegex);
			NSLog(@"replaceText: %@",replaceText);
			NSLog(@"perlCommand: %@",perlCommand);
			continue;
		}
		
		inputData = [perlOutputFH readDataToEndOfFile];
		NSString *newstring = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
		
		[perlTask release];

		// Since perl's output won't tell us the substitution happened, we'll
		// compare the resulting string with the "original" to determine if
		// we had a match
		if ([unescapedString compare:newstring] != NSOrderedSame) {
			NSLog(@"unescaedString: %@", unescapedString);
			NSLog(@"newstring: %@", newstring);
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
					;
				} else {
					if ( [[NSWorkspace sharedWorkspace] openFile: unescaped_url_str] ) {
						return YES;
					} else {
						// should alert user
						return NO;
					}
				} // FSMountServerVolumeSync

				free(fs);
			} // if ...shareToMount...
			else {
				return [self _ha_handleClickOnURL:unescaped_url_str
									  visibleText:linkText
										  message:msg
										   window:containerWindow
									   dontSwitch:fp24];
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
