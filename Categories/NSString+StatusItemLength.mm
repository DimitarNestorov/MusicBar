#import <AppKit/AppKit.h>

#import "NSString+StatusItemLength.h"

static NSFont *font = [NSFont systemFontOfSize:14.0f];

static NSDictionary *createAttributes() {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle.defaultParagraphStyle mutableCopy];
    [paragraphStyle setLineSpacing:1];
    paragraphStyle.lineHeightMultiple = 1.0f;

    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentNatural;
    return @{
        NSFontAttributeName: font,
        NSParagraphStyleAttributeName: paragraphStyle,
    };
}

static NSDictionary *attributes = createAttributes();

@implementation NSString (StatusItemLength)

- (CGFloat)statusItemLengthWithSelf {
    if (self.length <= 0) return 0;

    CGSize expectedLabelSize = [self boundingRectWithSize:CGSizeMake(FLT_MAX, 22)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil].size;
    
    return expectedLabelSize.width;
}

@end
