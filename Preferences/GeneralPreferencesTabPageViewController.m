#import "GeneralPreferencesTabPageViewController.h"

#import "UserDefaultsKeys.h"

#import "PreferencesCheckbox.h"
#import "PreferencesPopUpButton.h"

@interface GeneralPreferencesTabPageViewController ()

@property (strong) IBOutlet NSUserDefaults *userDefaults;

@property (weak) IBOutlet PreferencesCheckbox *showArtistCheckbox;
@property (weak) IBOutlet PreferencesCheckbox *showTitleCheckbox;
@property (weak) IBOutlet PreferencesCheckbox *showAlbumCheckbox;
@property (weak) IBOutlet PreferencesCheckbox *hideTextWhenPausedCheckbox;
@property (weak) IBOutlet PreferencesCheckbox *enableErrorReportingCheckbox;
@property (weak) IBOutlet PreferencesPopUpButton *iconPopUpButton;
@property (weak) IBOutlet PreferencesPopUpButton *iconWhilePlayingPopUpButton;

@property (weak) IBOutlet NSSlider *maximumWidthSlider;

@end

@implementation GeneralPreferencesTabPageViewController

- (void)setupCheckbox:(PreferencesCheckbox *)checkbox userDefaultsKey:(NSString *)key {
    checkbox.userDefaultsKey = key;
    checkbox.state = [self.userDefaults boolForKey:key] ? NSControlStateValueOn : NSControlStateValueOff;
}

- (void)setupPopUpBox:(PreferencesPopUpButton *)popUpButton userDefaultsKey:(NSString *)key {
    popUpButton.userDefaultsKey = key;
    NSString *currentValue = [self.userDefaults stringForKey:key];
    [popUpButton selectItemWithTitle:currentValue.length == 0 ? @"None" : currentValue];
}

#pragma mark - View controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCheckbox:self.showArtistCheckbox userDefaultsKey:ShowArtistUserDefaultsKey];
    [self setupCheckbox:self.showTitleCheckbox userDefaultsKey:ShowTitleUserDefaultsKey];
    [self setupCheckbox:self.showAlbumCheckbox userDefaultsKey:ShowAlbumUserDefaultsKey];
    [self setupCheckbox:self.hideTextWhenPausedCheckbox userDefaultsKey:HideTextWhenPausedUserDefaultsKey];
    [self setupCheckbox:self.enableErrorReportingCheckbox userDefaultsKey:EnableErrorReportingUserDefaultsKey];
    [self setupPopUpBox:self.iconPopUpButton userDefaultsKey:IconUserDefaultsKey];
    [self setupPopUpBox:self.iconWhilePlayingPopUpButton userDefaultsKey:IconWhilePlayingUserDefaultsKey];
    
    NSInteger maximumWidth = [self.userDefaults integerForKey:MaximumWidthUserDefaultsKey];
    self.maximumWidthSlider.integerValue = maximumWidth;
}

#pragma mark - Actions

- (IBAction)booleanAction:(PreferencesCheckbox *)sender {
    [self.userDefaults setBool:sender.state == NSControlStateValueOn forKey:sender.userDefaultsKey];
}

- (IBAction)popUpBoxAction:(PreferencesPopUpButton *)sender {
    NSString *currentValue = sender.selectedItem.title;
    [self.userDefaults setObject:[currentValue compare:@"None"] == NSOrderedSame ? @"" : currentValue
                          forKey:sender.userDefaultsKey];
}

- (IBAction)maximumWidthSliderAction:(NSSlider *)sender {
    [self.userDefaults setInteger:sender.integerValue forKey:MaximumWidthUserDefaultsKey];
}

@end
