//
//  ShapedTextLabel.m
//  DropCap
//
//  Created by Travis Kirton on 13-01-31.
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
    //set up default variables
    //you can also set these in the main C4WorkSpace.m file, as they are all readwrite properties
    _text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam fringilla urna eu massa tincidunt nec viverra ipsum congue. Proin pellentesque, urna hendrerit fringilla viverra, dui mauris viverra nibh, ac feugiat eros erat in diam. Nullam dignissim ante a leo posuere molestie. Nulla nec magna sed velit elementum pulvinar. Aliquam ac nulla enim. Nullam quis nisl a erat fringilla rhoncus. Etiam molestie arcu at dolor iaculis pellentesque. Morbi at ultrices urna. Pellentesque tempus venenatis urna sed venenatis. Nam elementum augue id tellus vestibulum ac fermentum turpis dapibus.\n\tInteger pharetra nibh eu libero ultricies ut sagittis sapien volutpat. Nunc ut lacus libero, vel porttitor tellus. Mauris sed odio elit. Donec vitae nulla justo, vitae vulputate lacus. Donec eu tempus leo. Ut enim nisi, sollicitudin eget adipiscing a, elementum id erat. Cras egestas luctus justo, vel pellentesque justo imperdiet tincidunt. Ut ut enim purus, sed tincidunt tellus. Proin laoreet, eros eu sollicitudin hendrerit, mauris dui posuere elit, a pretium enim nulla sit amet neque.\n\tAliquam sit amet mauris dolor. Proin ut nisl eu orci semper iaculis. Nunc vitae mi enim. Pellentesque hendrerit facilisis ipsum, eget vestibulum mi lobortis a. Nulla in enim non arcu pharetra dapibus et vitae quam. Mauris pulvinar, nisl in cursus facilisis, ipsum leo iaculis eros, sit amet dignissim quam nibh nec nulla. Donec sollicitudin, ante sit amet dictum vulputate, dui tellus laoreet nisl, in egestas tellus ligula aliquet metus. Sed sit amet nisl eu elit vehicula interdum id non leo. Donec odio nisi, condimentum vel ultricies vitae, molestie sed odio. Sed rhoncus pretium condimentum. Praesent pellentesque viverra lacus, sed dignissim est laoreet non. Morbi convallis sollicitudin ornare. Fusce auctor convallis mollis.";
    _fontName = @"Avenir-Roman"; //can be any other ui font name (www.iosfonts.com)
    _dropCapFontSize = 60;
    _dropCapKernValue = 20;
    _textFontSize = 12;
    _textColor = [UIColor lightGrayColor];
    _textAlignment = NSTextAlignmentJustified;
}

- (void)drawRect:(CGRect)rect
{
    //make sure that all the variables exist and are non-nil
    NSAssert(_text != nil, @"text is nil");
    NSAssert(_textColor != nil, @"textColor is nil");
    NSAssert(_fontName != nil, @"fontName is nil");
    NSAssert(_dropCapFontSize > 0, @"dropCapFontSize is <= 0");
    NSAssert(_textFontSize > 0, @"textFontSize is <=0");
    
    //convert the text aligment from NSTextAligment to CTTextAlignment
    CTTextAlignment ctTextAlignment = NSTextAlignmentToCTTextAlignment(_textAlignment);
    
    //create a paragraph style
    CTParagraphStyleSetting paragraphStyleSettings[] = {
        {
            .spec = kCTParagraphStyleSpecifierAlignment,
            .valueSize = sizeof ctTextAlignment,
            .value = &ctTextAlignment
        }
    };
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(paragraphStyleSettings, sizeof paragraphStyleSettings / sizeof *paragraphStyleSettings);
    
    //create two fonts, with the same name but differing font sizes
    CTFontRef dropCapFontRef = CTFontCreateWithName((__bridge CFStringRef)_fontName, _dropCapFontSize, NULL);
    CTFontRef textFontRef = CTFontCreateWithName((__bridge CFStringRef)_fontName, _textFontSize, NULL);

    //create a dictionary of style elements for the drop cap letter
    NSDictionary *dropCapDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)dropCapFontRef, kCTFontAttributeName,
                                _textColor.CGColor, kCTForegroundColorAttributeName,
                                style, kCTParagraphStyleAttributeName,
                                @(_dropCapKernValue) , kCTKernAttributeName,
                                nil];
    //convert it to a CFDictionaryRef
    CFDictionaryRef dropCapAttributes = (__bridge CFDictionaryRef)dropCapDict;

    //create a dictionary of style elements for the main text body
    NSDictionary *textDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 (__bridge id)textFontRef, kCTFontAttributeName,
                                 _textColor.CGColor, kCTForegroundColorAttributeName,
                                 style, kCTParagraphStyleAttributeName,
                                 nil];
    //convert it to a CFDictionaryRef
    CFDictionaryRef textAttributes = (__bridge CFDictionaryRef)textDict;

    //clean up, because the dictionaries now have copies
    CFRelease(dropCapFontRef);
    CFRelease(textFontRef);
    CFRelease(style);
    
    //create an attributed string for the dropcap
    CFAttributedStringRef dropCapString = CFAttributedStringCreate(kCFAllocatorDefault,
                                                                   (__bridge CFStringRef)[_text substringToIndex:1],
                                                                   dropCapAttributes);
    
    //create an attributed string for the text body
    CFAttributedStringRef textString = CFAttributedStringCreate(kCFAllocatorDefault,
                                                                (__bridge CFStringRef)[_text substringFromIndex:1],
                                                                   textAttributes);
    
    //create an frame setter for the dropcap
    CTFramesetterRef dropCapSetter = CTFramesetterCreateWithAttributedString(dropCapString);

    //create an frame setter for the dropcap
    CTFramesetterRef textSetter = CTFramesetterCreateWithAttributedString(textString);
    
    //clean up
    CFRelease(dropCapString);
    CFRelease(textString);
    
    //get the size of the drop cap letter
    CFRange range;
    CGSize maxSizeConstraint = CGSizeMake(200.0f, 200.0f);
    CGSize dropCapSize = CTFramesetterSuggestFrameSizeWithConstraints(dropCapSetter, CFRangeMake(0, 1), dropCapAttributes, maxSizeConstraint, &range);
    
    //create the path that the main body of text will be drawn into
    //i create the path based on the dropCapSize, with some adjustments to tighten things up (done by eye)
    //to get some padding around the edges of the screen, you could go to +5 (x) and self.frame.size.width -5 (same for height)
    CGMutablePathRef textBox = CGPathCreateMutable();
    CGPathMoveToPoint(textBox, nil, dropCapSize.width, 0);
    CGPathAddLineToPoint(textBox, nil, dropCapSize.width, dropCapSize.height * 0.8); //adjustment because the dropCapSize is tall
    CGPathAddLineToPoint(textBox, nil, 0, dropCapSize.height * 0.8);
    CGPathAddLineToPoint(textBox, nil, 0, self.frame.size.height);
    CGPathAddLineToPoint(textBox, nil, self.frame.size.width, self.frame.size.height);
    CGPathAddLineToPoint(textBox, nil, self.frame.size.width, 0);
    CGPathCloseSubpath(textBox);
    
    //create a transform which will flip the CGContext into the same coordinate orientation as the UIView
    CGAffineTransform flipTransform = CGAffineTransformIdentity;
    flipTransform = CGAffineTransformTranslate(flipTransform, 0, self.bounds.size.height);
    flipTransform = CGAffineTransformScale(flipTransform, 1, -1);
    
    //invert the path for the text box
    CGPathRef invertedTextBox = CGPathCreateCopyByTransformingPath(textBox, &flipTransform);
    CFRelease(textBox);
    
    //create the CTFrame that will hold the main body of text
    CTFrameRef textFrame = CTFramesetterCreateFrame(textSetter, CFRangeMake(0, 0), invertedTextBox, NULL);
    CFRelease(invertedTextBox);
    CFRelease(textSetter);
    
    //create the drop cap text box, inverted already because we don't have to create an independent cgpathref (like above)
    CGPathRef dropCapTextBox = CGPathCreateWithRect(CGRectMake(_dropCapKernValue/2.0f, 0, dropCapSize.width, dropCapSize.height), &flipTransform);
    CTFrameRef dropCapFrame = CTFramesetterCreateFrame(dropCapSetter, CFRangeMake(0, 0), dropCapTextBox, NULL);
    CFRelease(dropCapTextBox);
    CFRelease(dropCapSetter);
    
    //draw the frames into our graphic context
    CGContextRef gc = UIGraphicsGetCurrentContext();
    CGContextSaveGState(gc); {
        CGContextConcatCTM(gc, flipTransform);
        CTFrameDraw(dropCapFrame, gc);
        CTFrameDraw(textFrame, gc);
    } CGContextRestoreGState(gc);
    CFRelease(dropCapFrame);
    CFRelease(textFrame);
}

#pragma mark SETTERS

//All of these have [self setNeedsDisplay] to force redrawing when they render
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
