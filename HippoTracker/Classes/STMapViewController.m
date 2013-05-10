//
//  STMapViewController.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMapViewController.h"

@interface STMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *firstPointButton;
@property (weak, nonatomic) IBOutlet UIButton *secondPointButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation STMapViewController

- (IBAction)firstPointButtonPressed:(id)sender {
    self.firstPointButton.enabled = NO;
    self.secondPointButton.enabled = YES;
    self.cancelButton.enabled = YES;
}

- (IBAction)secondPointButtonPressed:(id)sender {
}

- (IBAction)cancelButtonPressed:(id)sender {
    self.firstPointButton.enabled = YES;
    self.secondPointButton.enabled = NO;
    self.cancelButton.enabled = NO;
}

- (void)buttonInit {
    [self.firstPointButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.secondPointButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    self.secondPointButton.enabled = NO;
    self.cancelButton.enabled = NO;
}

- (void)mapInit {
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    CLLocationCoordinate2D center = self.mapView.centerCoordinate;
    MKCoordinateSpan span;
    span.longitudeDelta = 0.001;
    span.latitudeDelta = 0.001;
    [self.mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];
}

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
    [self buttonInit];
    [self mapInit];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    NSLog(@"secondPointButton.enabled %d", self.secondPointButton.enabled);
//    NSLog(@"cancelButton.enabled %d", self.cancelButton.enabled);
//    NSLog(@"cancelButton.alpha %f", self.cancelButton.alpha);
//}

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
