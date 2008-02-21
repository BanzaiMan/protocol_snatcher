//
//  PSPreferences.h
//  ProtocolSnatcher
//
//  Created by Hirotsugu Asari on 2/14/08.
//  Copyright 2008 Hirotsugu Asari. All rights reserved.
//

#import "ProtocolSnatcher.h"


@interface PSPreferences : NSPreferences {

}

- (void) startObservingRewriteRule: (id)rule;
- (void) stopObservingRewriteRule: (id)rule;

@end
