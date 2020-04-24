#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FormatTime)

+ (NSString *)formatSeconds:(double)seconds __attribute__((warn_unused_result));

@end

NS_ASSUME_NONNULL_END
