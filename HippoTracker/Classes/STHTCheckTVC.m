//
//  STHTCheckTVC.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/16/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STHTCheckTVC.h"
#import <CoreData/CoreData.h>
#import "STHTLocation.h"

@interface STHTCheckTVC () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) NSMutableDictionary *overallTimes;
@property (nonatomic, strong) NSMutableDictionary *overallDistances;

@end

@implementation STHTCheckTVC


- (NSFetchedResultsController *)resultsController {
    if (!_resultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STHTLocation"];
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
        
    }
}





- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.overallDistances = [NSMutableDictionary dictionary];
    self.overallTimes = [NSMutableDictionary dictionary];
    [self performFetch];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"checkCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
    STHTLocation *location = (STHTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row];
    
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 24)];
    
    if (indexPath.row == 0) {
        firstLabel.text = @"t";
    } else {
        STHTLocation *previousLocation = (STHTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row-1];
        NSTimeInterval timeInterval = [previousLocation.timestamp timeIntervalSinceDate:location.timestamp];
        firstLabel.text = [NSString stringWithFormat:@"%.2f", timeInterval];
    }
    
    UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 80, 24)];
    if (indexPath.row == 0) {
        secondLabel.text = @"ot";
    } else {
        
        secondLabel.text = [NSString stringWithFormat:@"%.2f", [self overallTimeFor:indexPath]];
    }

    UILabel *thirdLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 80, 24)];
    if (indexPath.row == 0) {
        thirdLabel.text = @"d";
    } else {
        STHTLocation *previousLocation = (STHTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row-1];
        CLLocation *loc = [self locationFromLocationObject:location];
        CLLocation *prevLoc = [self locationFromLocationObject:previousLocation];
        CLLocationDistance distance = [loc distanceFromLocation:prevLoc];
        thirdLabel.text = [NSString stringWithFormat:@"%.2f", distance];
    }

    UILabel *fourthLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 10, 100, 24)];
    if (indexPath.row == 0) {
        fourthLabel.text = @"od";
    } else {
        fourthLabel.text = [NSString stringWithFormat:@"%.2f", [self overallDistanceFor:indexPath]];
    }
    
    [cell.contentView addSubview:firstLabel];
    [cell.contentView addSubview:secondLabel];
    [cell.contentView addSubview:thirdLabel];
        [cell.contentView addSubview:fourthLabel];

    return cell;
}

- (NSTimeInterval)overallTimeFor:(NSIndexPath *)indexPath {
    NSNumber *result = [self.overallTimes valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    if (!result) {
        NSTimeInterval overallTime = 0;
        for (int i = 1; i <= indexPath.row; i++) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
            STHTLocation *location = (STHTLocation *)[[sectionInfo objects] objectAtIndex:i];
            STHTLocation *previousLocation = (STHTLocation *)[[sectionInfo objects] objectAtIndex:i-1];
            NSTimeInterval timeInterval = [previousLocation.timestamp timeIntervalSinceDate:location.timestamp];
            overallTime += timeInterval;
        }
        [self.overallTimes setValue:[NSNumber numberWithDouble:overallTime] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    }
    return [[self.overallTimes valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]] doubleValue];
}

- (CLLocationDistance)overallDistanceFor:(NSIndexPath *)indexPath {
    NSNumber *result = [self.overallDistances valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    if (!result) {
        CLLocationDistance overallDistance = 0;
        for (int i = 1; i <= indexPath.row; i++) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
            STHTLocation *location = (STHTLocation *)[[sectionInfo objects] objectAtIndex:i];
            STHTLocation *previousLocation = (STHTLocation *)[[sectionInfo objects] objectAtIndex:i-1];
            CLLocation *loc = [self locationFromLocationObject:location];
            CLLocation *prevLoc = [self locationFromLocationObject:previousLocation];
            CLLocationDistance distance = [loc distanceFromLocation:prevLoc];
            overallDistance += distance;
            [self.overallDistances setValue:[NSNumber numberWithDouble:overallDistance] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
        }
    }
    return [[self.overallDistances valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]] doubleValue];
}

- (CLLocation *)locationFromLocationObject:(STLocation *)locationObject {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([locationObject.latitude doubleValue], [locationObject.longitude doubleValue]);
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate
                                                         altitude:[locationObject.altitude doubleValue]
                                               horizontalAccuracy:[locationObject.horizontalAccuracy doubleValue]
                                                 verticalAccuracy:[locationObject.verticalAccuracy doubleValue]
                                                           course:[locationObject.course doubleValue]
                                                            speed:[locationObject.speed doubleValue]
                                                        timestamp:locationObject.timestamp];
    return location;
}





/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
