//
//  ProtocolSnatcherBundle.m
//  ProtocolSnatcher
//
//

#import "ProtocolSnatcherBundle.h"

@implementation ProtocolSnatcherBundle
+ (void) initialize
{
	NSBundle *myBundle;
	[super initialize];
	myBundle = [NSBundle bundleForClass:self];
	[self registerBundle];

	[MailApp ProtocolSnatcherSwizzleMethod: @selector(handleClickOnURL:visibleText:message:window:dontSwitch:)
		withMethod: @selector(_ha_handleClickOnURL:visibleText:message:window:dontSwitch:)];
	NSLog(@"Mail.app URL Rewriter loaded");
}

+ (BOOL) hasPreferencePanel {
// I don't think this has any bearing on the behavior of the bundle preferences
	return YES;
}

+ (NSString *) preferencesOwnerClassName {
    //NSLog(@"Returning PreferenceOwnerClassName");
    return @"PSPreferencesModule";
}

+ (NSString *) preferencesPanelName {
     //NSLog(@"Returning PreferencePanelName");
    return @"MURLR";
}

+ (NSBundle *) bundle {
    return [NSBundle bundleForClass:self];
}


@end
