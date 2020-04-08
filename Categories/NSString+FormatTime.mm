#import "NSString+FormatTime.h"

static NSDateFormatter *createFormatter(BOOL withHours) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:withHours ? @"H:m:ss" : @"m:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return formatter;
}

static NSDateFormatter *formatterWithHours = createFormatter(YES);
static NSDateFormatter *formatterWithoutHours = createFormatter(NO);

@implementation NSString (FormatTime)

+ (NSString *)formatSeconds:(NSNumber *)seconds {
    if (seconds == nil) {
        return @"0:00";
    }
    
    return [NSString formatSecondsWithDouble:[seconds doubleValue]];
}

+ (NSString *)formatSecondsWithDouble:(double)seconds {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    unsigned long hours = seconds / 3600;
    NSDateFormatter *formatter = hours > 0 ? formatterWithHours : formatterWithoutHours;
    
    return [formatter stringFromDate:date];
}

@end
