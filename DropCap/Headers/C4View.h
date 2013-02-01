//
//  C4View.h
//  C4iOS
//
//  Created by Travis Kirton on 12-02-14.
//  Copyright (c) 2012 POSTFL. All rights reserved.
//

#import <UIKit/UIKit.h>
/** The C4View is a subclass of UIView, which defines a rectangular area on the screen and the interfaces for managing the content in that area. At runtime, a view object handles the rendering of any content in its area and also handles any interactions with that content. The C4View class itself provides basic behavior for filling its rectangular area with a background color.
 
 Because view objects are the main way your application interacts with the user, they have a number of responsibilities. Here are just a few:
 
 You should never have to construct a C4View yourself. Instead, choose the appropriate C4 object and work from there.

 C4Views conform to the C4Notification protocol which means that all views will have the ability to post and receive notifications. Furthermore, C4View defines basic methods that deal with basic animations for the following properties:
 
 @property center
 @property frame
 @property bounds
 @property transform
 @property alpha
 @property backgroundColor
 @property contentStretch
 
 @warning *Note:* For more information on the above properties, consult the UIView class documentation.
 
 C4Views also have a custom animation options property which allows for setting of basic characteristics such as AUTOREVERSE, REPEAT, as well as delays and durations. These properties are:
 
 @property animationDelay
 @property animationDuration
 @property animationOptions

*/
@interface C4View : UIView <C4MethodDelay, C4Notification, C4AddSubview> {
}

@property (nonatomic) CGPoint origin;

#pragma mark Animation Properties
/// @name Configuring A View's Animation Properties

/** The duration of the view's animations, measured in seconds.
 
 All animations that occur will use this value as their duration.
 
 For immediate animations set this property to 0.0f;
 
 Defaults to 0.0f;
 */
@property (atomic) CGFloat animationDuration;

/** The time to wait before the view's animations begin, measured in seconds.
 
 A value in seconds for the length that a view should wait before it triggers its animations.

 All animations that occur will use this value as their delay.
 
 For immediate animations set this property to 0.0f;
 
 Defaults to 0.0f;
 */
@property (atomic) CGFloat animationDelay;

/** The options for which the view should use in its animations.

 An integer which can be constructed from bitmasked values.
 
 The available animation options are a limited subset of UIViewAnimationOptions and include:
 - ALLOWSINTERACTION
 - BEGINCURRENT (default)
 - REPEAT
 - AUTOREVERSE
 - EASEINOUT
 - EASEIN
 - EASEOUT
 - LINEAR 
 
 This value can have a variety of options attached to it by using integer bitmasks. For example, to set an animation which will auto reverse and repeat:
 view.animationOptions = AUTOREVERSE | REPEAT;
 
 @warning *Note:* All animation options should be set at the same time using the | bitmask operator. Animation options should never be set in the following way:
 view.animationOptions = AUTOREVERSE;
 view.animationOptions = REPEAT;
 */
@property (nonatomic) NSUInteger animationOptions;

/** The number of times an animation autorepeats.
 
 @warning *Note:* This parameter is currently unused.
  */
@property (nonatomic) CGFloat repeatCount;

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
