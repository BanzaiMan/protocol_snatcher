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
	
}

+ (id) sharedPreferences {
	static BOOL added = NO;
	id preferences = [super sharedPreferences];
	if (preferences && !added) {
		added = YES;
		[preferences addPreferenceNamed: [ProtocolSnatcherBundle preferencesPanelName]
								  owner: [PSPreferencesModule sharedInstance]];
	}
	return preferences;
	
}

@end
