//
//  STMainViewController.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMainViewController.h"
#import "STMapViewController.h"
#import "STHTSpotController.h"
#import "STHTSpotTVC.h"
#import "STTracker.h"
#import "STSession.h"

@interface STMainViewController ()

@property (nonatomic, strong) STSession *currentSession;

@end

@implementation STMainViewController


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"newSpot"]) {
        if ([segue.destinationViewController isKindOfClass:[STMapViewController class]]) {
            STHTSpot *newSpot = [self.currentSession.spotController newSpot];
            [(STMapViewController *)segue.destinationViewController setSpot:newSpot];
        }
    } else if ([segue.identifier isEqualToString:@"showSpotTVC"]) {
        if ([segue.destinationViewController isKindOfClass:[STHTSpotTVC class]]) {
            STHTSpotTVC *spotTVC = segue.destinationViewController;
            spotTVC.tableView.delegate = self.currentSession.spotController;
            spotTVC.tableView.dataSource = self.currentSession.spotController;
            self.currentSession.spotController.tableView = spotTVC.tableView;
        }

    }
    
}

- (STSession *)currentSession {
    return [[STSessionManager sharedManager] currentSession];
}

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
