//
//  PSPreferences.m
//  ProtocolSnatcher
//
//  Created by Hirotsugu Asari on 2/14/08.
//  Copyright 2008 Hirotsugu Asari. All rights reserved.
//

#import "PSPreferences.h"

@implementation PSPreferences

+(void) load {
	// pose as NSPreferences so that Mail.app will load us correctly.
	[PSPreferences poseAsClass:[NSPreferences class]];
	
	// load defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSMutableArray *rewriteRules = [defaults objectForKey:@"URLRewriteRules"];
	if (rewriteRules == nil) rewriteRules = [NSMutableArray array];
	
	NSLog(@"PSPreferences: %@",rewriteRules);
	NSEnumerator *enumerator = [rewriteRules objectEnumerator];
	id aRewriteRule;
	while ( aRewriteRule = [enumerator nextObject]) {
		NSLog(@"%@", aRewriteRule);
	}
	
}

+ (id) sharedPreferences {
	static BOOL added = NO;
	id preferences = [super sharedPreferences];
	if (preferences && !added) {
		added = YES;
		[preferences addPreferenceNamed: [ProtocolSnatcherBundle preferencesPanelName] owner: [PSPreferencesModule sharedInstance]];
	}
	return preferences;
	
}


/* rewrite rule observation */

- (void) startObservingRewriteRule: (id)rule {
	[rule addObserver:self forKeyPath:@"matchRegex" options:NSKeyValueObservingOptionOld context:NULL];
	[rule addObserver:self forKeyPath:@"replaceText" options:NSKeyValueObservingOptionOld context:NULL];
	[rule addObserver:self forKeyPath:@"shareToMount" options:NSKeyValueObservingOptionOld context:NULL];
}

- (void) stopObservingRewriteRule: (id)rule {
	[rule removeObserver:self forKeyPath:@"matchRegex"];
	[rule removeObserver:self forKeyPath:@"replaceText"];
	[rule removeObserver:self forKeyPath:@"shareToMount"];
}

@end
