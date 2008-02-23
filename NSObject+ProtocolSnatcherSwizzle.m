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
//    NSLog(@"Attempting to swizzle in class '%@': swapping method '%@' with '%@'...",[self class], originalMethodName, alternateMethodName);
	
    // First, look for the methods
    Method orig_method = nil, alt_method = nil;
    orig_method = class_getInstanceMethod([self class], orig_sel);
    alt_method = class_getInstanceMethod([self class], alt_sel);
	
    // If both are found, swizzle them
    if ((orig_method != nil) && (alt_method != nil)) {
		method_exchangeImplementations(orig_method, alt_method);
/*
        char *temp1;
        IMP temp2;
		
        temp1 = orig_method->method_types;
        orig_method->method_types = alt_method->method_types;
        alt_method->method_types = temp1;
		
        temp2 = orig_method->method_imp;
        orig_method->method_imp = alt_method->method_imp;
        alt_method->method_imp = temp2;
	NSLog(@"  ...succeeded!");
 */
    } else {
	if (orig_method == nil) {
	    NSLog(@"    ...ERROR: original method '%@' doesn't exist",originalMethodName);
	}
	if (alt_method == nil) {
	    NSLog(@"    ...ERROR: alternate method '%@' doesn't exist",alternateMethodName);
	}
    }
}

+ (void)ProtocolSnatcherReplaceMethod:(SEL)orig_sel withMethod:(SEL)alt_sel fromClass:(Class)targetClass {
    NSString *originalMethodName = [NSString stringWithCString:sel_getName(orig_sel)];
    NSString *alternateMethodName = [NSString stringWithCString:sel_getName(alt_sel)];    	
    NSLog(@"Attempting to replace class \"%@\"'s method \"%@\" with class \"%@\"'s method \"%@\"...",[self class],originalMethodName,targetClass,alternateMethodName);

    // First, look for the methods
    Method orig_method = nil, alt_method = nil;
    orig_method = class_getInstanceMethod([self class], orig_sel);
    alt_method = class_getInstanceMethod(targetClass, alt_sel);
	
    // If both are found, replace!
    if ((orig_method != nil) && (alt_method != nil)) {
		
/*
	orig_method->method_types = alt_method->method_types;
	orig_method->method_imp = alt_method->method_imp;
*/
	method_setImplementation(orig_method, method_getImplementation(alt_method));
	NSLog(@"   ...succeeded!");
    } else {
	if (orig_method == nil) {
	    NSLog(@"    ...ERROR: original method '%@' doesn't exist",originalMethodName);
	}
	if (alt_method == nil) {
	    NSLog(@"    ...ERROR: alternate method '%@' doesn't exist",alternateMethodName);
	}
    }
}

- (id)ProtocolSnatcherPerformSelector:(SEL)sel asClass:(Class)cls {
    Class wasa = [self class];
    id result;

    NS_DURING {
        isa = cls;
        result = [self performSelector:sel];
        isa = wasa;
    } NS_HANDLER {
        isa = wasa;
        [localException raise];
    } NS_ENDHANDLER;

    return result;
}

// ----------- poseAsClass support -----------------
static NSMutableDictionary *ProtocolSnatcher_swizzle_instanceIDToIvars = nil;
static BOOL ProtocolSnatcher_swizzle_needToSwizzleDealloc = YES;


- (id)ProtocolSnatcher_swizzle_instanceID
{
    return [NSValue valueWithPointer:self];
}

- (NSMutableDictionary *)ProtocolSnatcher_swizzle_ivars
{
    NSMutableDictionary *ivars;
    
    if (ProtocolSnatcher_swizzle_needToSwizzleDealloc)
    {
	[[self class] ProtocolSnatcherSwizzleMethod:@selector(dealloc) withMethod:@selector(swizzle_deallocSwizzler)]; 
    	ProtocolSnatcher_swizzle_needToSwizzleDealloc = NO;
    }
    
    if (ProtocolSnatcher_swizzle_instanceIDToIvars == nil)
    {
        ProtocolSnatcher_swizzle_instanceIDToIvars = [[NSMutableDictionary alloc] init];
    }
    
    ivars = [ProtocolSnatcher_swizzle_instanceIDToIvars objectForKey:[self ProtocolSnatcher_swizzle_instanceID]];
    if (ivars == nil)
    {
        ivars = [NSMutableDictionary dictionary];
        [ProtocolSnatcher_swizzle_instanceIDToIvars setObject:ivars forKey:[self ProtocolSnatcher_swizzle_instanceID]];
    }
    
    return ivars;
}

- (void)ProtocolSnatcher_swizzle_deallocSwizzler
{
    [ProtocolSnatcher_swizzle_instanceIDToIvars removeObjectForKey:[self ProtocolSnatcher_swizzle_instanceID]];
    if ([ProtocolSnatcher_swizzle_instanceIDToIvars count] == 0)
    {
        [ProtocolSnatcher_swizzle_instanceIDToIvars release];
        ProtocolSnatcher_swizzle_instanceIDToIvars = nil;
    }
    
    [self ProtocolSnatcher_swizzle_deallocSwizzler];
}
@end

