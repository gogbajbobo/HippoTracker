//
//  STMainViewController.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMainViewController.h"
#import "STMapViewController.h"
#import "STHTHippodromeController.h"
#import "STTracker.h"
#import "STSession.h"

@interface STMainViewController ()

@property (nonatomic, strong) STSession *currentSession;
@property (weak, nonatomic) IBOutlet UILabel *currentAccuracyLabel;

@end

@implementation STMainViewController


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"newSpot"]) {
        if ([segue.destinationViewController isKindOfClass:[STMapViewController class]]) {
//            STHTHippodrome *newHippodrome = [self.currentSession.hippodromeController newHippodrome];
//            [(STMapViewController *)segue.destinationViewController set:newHippodrome];
        }
    } else if ([segue.identifier isEqualToString:@"showSpotTVC"]) {
//        if ([segue.destinationViewController isKindOfClass:[STHTSpotTVC class]]) {
//            STHTSpotTVC *spotTVC = segue.destinationViewController;
//            spotTVC.tableView.delegate = self.currentSession.spotController;
//            spotTVC.tableView.dataSource = self.currentSession.spotController;
//            self.currentSession.spotController.tableView = spotTVC.tableView;
//        }

    } else if ([segue.identifier isEqualToString:@"showMap"]) {
        if ([segue.destinationViewController isKindOfClass:[STMapViewController class]]) {
            STMapViewController *mapVC = segue.destinationViewController;
            mapVC.session = self.currentSession;
        }
        
    }
    
}

- (STSession *)currentSession {
    return [[STSessionManager sharedManager] currentSession];
}

- (void)currentAccuracyChanged:(NSNotification *)notification {
    CLLocationAccuracy currentAccuracy = [[notification.userInfo objectForKey:@"currentAccuracy"] doubleValue];
    self.currentAccuracyLabel.text = [NSString stringWithFormat:@"Current accuracy: %.fm", currentAccuracy];
    if (currentAccuracy <= 10) {
        self.currentAccuracyLabel.textColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1];
    } else {
        self.currentAccuracyLabel.textColor = [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1];
    }
}

- (void)checkHippodrome {
    if (!self.currentSession.lapTracker.hippodrome) {
        [self performSegueWithIdentifier:@"showMap" sender:self];
    }
}

#pragma mark - notifications

- (void)addNotificationsObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentAccuracyChanged:) name:@"currentAccuracyChanged" object:self.currentSession.lapTracker];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"currentAccuracyChanged" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:_currentAccuracy] forKey:@"currentAccuracy"]];

}

- (void)removeNotificationsObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"currentAccuracyChanged" object:self.currentSession.lapTracker];
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
    [self addNotificationsObservers];
    [self checkHippodrome];
	// Do any additional setup after loading the view.
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
