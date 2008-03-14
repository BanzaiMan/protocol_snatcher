//
//  ProtocolSnatcherBundle.h
//  ProtocolSnatcher
//
//

#import "ProtocolSnatcher.h"

#ifdef DEBUG
#define NSLOG(x)
#else
#define NSLOG(x)
#endif

@interface ProtocolSnatcherBundle : MVMailBundle <GrowlApplicationBridgeDelegate> {
//	NSMutableArray *rules;
}

//+ (BOOL) hasPreferencePanel;
//+ (NSString *) preferencesOwnerClassName;
//+ (NSString *) preferencesPanelName;
+ (NSBundle *) bundle;
- (NSDictionary *) registrationDictionaryForGrowl;

@end
