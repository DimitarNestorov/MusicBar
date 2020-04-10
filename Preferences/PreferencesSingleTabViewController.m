#import "PreferencesSingleTabViewController.h"

@interface PreferencesSingleTabViewController ()

@end

@implementation PreferencesSingleTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
}

- (IBAction)githubButtonAction:(NSButton *)sender {
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"https://github.com/dimitarnestorov/MusicBar"]];
}

@end
