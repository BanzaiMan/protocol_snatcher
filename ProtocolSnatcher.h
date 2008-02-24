/*
 *  ProtocolSnatcher.h
 *  ProtocolSnatcher
 *
 *  Created by Hirotsugu Asari on 2/17/08.
 *  Copyright 2008 Hirotsugu Asari. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
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
