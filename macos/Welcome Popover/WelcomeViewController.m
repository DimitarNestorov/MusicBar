#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (IBAction)nextAction:(NSButton *)sender {
    NSPopover *popover = [self.view.window valueForKey:@"_popover"];
    popover.contentViewController = [[NSStoryboard storyboardWithName:@"Welcome Popover" bundle:nil] instantiateControllerWithIdentifier:@"Automatic Updates"];
}

@end
