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

- (id) init {
	NSBundle *myBundle    = [NSBundle bundleWithIdentifier:@"net.asari.murlr"];
    NSString *growlPath   = [[myBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
    NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
    
    if (growlBundle && [growlBundle load]) {
        // Register ourselves as a Growl delegate
        [GrowlApplicationBridge setGrowlDelegate:self];
    } else {
        NSLog(@"Could not load Growl.framework");
    }
    return self;
}

#pragma mark -
#pragma mark Growl delegate methods
- (NSString *) applicationNameForGrowl {
    return @"MURLR";
}

- (NSDictionary *) registrationDictionaryForGrowl {
    NSArray *allNotifications = [NSArray arrayWithObjects:
                                 MURLR_GROWL_NOTIFICATION_VOLUME_MOUNT_FAILED,
                                 MURLR_GROWL_NOTIFICATION_NO_REGEX_MATCHED,
                                 MURLR_GROWL_NOTIFICATION_OPEN_FILE_FAILED,
                                 nil];
    NSArray *defaultNotifications = [NSArray arrayWithObjects:
                                     MURLR_GROWL_NOTIFICATION_VOLUME_MOUNT_FAILED,
                                     MURLR_GROWL_NOTIFICATION_OPEN_FILE_FAILED,
                                     nil];
    return [NSDictionary dictionaryWithObjectsAndKeys: allNotifications, GROWL_NOTIFICATIONS_ALL,
            defaultNotifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
}

- (void) growlNotificationWasClicked:(id)clickContext {
    NSLog(@"growlNotificationWasClicked: %@", clickContext);
}

@end
