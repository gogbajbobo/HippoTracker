//
//  STMainViewController.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/14/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STHTMainViewController.h"
#import "STSessionManager.h"
#import "STHTLapViewController.h"

@interface STHTMainViewController ()

@property (nonatomic, weak) IBOutlet UIButton *startTrackerButton;
@property (nonatomic, weak) IBOutlet UIButton *lapsHistoryButton;
@property (nonatomic, weak) IBOutlet UIButton *startNewLapButton;
@property (weak, nonatomic) IBOutlet UILabel *currentAccuracyLabel;
@property (nonatomic, strong) STSession *session;

@end

@implementation STHTMainViewController

- (STSession *)session {
    if (!_session) {
        _session = [[STSessionManager sharedManager] currentSession];
    }
    return _session;
}

- (IBAction)startTrackerButtonPressed:(id)sender {
    STHTLapTracker *lapTracker = self.session.lapTracker;
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
    
}

- (IBAction)startNewLapButtonPressed:(id)sender {
    
}

- (void)sessionStatusChanged:(NSNotification *)notification {
    if ([self.session.status isEqualToString:@"running"]) {
        self.startTrackerButton.enabled = YES;
    }
}

- (void)currentAccuracyChanged:(NSNotification *)notification {

    CLLocationAccuracy currentAccuracy = self.session.lapTracker.currentAccuracy;
    CLLocationAccuracy requiredAccuracy = [[self.session.lapTracker.settings objectForKey:@"requiredAccuracy"] doubleValue];
    
    if (currentAccuracy == 0.0) {
        self.currentAccuracyLabel.text = @"Current accuracy: N/A";
    } else {
        self.currentAccuracyLabel.text = [NSString stringWithFormat:@"Current accuracy: %.fm", currentAccuracy];
    }
    
    if (currentAccuracy > 0.0 && currentAccuracy <= requiredAccuracy) {
        self.startNewLapButton.enabled = YES;
        self.currentAccuracyLabel.textColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    } else {
        self.startNewLapButton.enabled = NO;
        self.currentAccuracyLabel.textColor = [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0];
    }

}

#pragma mark - view init

- (void)buttonsInit {
    [self.startTrackerButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.lapsHistoryButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.startNewLapButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    self.startTrackerButton.enabled = NO;
    self.lapsHistoryButton.enabled = NO;
    self.startNewLapButton.enabled = NO;
    self.currentAccuracyLabel.text = @"Current accuracy: N/A";
    self.currentAccuracyLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
}

- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentAccuracyChanged:) name:@"currentAccuracyChanged" object:self.session.lapTracker];
}

- (void)removeNotificationsObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sessionStatusChanged" object:self.session];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"currentAccuracyChanged" object:self.session.lapTracker];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNotificationObservers];
    [self buttonsInit];
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
