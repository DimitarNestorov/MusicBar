@import Cocoa;

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (ProportionalScaling)

- (NSImage *)imageByScalingProportionallyToSize:(NSSize)targetSize __attribute__((warn_unused_result));

@end

NS_ASSUME_NONNULL_END
