#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (ProportionalScaling)

- (NSImage * _Nullable)imageByScalingProportionallyToSize:(NSSize)targetSize __attribute__((warn_unused_result));

@end

NS_ASSUME_NONNULL_END
