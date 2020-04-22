#import "LicenseView.h"

static void commonInit(LicenseView *self) {
    NSData *data = [[NSDataAsset alloc] initWithName:@"License"].data;
    self.document = [[PDFDocument alloc] initWithData:data];
    self.scaleFactor = 1.4;
}

@implementation LicenseView

- (instancetype)init {
    self = [super init];
    if (self) commonInit(self);
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) commonInit(self);
    return self;
}

@end
