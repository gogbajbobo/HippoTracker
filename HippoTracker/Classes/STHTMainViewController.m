//
//  STMainViewController.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/14/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STHTMainViewController.h"
#import "STSessionManager.h"
#import "STHTLapTracker.h"
#import "STHTSettingsTVC.h"
#import "STHTLapInfoVC.h"

@interface STHTMainViewController ()

@property (nonatomic, weak) IBOutlet UIButton *startTrackerButton;
@property (nonatomic, weak) IBOutlet UIButton *lapsHistoryButton;
@property (nonatomic, weak) IBOutlet UIButton *startNewLapButton;
@property (weak, nonatomic) IBOutlet UILabel *currentAccuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceFilterValueLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logButton;

@property (nonatomic, strong) STSession *session;

@end

@implementation STHTMainViewController

- (STSession *)session {
    if (!_session) {
        _session = [[STSessionManager sharedManager] currentSession];
    }
    return _session;
}

- (IBAction)logButtonPressed:(id)sender {
    UITableViewController *logTVC = [[UITableViewController alloc] init];
    logTVC.tableView.delegate = self.session.logger;
    logTVC.tableView.dataSource = self.session.logger;
    self.session.logger.tableView = logTVC.tableView;
    [self.navigationController pushViewController:logTVC animated:YES];
}

- (IBAction)settingsButtonPressed:(id)sender {
    STHTSettingsTVC *settingsTVC = [[STHTSettingsTVC alloc] init];
    settingsTVC.session = self.session;
    [self.navigationController pushViewController:settingsTVC animated:YES];
}

- (IBAction)startTrackerButtonPressed:(id)sender {
    STHTLapTracker *lapTracker = (STHTLapTracker *)self.session.locationTracker;
    if (!lapTracker.tracking) {
        [lapTracker startTracking];
        [self.startTrackerButton setTitle:@"STOP TRACKER" forState:UIControlStateNormal];
        [self currentAccuracyChanged:nil];
    } else {
        [lapTracker stopTracking];
        [self.startTrackerButton setTitle:@"START TRACKER" forState:UIControlStateNormal];
        self.startNewLapButton.enabled = NO;
        self.currentAccuracyLabel.text = @"Current accuracy: N/A";
        self.currentAccuracyLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    }
}

- (IBAction)lapsHistoryButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showLapsHistory" sender:self];
}

- (IBAction)startNewLapButtonPressed:(id)sender {
    STHTLapTracker *lapTracker = (STHTLapTracker *)self.session.locationTracker;
    if (!lapTracker.lapTracking) {
        self.startTrackerButton.enabled = NO;
        [self.startNewLapButton setTitle:@"FINISH LAP" forState:UIControlStateNormal];
        lapTracker.lapTracking = YES;
    } else {
        self.startTrackerButton.enabled = YES;
        self.startNewLapButton.frame = CGRectMake(20, 330, 280, 67);
        [self.startNewLapButton setTitle:@"START NEW LAP" forState:UIControlStateNormal];
        [[self.view viewWithTag:1] removeFromSuperview];
        [self.view setNeedsDisplay];
        [lapTracker finishLap];
    }
    
}

- (void)sessionStatusChanged:(NSNotification *)notification {
    if ([self.session.status isEqualToString:@"running"]) {
        self.startTrackerButton.enabled = YES;
        self.lapsHistoryButton.enabled = YES;
        self.settingsButton.enabled = YES;
        self.logButton.enabled = YES;
    }
}

- (void)currentAccuracyChanged:(NSNotification *)notification {
    [self setCurrentAccuracyText];
}

- (void)setCurrentAccuracyText {

    CLLocationAccuracy currentAccuracy = [(STHTLapTracker *)self.session.locationTracker currentAccuracy];
    CLLocationAccuracy requiredAccuracy = [[self.session.locationTracker.settings objectForKey:@"requiredAccuracy"] doubleValue];
    
    if (currentAccuracy == 0.0) {
        self.currentAccuracyLabel.text = @"Current accuracy: N/A";
    } else {
        self.currentAccuracyLabel.text = [NSString stringWithFormat:@"Current accuracy: %.fm", currentAccuracy];
    }
    
    if (currentAccuracy > 0.0 && currentAccuracy <= requiredAccuracy) {
        self.startNewLapButton.enabled = YES;
        self.currentAccuracyLabel.textColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    } else {
        if (![(STHTLapTracker *)self.session.locationTracker lapTracking]) {
            self.startNewLapButton.enabled = NO;
        }
        self.currentAccuracyLabel.textColor = [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0];
    }

}

- (void)lapTracking:(NSNotification *)notification {
    if ([(STHTLapTracker *)self.session.locationTracker lapTracking]) {
        self.distanceFilterValueLabel.text = @"-1";
    } else {
        self.distanceFilterValueLabel.text = [NSString stringWithFormat:@"%.f", [[[self.session.settingsController currentSettingsForGroup:@"location"] objectForKey:@"distanceFilter"] doubleValue]];
    }
}

- (void)stopDetected:(NSNotification *)notification {
    self.startTrackerButton.enabled = YES;
    [self.startNewLapButton setTitle:@"START NEW LAP" forState:UIControlStateNormal];
}

- (void)startNewLap:(NSNotification *)notification {
    [self addCurrentLapButton];
    [self performSegueWithIdentifier:@"showCurrentLap" sender:self];
}

- (void)addCurrentLapButton {
    self.startNewLapButton.frame = CGRectMake(20, 330, 220, 67);
    UIButton *currentLapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    currentLapButton.frame = CGRectMake(250, 330, 50, 67);
    [currentLapButton setTitle:@">>" forState:UIControlStateNormal];
    [currentLapButton addTarget:self action:@selector(currentLapButtonPressed:) forControlEvents:UIControlEventTouchDown];
    currentLapButton.tag = 1;
    [self.view addSubview:currentLapButton];
    [self.view setNeedsDisplay];
}

- (IBAction)currentLapButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showCurrentLap" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showCurrentLap"]) {
        if ([segue.destinationViewController isKindOfClass:[STHTLapInfoVC class]]) {
            STHTLapTracker *lapTracker = (STHTLapTracker *)self.session.locationTracker;
            [(STHTLapInfoVC *)segue.destinationViewController setLap:lapTracker.currentLap];
        }
    }
    
}


#pragma mark - view init

- (void)interfaceInit {
    [self.startTrackerButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.lapsHistoryButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.startNewLapButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    if (![self.session.status isEqualToString:@"running"]) {
        self.startTrackerButton.enabled = NO;
        self.lapsHistoryButton.enabled = NO;
        self.settingsButton.enabled = NO;
        self.logButton.enabled = NO;
        self.startNewLapButton.enabled = NO;
        self.currentAccuracyLabel.text = @"Current accuracy: N/A";
        self.currentAccuracyLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        self.distanceFilterValueLabel.text = @"";
    } else {
        self.startTrackerButton.enabled = YES;
        self.lapsHistoryButton.enabled = YES;
        self.settingsButton.enabled = YES;
        self.logButton.enabled = YES;
        self.startNewLapButton.enabled = YES;
        if ([self.session.locationTracker tracking]) {
            [self.startTrackerButton setTitle:@"STOP TRACKER" forState:UIControlStateNormal];
        }
        if ([(STHTLapTracker *)self.session.locationTracker lapTracking]) {
            self.startTrackerButton.enabled = NO;
            [self.startNewLapButton setTitle:@"FINISH LAP" forState:UIControlStateNormal];
            if ([(STHTLapTracker *)self.session.locationTracker currentLap]) {
                [self addCurrentLapButton];
            }
            self.distanceFilterValueLabel.text = @"-1";
        }
        [self setCurrentAccuracyText];
        self.distanceFilterValueLabel.text = [NSString stringWithFormat:@"%.f", [[[self.session.settingsController currentSettingsForGroup:@"location"] objectForKey:@"distanceFilter"] doubleValue]];
    }
}

- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentAccuracyChanged:) name:@"currentAccuracyChanged" object:self.session.locationTracker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDetected:) name:@"stopDetected" object:self.session.locationTracker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startNewLap:) name:@"startNewLap" object:self.session.locationTracker];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lapTracking:) name:@"locationSettingsChanged" object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lapTracking:) name:@"lapTracking" object:self.session.locationTracker];
}

- (void)removeNotificationsObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sessionStatusChanged" object:self.session];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"currentAccuracyChanged" object:self.session.locationTracker];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stopDetected" object:self.session.locationTracker];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startNewLap" object:self.session.locationTracker];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationSettingsChanged" object:self.session];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"lapTracking" object:self.session.locationTracker];
}

#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNotificationObservers];
    [self interfaceInit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        [self removeNotificationsObservers];
        self.view = nil;
    }

}

@end
