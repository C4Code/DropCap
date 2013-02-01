//
//  C4Window.h
//  C4iOSDevelopment
//
//  Created by Travis Kirton on 11-10-07.
//  Copyright (c) 2011 mediart. All rights reserved.
//

#import <UIKit/UIKit.h>

/**The C4Window class is a subclass of UIWindow. The two principal functions of a window are to provide an area for displaying its views and to distribute events to the views. The window is the root view in the view hierarchy. Typically, there is only one window in an iOS application.

For more information about how to use windows, see View Programming Guide for iOS.
 
 The C4Window is a subclass of UIWindow, which is also a subclass of UIView. Because we cannot create chains of subclasses i.e. C4Window : C4View, the addShape: and addLabel: methods are coded directly into this class for sake of convenience.

 @warning *Note:* in C4 you should never have to worry about constructing windows.
*/
@interface C4Window : UIWindow <C4MethodDelay, C4Notification, C4AddSubview>

#pragma mark Root View Controller

/** A controller which will be set at the window's root view controller.
 
 This property provides access for setting a C4Window's root view controller. 
 
 The C4CanvasController is a subclass of UIViewController and is the principle object within C4 in which programmers will set up and control their applications.
 
 @warning *Note:* When programming a C4 project the canvasController is preset. This shouldn't change unless the entire project structure is changing.
  */
@property (readwrite, atomic, strong) C4CanvasController *canvasController;

#pragma mark New Stuff

/** The width of the receiver's frame.
 */
@property (readonly, nonatomic) CGFloat width;

/** The height of the receiver's frame.
 */
@property (readonly, nonatomic) CGFloat height;

/** A method to remove another object from its subviews.
 
 For the object in question, use this method to remove any visible object that was previously added to it as a subview.
 
 @param visibleObject the visible object to remove from its parent view
 */
-(void)removeObject:(C4Control *)visibleObject;
@end
