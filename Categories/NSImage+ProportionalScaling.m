#import "NSImage+ProportionalScaling.h"

@implementation NSImage (ProportionalScaling)

- (NSImage*)imageByScalingProportionallyToSize:(NSSize)targetSize {
    NSImage* newImage = nil;
    
    if ([self isValid]) {
        NSSize imageSize = self.size;
        float width = imageSize.width;
        float height = imageSize.height;
        
        float targetWidth = targetSize.width;
        float targetHeight = targetSize.height;
        
        float scaleFactor = 0.0;
        float scaledWidth = targetWidth;
        float scaledHeight = targetHeight;
        
        NSPoint thumbnailPoint = NSZeroPoint;
        
        if (NSEqualSizes(imageSize, targetSize) == NO) {
            float widthFactor = targetWidth / width;
            float heightFactor = targetHeight / height;
            
            if (widthFactor < heightFactor) {
                scaleFactor = widthFactor;
            } else {
                scaleFactor = heightFactor;
            }

            scaledWidth = width * scaleFactor;
            scaledHeight = height * scaleFactor;
            
            if (widthFactor < heightFactor) {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            } else if (widthFactor > heightFactor) {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
        
        newImage = [[NSImage alloc] initWithSize:targetSize];
        
        [newImage lockFocus];
        
        [NSColor.windowBackgroundColor setFill];
        [NSBezierPath fillRect:NSMakeRect(0, 0, targetSize.width, targetSize.height)];
        
        NSRect thumbnailRect;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        
        [self drawInRect: thumbnailRect
                fromRect: NSZeroRect
               operation: NSCompositingOperationSourceOver
                fraction: 1.0];
        
        [newImage unlockFocus];
        
    }
    
    return newImage;
}

@end
