//
//  STHTLapInfoVC.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/15/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STHTLapInfoVC.h"
#import <STManagedTracker/STSessionManager.h>
#import "STHTLapCheckpoint.h"
#import "STHTLapTracker.h"
#import "STHTCheckTVC.h"

@interface STHTLapInfoVC () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lapDateLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkButton;
@property (weak, nonatomic) IBOutlet UIButton *lapButton;
@property (nonatomic, strong) NSString *lapInfo;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STSession *session;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation STHTLapInfoVC

- (STSession *)session {
    if (!_session) {
        _session = [[STSessionManager sharedManager] currentSession];
    }
    return _session;
}

- (NSFetchedResultsController *)resultsController {
    if (!_resultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STHTLapCheckpoint"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:NO selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF.lap == %@", self.lap];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
    }
    return _resultsController;
}

- (void)performFetch {
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"performFetch error %@", error);
    } else {
        [self.tableView reloadData];
    }
}

- (IBAction)checkButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showCheckTVC" sender:self];
}

- (IBAction)lapButtonPressed:(id)sender {
    if ([(STHTLapTracker *)self.session.locationTracker lapTracking]) {
        [(STHTLapTracker *)self.session.locationTracker finishLap];
        [self stopDetected:nil];
    } else {
        [self lapButtonWaitingStartDetection];
        [(STHTLapTracker *)self.session.locationTracker setLapTracking:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showCheckTVC"]) {
        if ([segue.destinationViewController isKindOfClass:[STHTCheckTVC class]]) {
            [(STHTCheckTVC *)segue.destinationViewController setLap:self.lap];
            [(STHTCheckTVC *)segue.destinationViewController setSession:self.session];
        }
    }
    
}

- (void)stopDetected:(NSNotification *)notification {
    [self.timer invalidate];
    self.timer = nil;
    [self lapButtonInit];
}

- (void)newLapStarted:(NSNotification *)notification {
    self.lap = [notification.userInfo objectForKey:@"currentLap"];
    self.resultsController = nil;
    [self performFetch];
    if (!self.timer) {
        [self timerInit];
    }
}

- (void)newLocationReceived:(NSNotification *)notification {
    CLLocation *lastLocation = [notification.userInfo objectForKey:@"lastLocation"];
    CLLocation *currentLocation = [notification.userInfo objectForKey:@"currentLocation"];
    CLLocationDistance checkpointDistance = [[notification.userInfo objectForKey:@"checkpointDistance"] doubleValue];
    CLLocationDistance distance = [currentLocation distanceFromLocation:lastLocation];
    NSTimeInterval time = [currentLocation.timestamp timeIntervalSinceDate:lastLocation.timestamp];
    CLLocationSpeed speed = 3.6 * distance / time;
    self.lapInfo = [NSString stringWithFormat:@"%.1fm %.fkm/h", checkpointDistance, speed];
}

- (void)lapButtonWaitingStartDetection {
    [self.lapButton setTitle:@"WAITING START" forState:UIControlStateNormal];
}

- (void)lapButtonShowLapInfo:(NSString *)lapInfo {
    [self.lapButton setTitle:lapInfo forState:UIControlStateNormal];
}

- (void)lapButtonInit {
    [self.lapButton setTitle:@"START NEW LAP" forState:UIControlStateNormal];
}

- (void)timerTick {
    NSTimeInterval timeFromStart = [[NSDate date] timeIntervalSinceDate:self.lap.startTime];
    NSString *info = [NSString stringWithFormat:@"%.1fs %@", timeFromStart, self.lapInfo];
    [self lapButtonShowLapInfo:info];
}

- (void)timerInit {
    self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:0.1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.resultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"lapInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
    STHTLapCheckpoint *checkpoint = (STHTLapCheckpoint *)[[sectionInfo objects] objectAtIndex:indexPath.row];
    
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 24)];
    
    distanceLabel.text = [NSString stringWithFormat:@"%.f", ([checkpoint.checkpointNumber intValue] +1) * [checkpoint.interval doubleValue]];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 10, 80, 24)];
    timeLabel.text = [NSString stringWithFormat:@"%.1f", [checkpoint.time doubleValue]];
    
    UILabel *speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 10, 100, 24)];
    speedLabel.text = [NSString stringWithFormat:@"%.f", [checkpoint.speed doubleValue]];
    
    [cell.contentView addSubview:distanceLabel];
    [cell.contentView addSubview:timeLabel];
    [cell.contentView addSubview:speedLabel];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleNone;
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
    
}



#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"controllerWillChangeContent");
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"controllerDidChangeContent");
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //    NSLog(@"controller didChangeObject");
    
    if (type == NSFetchedResultsChangeDelete) {
        
        //        NSLog(@"NSFetchedResultsChangeDelete");
        
    } else if (type == NSFetchedResultsChangeInsert) {
        
        //        NSLog(@"NSFetchedResultsChangeInsert");
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        //        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        //        NSLog(@"NSFetchedResultsChangeUpdate");
        
    }
    
}

- (NSString *)formatedLapDate {
    
    NSString *lapDate;
    if (self.lap.startTime) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        lapDate = [dateFormatter stringFromDate:self.lap.startTime];
    } else {
        lapDate = @"N/A";
    }
    return lapDate;
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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.lapDateLabel.text = [self formatedLapDate];

    if (self.lapButton) {
        [self.lapButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self addNotificationObservers];
        if ([(STHTLapTracker *)self.session.locationTracker lapTracking]) {
            self.lapInfo = @"0m 0km/h";
            [self timerInit];
        } else {
            [self lapButtonInit];
        }
    }

    [self performFetch];
}

- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newLocationReceived:) name:@"newLocation" object:self.session.locationTracker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newLapStarted:) name:@"startNewLap" object:self.session.locationTracker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDetected:) name:@"stopDetected" object:self.session.locationTracker];

}

- (void)removeNotificationsObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newLocation" object:self.session.locationTracker];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startNewLap" object:self.session.locationTracker];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stopDetected" object:self.session.locationTracker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        if (self.lapButton) {
            [self removeNotificationsObservers];
            [self.timer invalidate];
        }
        self.view = nil;
    }
}

@end
