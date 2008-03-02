//
//  CustomURLHandler.h
//  ProtocolSnatcher
//
//  Created by Hirotsugu Asari on 2/12/08.
//  Copyright 2008 Hirotsugu Asari. All rights reserved.
//

#import "ProtocolSnatcher.h"
#define MURLR_ERROR_DOMAIN @"MURLR Error Domain"
#define MURLR_VOLUME_MOUNT_ERROR 1
#define MURLR_OPEN_FILE_ERROR 2

@interface MailApp  (CustomURLHandler)

- (BOOL)_ha_handleClickOnURL:(id)fp8 visibleText:(id)fp12 message:(id)fp16 window:(id)fp20 dontSwitch:(BOOL)fp24;
@end
