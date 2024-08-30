#import "SettingsViewController.h"
#import "Settings.h"
#import "SwitchTableViewCell.h"

@interface SettingsViewController ()

@end

enum SettingsSection {
    SettingsSectionReportCrashes,
    SettingsSectionReportUsage,
    SettingsSectionCount
};

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SettingsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case SettingsSectionReportCrashes:
            return @"Anonymously send back crash information with minimal system data to AppCenter. No data is sent until a crash happens.";
        case SettingsSectionReportUsage:
            return @"Let NXBoot count how often it is used, and anonymously report successful or failed boot events to AppCenter.";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchTableViewCell" forIndexPath:indexPath];
    switch (indexPath.section) {
        case SettingsSectionReportCrashes:
            cell.customLabel.text = @"Allow crash reports";
            cell.customSwitch.on = Settings.allowCrashReports;
            [cell.customSwitch addTarget:self
                                  action:@selector(setAllowCrashReports:)
                        forControlEvents:UIControlEventTouchUpInside];
            break;
        case SettingsSectionReportUsage:
            cell.customLabel.text = @"Allow usage pings";
            cell.customSwitch.on = Settings.allowUsagePings;
            [cell.customSwitch addTarget:self
                                  action:@selector(setAllowUsagePings:)
                        forControlEvents:UIControlEventTouchUpInside];
            break;
    }
    return cell;
}

#pragma mark - Switch actions

- (void)setEnableCrashReports:(UISwitch *)sender {
    Settings.allowCrashReports = sender.on;
}

- (void)setEnableUsagePings:(UISwitch *)sender {
    Settings.allowUsagePings = sender.on;
}

@end
