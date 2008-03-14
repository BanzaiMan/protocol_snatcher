/*
 *  ProtocolSnatcher.h
 *  ProtocolSnatcher
 *
 *  Created by Hirotsugu Asari on 2/17/08.
 *  Copyright 2008 Hirotsugu Asari. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import <OgreKit/OgreKit.h>
#import <Growl/Growl.h>

// headers for barebones mail plugin
#import "NSObject+ProtocolSnatcherSwizzle.h"
#import "Mail/MailApp-MFUserAgent.h"
#import "MVMailBundle.h"
// ...and my plugin
#import "ProtocolSnatcherBundle.h"
#import "CustomURLHandler.h"

// headers for inserting a preference panel in Mail.app's
#import "NSPreferences.h"
#import "NSPreferencesModule.h"
#import "PSPreferences.h"
#import "PSPreferencesModule.h"

// and constants
#define MyPrivateTableViewDataType @"PSURLRewriteRuleDataType"
#define MURLR_GROWL_NOTIFICATION_VOLUME_MOUNT_FAILED @"Remote Volume Mount Failed"
#define MURLR_GROWL_NOTIFICATION_NO_REGEX_MATCHED @"No Regular Expression Matched"
#define MURLR_GROWL_NOTIFICATION_OPEN_FILE_FAILED @"Unable To Open File"