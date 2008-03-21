//
//  CustomURLHandler.m
//  ProtocolSnatcher
//
//  Created by Hirotsugu Asari on 2/12/08.
//  Copyright 2008 Hirotsugu Asari. All rights reserved.
//

#import "CustomURLHandler.h"

static void
volumeMountCallback(FSVolumeOperation volumeOp, void *clientData, OSStatus err, FSVolumeRefNum mountedVolumeRefNum)
{
	NSDictionary *dict = [(NSString *)clientData autorelease];
	NSString *url               = [dict objectForKey:@"originalURL"];
    NSString *matchRegex        = [dict objectForKey:@"matchRegex"];
    NSString *replaceText       = [dict objectForKey:@"replaceText"];
    NSString *string            = [dict objectForKey:@"rewrittenURL"];
    NSString *unescaped_url_str = [dict objectForKey:@"unescapedURL"];
    
    
    if (err != noErr) {
        if ([GrowlApplicationBridge isGrowlRunning]) {
            // Remember that we are posing as MailApp class at the moment...
            [MailApp postGrowlNotificationName:MURLR_GROWL_NOTIFICATION_VOLUME_MOUNT_FAILED details:dict];
        } else {
            [[NSAlert alertWithMessageText: [NSString stringWithFormat: @"Unable to mount requested volume"]
                             defaultButton: @"Dismiss"
                           alternateButton: nil
                               otherButton: nil
                 informativeTextWithFormat: @"Original URL: %@\nRegular expression: %@\nReplacement Text: %@\nURL after replacement: %@",
              url, matchRegex, replaceText, string ] runModal];            
        }
        FSDisposeVolumeOperation(volumeOp);
        return;
    }
    
    // Volume mount was successful, so try opening the file
    if ( ! [[NSWorkspace sharedWorkspace] openFile: unescaped_url_str] ) {
        // failed to open the file, so alert the user
        if ([GrowlApplicationBridge isGrowlRunning]) {
            [MailApp postGrowlNotificationName:MURLR_GROWL_NOTIFICATION_OPEN_FILE_FAILED details:dict];
        } else {
            [[NSAlert alertWithMessageText: [NSString stringWithFormat: @"Unable to open %@", unescaped_url_str]
                             defaultButton: @"Dismiss"
                           alternateButton: nil
                               otherButton: nil
                 informativeTextWithFormat: @"Original URL: %@\nRegular expression: %@\nReplacement Text: %@\nURL after replacement: %@",
              url, matchRegex, replaceText, string ] runModal];            
        }
    }
    FSDisposeVolumeOperation(volumeOp);
    return;
}

@implementation MailApp(CustomURLHandler)

- (BOOL)_ha_handleClickOnURL:(id)url
    visibleText:(id)linkText
    message:(id)msg
    window:(id)containerWindow
    dontSwitch:(BOOL)fp24
{
    // we return YES for the most part, since we will handle most errors ourselves
    // if we return NO, Mail.app will display error dialog as well
    /* Assume that url is UTF8-encoded. */
    NSMutableString *string    = [ NSMutableString stringWithString: [url absoluteString] ];	
    NSMutableArray *rulesArray = [[NSUserDefaults standardUserDefaults] objectForKey: @"URLRewriteRules"];

    FSVolumeMountUPP volumeMountUPP = NewFSVolumeMountUPP(volumeMountCallback);
    FSVolumeOperation volumeOp;
    OSStatus err                    = FSCreateVolumeOperation(&volumeOp);
    
    NSMutableDictionary *detailedInfo = [NSMutableDictionary dictionaryWithObject: string forKey: @"originalURL"];

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
        [detailedInfo setObject:matchRegex   forKey:@"matchRegex"];
        [detailedInfo setObject:replaceText  forKey:@"replaceText"];
        [detailedInfo setObject:shareToMount forKey:@"shareToMount"];
        
        if (matchRegex == nil || replaceText == nil || shareToMount == nil) {
            NSLog(@"Rewrite rule lacks required parameter");
            continue;
        }

        if ([string replaceOccurrencesOfRegularExpressionString: matchRegex
            withString: replaceText options: OgreNoneOption
            range: NSMakeRange(0, [string length])] > 0) {
                                                              
            NSString *unescaped_url_str = [string stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSDictionary *remoteVolumeMountInfo = [[NSDictionary alloc] initWithObjectsAndKeys: [url absoluteString], @"originalURL",
                matchRegex, @"matchRegex", replaceText, @"replaceText", string, @"rewrittenURL",unescaped_url_str, @"unescapedURL",nil];
            if ([shareToMount length] > 0 ) {
                NSURL *shareURL = [NSURL URLWithString: shareToMount];
                if ((err = FSMountServerVolumeAsync( (CFURLRef) shareURL,
                    NULL, NULL, NULL, volumeOp, remoteVolumeMountInfo, 0,
                    volumeMountUPP, CFRunLoopGetCurrent(), kCFRunLoopCommonModes)) != noErr) {
                    FSDisposeVolumeOperation(volumeOp);
                } // FSMountServerVolumeAsync
            }
            else {
                if ( ! [self _ha_handleClickOnURL:unescaped_url_str
                    visibleText:linkText
                    message:msg
                    window:containerWindow
                    dontSwitch:fp24] ) {
                    if ([GrowlApplicationBridge isGrowlRunning]) {
                        [MailApp postGrowlNotificationName:MURLR_GROWL_NOTIFICATION_OPEN_FILE_FAILED details:detailedInfo];
                    } else {
                        [[NSAlert alertWithMessageText: [NSString stringWithFormat: @"Unable to open %@", unescaped_url_str]
                                         defaultButton: @"Dismiss"
                                       alternateButton: nil
                                           otherButton: nil
                             informativeTextWithFormat: @"Original URL: %@\nRegular expression: %@\nReplacement Text: %@\nURL after replacement: %@",
                          url, matchRegex, replaceText, string ] runModal];            
                    }
                }
            }
            return YES;
        } // URL matched this rule...
    } // looping over rules array

    // none of the rewrite rules matched, so we'll
    // just hand this request off to the original method
    [MailApp postGrowlNotificationName: MURLR_GROWL_NOTIFICATION_NO_REGEX_MATCHED
                               details:[NSDictionary dictionaryWithObject:[url absoluteString] forKey:@"originalURL"]];
    return [self _ha_handleClickOnURL:url visibleText:linkText message:msg window:containerWindow dontSwitch:fp24];
}

+ (void)postGrowlNotificationName:(NSString *)notification details:(NSDictionary *)detailedInfo {
    [GrowlApplicationBridge notifyWithTitle: notification
                                description: @"Click for more information...."
                           notificationName: notification
                                   iconData: nil
                                   priority: 0
                                   isSticky: NO
                               clickContext: detailedInfo];
}

@end
