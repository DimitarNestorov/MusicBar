@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Debounce)

- (void)debounce:(SEL)action delay:(NSTimeInterval)delay;

@end

NS_ASSUME_NONNULL_END
