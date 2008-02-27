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

@end
