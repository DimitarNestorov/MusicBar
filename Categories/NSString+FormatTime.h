#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FormatTime)

+ (NSString *)formatSeconds:(NSNumber *)seconds;
+ (NSString *)formatSecondsWithDouble:(double)seconds;

@end

NS_ASSUME_NONNULL_END
