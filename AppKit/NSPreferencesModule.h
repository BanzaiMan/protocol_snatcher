/*
 *  NSPreferencesModule.h
 *  ProtocolSnatcher
 *
 *  Created by Hirotsugu Asari on 2/15/08.
 *  Copyright 2008 Hirotsugu Asari. All rights reserved.
 *  Created with class-dump 3.1.2 from /System/Library/Frameworks/AppKit.framework/AppKit 
 *  From OS 10.5.2 (Build 9C31)
 */
 
#import <objc/objc.h>

@protocol NSPreferencesModule
- (NSImage *) imageForPreferenceNamed:(NSString *)_name;
- (NSString *) preferencesNibName;
- (void) didChange;
- (NSView*) viewForPreferenceNamed:(NSString *)aName;
- (void) willBeDisplayed;
- (void) saveChanges;
- (BOOL) hasChangesPending;
- (void)moduleWillBeRemoved;
- (void)moduleWasInstalled;
@end

@class NSBox;

@interface NSPreferencesModule : NSObject <NSPreferencesModule>
{
    IBOutlet NSBox *_preferencesView;
    struct _NSSize _minSize;
    BOOL _hasChanges;
    void *_reserved;
}

+ (id)sharedInstance;
- (void)dealloc;
- (void)finalize;
- (id)init;
- (id)preferencesNibName;
- (void)setPreferencesView:(id)fp8;
- (id)viewForPreferenceNamed:(id)fp8;
- (id)imageForPreferenceNamed:(id)fp8;
- (id)titleForIdentifier:(id)fp8;
- (BOOL)hasChangesPending;
- (void)saveChanges;
- (void)willBeDisplayed;
- (void)initializeFromDefaults;
- (void)didChange;
- (struct _NSSize)minSize;
- (void)setMinSize:(struct _NSSize)fp8;
- (void)moduleWillBeRemoved;
- (void)moduleWasInstalled;
- (BOOL)moduleCanBeRemoved;
- (BOOL)preferencesWindowShouldClose;
- (BOOL)isResizable;

@end

