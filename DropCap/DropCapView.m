//
//  ShapedTextLabel.m
//  DropCap
//
//  Created by moi on 13-01-31.
//  Copyright (c) 2013 moi. All rights reserved.
//

#import "DropCapView.h"

@implementation DropCapView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self != nil) {
        [self setup];
    }
    return self;
}

-(void)setup {
    _text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut nec lacus vel diam commodo facilisis non sit amet velit. Proin congue tellus non tellus vehicula mattis. Phasellus facilisis mollis pulvinar. Pellentesque vehicula leo at metus lobortis sed congue magna dictum. Suspendisse sem felis, congue vel euismod vel, bibendum vitae dui. In ac gravida ante. Maecenas lectus ligula, gravida id pharetra at, placerat ut sapien. Phasellus ac nisi elit. Maecenas id erat lorem. Phasellus vestibulum leo massa, in sodales dolor.";
    _fontName = @"Avenir-Roman"; //can be any other ui font name (www.iosfonts.com)
    _dropCapFontSize = 50;
    _dropCapKernValue = 20;
    _textFontSize = 12;
    _textColor = [UIColor darkGrayColor];
}

- (void)drawRect:(CGRect)rect
{
    NSAssert(_text != nil, @"text is nil");
    NSAssert(_textColor != nil, @"textColor is nil");
    NSAssert(_fontName != nil, @"fontName is nil");
    NSAssert(_dropCapFontSize > 0, @"dropCapFontSize is <= 0");
    NSAssert(_textFontSize > 0, @"textFontSize is <=0");
        
    CTTextAlignment textAlignment = [self adjustTextAlignment:self.textAlignment];
    
    CTParagraphStyleSetting paragraphStyleSettings[] = {
        {
            .spec = kCTParagraphStyleSpecifierAlignment,
            .valueSize = sizeof textAlignment,
            .value = &textAlignment
        }
    };
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(paragraphStyleSettings, sizeof paragraphStyleSettings / sizeof *paragraphStyleSettings);
    
    CTFontRef dropCapFontRef = CTFontCreateWithName((__bridge CFStringRef)_fontName, _dropCapFontSize, NULL);
    CTFontRef textFontRef = CTFontCreateWithName((__bridge CFStringRef)_fontName, _textFontSize, NULL);

//    CFMutableDictionaryRef dropCapAttributes = CFDictionaryCreateMutable(kCFAllocatorDefault, 3, nil, nil);
//    CFDictionaryAddValue(dropCapAttributes, kCTFontAttributeName, dropCapFontRef);
//    CFDictionaryAddValue(dropCapAttributes, kCTForegroundColorAttributeName, _textColor.CGColor);
//    CFDictionaryAddValue(dropCapAttributes, kCTParagraphStyleAttributeName, style);
    
    NSDictionary *dropCapDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)dropCapFontRef, kCTFontAttributeName,
                                _textColor.CGColor, kCTForegroundColorAttributeName,
                                style, kCTParagraphStyleAttributeName,
                                @(_dropCapKernValue) , kCTKernAttributeName,
                                nil];
    
    CFDictionaryRef dropCapAttributes = (__bridge CFDictionaryRef)dropCapDict;

    CFMutableDictionaryRef textAttributes = CFDictionaryCreateMutable(kCFAllocatorDefault, 3, nil, nil);
    CFDictionaryAddValue(textAttributes, kCTFontAttributeName, textFontRef);
    CFDictionaryAddValue(textAttributes, kCTForegroundColorAttributeName, _textColor.CGColor);
    CFDictionaryAddValue(textAttributes, kCTParagraphStyleAttributeName, style);

    CFRelease(dropCapFontRef);
    CFRelease(textFontRef);
    CFRelease(style);
    
    CFAttributedStringRef dropCapString = CFAttributedStringCreate(kCFAllocatorDefault,
                                                                   (__bridge CFStringRef)[_text substringToIndex:1],
                                                                   dropCapAttributes);
    
    CFAttributedStringRef textString = CFAttributedStringCreate(kCFAllocatorDefault,
                                                                (__bridge CFStringRef)[_text substringFromIndex:1],
                                                                   textAttributes);
    
    CTFramesetterRef dropCapSetter = CTFramesetterCreateWithAttributedString(dropCapString);

    CTFramesetterRef textSetter = CTFramesetterCreateWithAttributedString(textString);
    
    
    CGFloat maxWidth  = 100.0f;
    CGFloat maxHeight = 100.0f;
    CGSize constraint = CGSizeMake(maxWidth, maxHeight);
    
    CFRange range;
    CGSize dropCapSize = CTFramesetterSuggestFrameSizeWithConstraints(dropCapSetter, CFRangeMake(0, 1), dropCapAttributes, constraint, &range);
    
    // Core Text lays out text using the default Core Graphics coordinate system, with the origin at the lower left.  We need to compensate for that, both when laying out the text and when drawing it.
    CGAffineTransform textMatrix = CGAffineTransformIdentity;
    textMatrix = CGAffineTransformTranslate(textMatrix, 0, self.bounds.size.height);
    textMatrix = CGAffineTransformScale(textMatrix, 1, -1);

    CGMutablePathRef textBox = CGPathCreateMutable();
    CGPathMoveToPoint(textBox, nil, dropCapSize.width, 0);
    CGPathAddLineToPoint(textBox, nil, dropCapSize.width, dropCapSize.height * 0.8);
    CGPathAddLineToPoint(textBox, nil, 0, dropCapSize.height * 0.8);
    CGPathAddLineToPoint(textBox, nil, 0, self.frame.size.height * 0.8);
    CGPathAddLineToPoint(textBox, nil, self.frame.size.width, self.frame.size.height);
    CGPathAddLineToPoint(textBox, nil, self.frame.size.width, 0);
    CGPathCloseSubpath(textBox);
    
    CGPathRef invertedTextBox = CGPathCreateCopyByTransformingPath(textBox, &textMatrix);
    CTFrameRef textFrame = CTFramesetterCreateFrame(textSetter, CFRangeMake(0, 0), invertedTextBox, NULL);
    CFRelease(invertedTextBox);
    CFRelease(textSetter);
    
    CGPathRef dropCapTextBox = CGPathCreateWithRect(CGRectMake(_dropCapKernValue/2.0f, 0, dropCapSize.width, dropCapSize.height), &textMatrix);
    CTFrameRef dropCapFrame = CTFramesetterCreateFrame(dropCapSetter, CFRangeMake(0, 0), dropCapTextBox, NULL);
    CFRelease(dropCapTextBox);
    CFRelease(dropCapSetter);
    
    CGContextRef gc = UIGraphicsGetCurrentContext();
    CGContextSaveGState(gc); {
        CGContextConcatCTM(gc, textMatrix);
        CTFrameDraw(dropCapFrame, gc);
        CTFrameDraw(textFrame, gc);
    } CGContextRestoreGState(gc);
    CFRelease(dropCapFrame);
    CFRelease(textFrame);
}

-(CTTextAlignment)adjustTextAlignment:(NSTextAlignment)textAlignment {
    switch (textAlignment) {
        case NSTextAlignmentCenter:
            return kCTTextAlignmentCenter;
            break;
        case NSTextAlignmentJustified:
            return kCTTextAlignmentJustified;
            break;
        case NSTextAlignmentNatural:
            return kCTTextAlignmentNatural;
            break;
        case NSTextAlignmentRight:
            return kCTTextAlignmentRight;
            break;
        default:
            return kCTTextAlignmentLeft;
            break;
    }
}

#pragma mark SETTERS

-(void)setText:(NSString *)text {
    _text = [text copy];
    [self setNeedsDisplay];
}

-(void)setTextAlignment:(UITextAlignment)textAlignment {
    _textAlignment = textAlignment;
    [self setNeedsDisplay];
}

-(void)setDropCapFontSize:(CGFloat)dropCapFontSize {
    _dropCapFontSize = dropCapFontSize;
    [self setNeedsDisplay];
}

-(void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self setNeedsDisplay];
}

-(void)setTextFontSize:(CGFloat)textFontSize {
    _textFontSize = textFontSize;
    [self setNeedsDisplay];
}

-(void)setFontName:(NSString *)fontName {
    _fontName = fontName;
    [self setNeedsDisplay];
}

-(void)setPath:(UIBezierPath *)path {
    _path = path;
    [self setNeedsDisplay];
}
@end
