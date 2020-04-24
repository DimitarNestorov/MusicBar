#import <objc/runtime.h>

#import "CustomMutableURLRequest.h"

@implementation CustomMutableURLRequest

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if ([@"Accept" isEqualToString:field]) {
        [super setValue:@"application/vnd.github.v3.raw" forHTTPHeaderField:field];
    } else {
        [super setValue:value forHTTPHeaderField:field];
    }
}

- (id)mutableCopy {
    id copy = [super mutableCopy];
    object_setClass(copy, [CustomMutableURLRequest class]);
    return copy;
}

@end
