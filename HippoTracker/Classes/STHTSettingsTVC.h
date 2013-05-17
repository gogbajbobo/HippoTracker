//
//  STHTSettingsTVC.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/17/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STManagedTracker/STSessionManagement.h>

@interface STHTSettingsTVC : UITableViewController

@property (nonatomic, strong) id <STSession> session;

@end


@interface STHTSettingsTableViewCell : UITableViewCell

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UISwitch *senderSwitch;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITextField *textField;


@end