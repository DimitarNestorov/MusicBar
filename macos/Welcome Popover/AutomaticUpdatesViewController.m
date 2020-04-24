#import "AutomaticUpdatesViewController.h"

#import "Constants.h"

@interface AutomaticUpdatesViewController ()

@end

@implementation AutomaticUpdatesViewController

- (IBAction)enableAutomaticUpdatesAction:(NSButton *)sender {
    [[NSUserDefaults new] setBool:YES forKey:EnableAutomaticUpdatesUserDefaultsKey];
    [self nextAction:sender];
}

- (IBAction)nextAction:(id)sender {
    NSPopover *popover = [self.view.window valueForKey:@"_popover"];
    popover.contentViewController = [[NSStoryboard storyboardWithName:@"Welcome Popover" bundle:nil] instantiateControllerWithIdentifier:@"Error Reporting"];
}

@end
