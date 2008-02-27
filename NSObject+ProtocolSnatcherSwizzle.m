//
//  NSObject+ProtocolSnatcherSwizzle.m
//  ProtocolSnatcher
//
//  Created by Aaron Harnly on 6/9/06.
//

// Using Leopard's new API

#import "NSObject+ProtocolSnatcherSwizzle.h"
#import <objc/objc-runtime.h>
// Turn off GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS to avoid warnings in this header

@implementation NSObject(ProtocolSnatcherSwizzle)

+ (void)ProtocolSnatcherSwizzleMethod:(SEL)orig_sel withMethod:(SEL)alt_sel {
	NSString *originalMethodName = [NSString stringWithCString:sel_getName(orig_sel)];
	NSString *alternateMethodName = [NSString stringWithCString:sel_getName(alt_sel)];    

	// First, look for the methods
	Method orig_method = nil, alt_method = nil;
	orig_method = class_getInstanceMethod([self class], orig_sel);
	alt_method = class_getInstanceMethod([self class], alt_sel);

	// If both are found, swizzle them with Apple's API
	if ((orig_method != nil) && (alt_method != nil)) {
		method_exchangeImplementations(orig_method, alt_method);
	} else {
		if (orig_method == nil) {
			NSLog(@"    ...ERROR: original method '%@' doesn't exist",originalMethodName);
		}
		if (alt_method == nil) {
			NSLog(@"    ...ERROR: alternate method '%@' doesn't exist",alternateMethodName);
		}
	}
}

@end

