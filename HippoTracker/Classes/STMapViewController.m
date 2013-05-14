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
@property (weak, nonatomic) IBOutlet UIButton *startLineButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *helpButton;
@property (nonatomic) BOOL startLineSetted;
@property (nonatomic, strong) STHTHippodrome *hippodrome;


@end

@implementation STMapViewController

- (IBAction)firstPointButtonPressed:(id)sender {
    self.firstPointButton.enabled = NO;
    self.secondPointButton.enabled = YES;
    self.cancelButton.enabled = YES;
    self.hippodrome.startLineLat1 = [NSNumber numberWithDouble:self.mapView.centerCoordinate.latitude];
    self.hippodrome.startLineLon1 = [NSNumber numberWithDouble:self.mapView.centerCoordinate.longitude];
}

- (IBAction)secondPointButtonPressed:(id)sender {
    self.firstPointButton.enabled = NO;
    self.secondPointButton.enabled = NO;
    self.cancelButton.enabled = NO;
    self.hippodrome.startLineLat2 = [NSNumber numberWithDouble:self.mapView.centerCoordinate.latitude];
    self.hippodrome.startLineLon2 = [NSNumber numberWithDouble:self.mapView.centerCoordinate.longitude];
    [self setSpotAddress];
    [self drawStartLine];
}

- (IBAction)cancelButtonPressed:(id)sender {
    self.firstPointButton.enabled = YES;
    self.secondPointButton.enabled = NO;
    self.cancelButton.enabled = NO;
    self.hippodrome.startLineLat1 = nil;
    self.hippodrome.startLineLon1 = nil;
}

- (IBAction)newStartLine:(id)sender {
    [self.mapView removeOverlays:self.mapView.overlays];
    self.startLineSetted = NO;
    [self buttonInit];
}

- (IBAction)helpButtonPressed:(id)sender {
    [self showInfo];
}

- (void)drawStartLine {
    CLLocationCoordinate2D coordinates[2];
    coordinates[0] = CLLocationCoordinate2DMake([self.hippodrome.startLineLat1 doubleValue], [self.hippodrome.startLineLon1 doubleValue]);
    coordinates[1] = CLLocationCoordinate2DMake([self.hippodrome.startLineLat2 doubleValue], [self.hippodrome.startLineLon2 doubleValue]);
    MKPolyline *startLine = [MKPolyline polylineWithCoordinates:coordinates count:2];
    startLine.title = @"startLine";
    [self.mapView insertOverlay:(id<MKOverlay>)startLine atIndex:self.mapView.overlays.count];
    self.startLineSetted = YES;
    [self buttonInit];
}

- (void)setSpotAddress {
    CLLocationDegrees longitude = ([self.hippodrome.startLineLon1 doubleValue] + [self.hippodrome.startLineLon2 doubleValue]) / 2;
    CLLocationDegrees latitude = ([self.hippodrome.startLineLat1 doubleValue] + [self.hippodrome.startLineLat2 doubleValue]) / 2;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        //            NSLog(@"placemarks %@", placemarks);
        if (error) {
            NSLog(@"error %@", error.localizedDescription);
        }
        CLPlacemark *place = [placemarks lastObject];
        NSLog(@"place.name %@", place.name);
        self.hippodrome.address = place.name;
    }];
}

- (void)buttonInit {
    if (!self.startLineSetted) {
        [self.startLineButton removeFromSuperview];
        
        self.firstPointButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.firstPointButton.frame = CGRectMake(20.0, 353.0, 98.0, 44.0);
        [self.firstPointButton addTarget:self action:@selector(firstPointButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [self.firstPointButton setTitle:@"1st point" forState:UIControlStateNormal];
        [self.firstPointButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        self.firstPointButton.enabled = YES;
        [self.view addSubview:self.firstPointButton];

        self.secondPointButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.secondPointButton.frame = CGRectMake(202.0, 353.0, 98.0, 44.0);
        [self.secondPointButton addTarget:self action:@selector(secondPointButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [self.secondPointButton setTitle:@"2nd point" forState:UIControlStateNormal];
        [self.secondPointButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        self.secondPointButton.enabled = NO;
        [self.view addSubview:self.secondPointButton];

        self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.cancelButton.frame = CGRectMake(126.0, 353.0, 68.0, 44.0);
        [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        self.cancelButton.enabled = NO;
        [self.view addSubview:self.cancelButton];
    } else {
        [self.firstPointButton removeFromSuperview];
        [self.secondPointButton removeFromSuperview];
        [self.cancelButton removeFromSuperview];
        
        self.startLineButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.startLineButton.frame = CGRectMake(20.0, 353.0, 280.0, 44.0);
        [self.startLineButton addTarget:self action:@selector(newStartLine:) forControlEvents:UIControlEventTouchDown];
        [self.startLineButton setTitle:@"New startline" forState:UIControlStateNormal];
        [self.startLineButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        self.startLineButton.enabled = YES;
        [self.view addSubview:self.startLineButton];
    }
}

- (void)mapInit {
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    self.mapView.mapType = MKMapTypeHybrid;
    CLLocationCoordinate2D center = self.mapView.centerCoordinate;
    MKCoordinateSpan span;
    span.longitudeDelta = 0.001;
    span.latitudeDelta = 0.001;
    [self.mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];
    self.mapView.delegate = self;
    double centerX = self.mapView.bounds.size.width / 2;
    double centerY = self.mapView.bounds.size.height / 2;
    UIView *hLine = [[UIView alloc] initWithFrame:CGRectMake(centerX-20, centerY, 40, 1)];
    hLine.backgroundColor = [UIColor blackColor];
    [self.mapView addSubview:hLine];
    UIView *vLine = [[UIView alloc] initWithFrame:CGRectMake(centerX, centerY-20, 1, 40)];
    vLine.backgroundColor = [UIColor blackColor];
    [self.mapView addSubview:vLine];
}

- (void)showInfo {
    UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:@"INFO" message:@"Info message" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [infoAlert show];
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
    [self mapInit];
    if (!self.session.lapTracker.hippodrome) {
        [self showInfo];
        self.hippodrome = [self.session.hippodromeController newHippodrome];
        self.startLineSetted = NO;
    } else {
        self.hippodrome = self.session.lapTracker.hippodrome;
        [self drawStartLine];
    }
    [self buttonInit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        self.view = nil;
    }
}

@end
