#import "ErrorReportingViewController.h"

#import "Constants.h"

@interface ErrorReportingViewController ()

@end

@implementation ErrorReportingViewController

- (IBAction)enableErrorReportingAction:(NSButton *)sender {
    [[NSUserDefaults new] setBool:YES forKey:EnableErrorReportingUserDefaultsKey];
    [self nextAction:sender];
}

- (IBAction)nextAction:(id)sender {
    NSPopover *popover = [self.view.window valueForKey:@"_popover"];
    popover.contentViewController = [[NSStoryboard storyboardWithName:@"Welcome Popover" bundle:nil] instantiateControllerWithIdentifier:@"Launch At Login"];
}

@end
