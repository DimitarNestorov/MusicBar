@import Cocoa;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [[[NSUserDefaults alloc] init] registerDefaults:[NSDictionary dictionaryWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"DefaultPreferences" withExtension:@"plist"]]];
    }
    return NSApplicationMain(argc, argv);
}
