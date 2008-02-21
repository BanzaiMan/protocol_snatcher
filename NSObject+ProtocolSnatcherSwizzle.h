//
//  NSObject+ProtocolSnatcherSwizzle.h
//  ProtocolSnatcher
//
//  Created by Aaron Harnly on 6/9/06.
//
// Some utilities for doing magical dynamic stuff.
// 

#import <Cocoa/Cocoa.h>


@interface NSObject (ProtocolSnatcherSwizzle)
// swizzleMethod: withMethod:
// swaps the implementations of two methods within a class
// so, with fooBar: and customFooBar:, swizzling will cause all calls to
// fooBar: to actually trigger the code written in customFooBar:
//  and vice-versa
// so, to call the *original* fooBar: implementation within the new customFooBar:,
//  send a 'customFooBar:' message, which will actually trigger the original fooBar: implementation.
+ (void)ProtocolSnatcherSwizzleMethod:(SEL)orig_sel withMethod:(SEL)alt_sel;

// replaceMethod: withMethod: fromClass:
// *replaces* the implementation of an original method fooBar:
//  with some other method doStuff: from a different target class.
// Obviously, this should be used with caution, and the target class should almost
//  certainly be a superclass.
+ (void)ProtocolSnatcherReplaceMethod:(SEL)orig_sel withMethod:(SEL)alt_sel fromClass:(Class)targetClass;

// performSelector: asClass:
// an instance method to do a one-time swaparoo.
// for example, with two classes Sun and Moon, which implement sunShine: and moonShine:
//   we can send a [theSun performSelector:@(moonShine) asClass:[Moon class]] to get a one-time
//   novel behavior. This only works if moonShine doesn't reference variables or methods from Moon
//   that don't exist in Sun.
- (id)ProtocolSnatcherPerformSelector:(SEL)sel asClass:(Class)cls;

// some stuff to make supporting poseAsClass easy
// this machinery helps us have a static NSMutableDictionary that maps instances to dictionaries
- (id)ProtocolSnatcher_swizzle_instanceID;
- (NSMutableDictionary *)ProtocolSnatcher_swizzle_ivars;
@end
