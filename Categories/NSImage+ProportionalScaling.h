@import Cocoa;

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (ProportionalScaling)

- (NSImage*)imageByScalingProportionallyToSize:(NSSize)targetSize;

@end

NS_ASSUME_NONNULL_END
