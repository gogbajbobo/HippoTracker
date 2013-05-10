//
//  STMapViewController.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMapViewController.h"

@interface STMapViewController () <MKMapViewDelegate>
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
    self.spot.latitude1 = [NSNumber numberWithDouble:self.mapView.centerCoordinate.latitude];
    self.spot.longitude1 = [NSNumber numberWithDouble:self.mapView.centerCoordinate.longitude];
}

- (IBAction)secondPointButtonPressed:(id)sender {
    self.firstPointButton.enabled = NO;
    self.secondPointButton.enabled = NO;
    self.cancelButton.enabled = NO;
    self.spot.latitude2 = [NSNumber numberWithDouble:self.mapView.centerCoordinate.latitude];
    self.spot.longitude2 = [NSNumber numberWithDouble:self.mapView.centerCoordinate.longitude];
    [self drawStartLine];
}

- (IBAction)cancelButtonPressed:(id)sender {
    self.firstPointButton.enabled = YES;
    self.secondPointButton.enabled = NO;
    self.cancelButton.enabled = NO;
    self.spot.latitude1 = nil;
    self.spot.longitude1 = nil;
}

- (void)drawStartLine {
    CLLocationCoordinate2D coordinates[2];
    coordinates[0] = CLLocationCoordinate2DMake([self.spot.latitude1 doubleValue], [self.spot.longitude1 doubleValue]);
    coordinates[1] = CLLocationCoordinate2DMake([self.spot.latitude2 doubleValue], [self.spot.longitude2 doubleValue]);
    MKPolyline *startLine = [MKPolyline polylineWithCoordinates:coordinates count:2];
    startLine.title = @"startLine";
    [self.mapView insertOverlay:(id<MKOverlay>)startLine atIndex:self.mapView.overlays.count];
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
    self.mapView.delegate = self;
}

#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineView *pathView = [[MKPolylineView alloc] initWithPolyline:overlay];
    if ([overlay.title isEqualToString:@"startLine"]) {
        pathView.strokeColor = [UIColor redColor];
        pathView.lineWidth = 4.0;
    }
    return pathView;
    
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
