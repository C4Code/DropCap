//
//  ShapedTextLabel.h
//  DropCap
//
//  Created by moi on 13-01-31.
//  Copyright (c) 2013 moi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropCapView : UIView
@property (nonatomic, copy) NSString *text;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) CGFloat dropCapFontSize, dropCapKernValue, textFontSize;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, copy) UIBezierPath *path;
@end
