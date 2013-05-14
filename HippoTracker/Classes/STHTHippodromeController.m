//
//  STHTSpotController.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STHTHippodromeController.h"

@interface STHTHippodromeController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end

@implementation STHTHippodromeController

- (STHTHippodrome *)newHippodrome {
    STHTHippodrome *newHippodrome = (STHTHippodrome *)[NSEntityDescription insertNewObjectForEntityForName:@"STHTHippodrome" inManagedObjectContext:self.session.document.managedObjectContext];
    return newHippodrome;
}

- (void)saveChanges {
    [self.session.document saveDocument:^(BOOL success) {
        NSLog(@"save changes");
        if (success) {
            NSLog(@"save changes success");
        }
    }];
}

- (void)setSession:(id <STSession>)session {
    
    if (session != _session) {
        _session = session;
        self.resultsController = nil;
        NSError *error;
        if (![self.resultsController performFetch:&error]) {
            NSLog(@"performFetch error %@", error);
        } else {
            
        }
    }
    
}

- (NSFetchedResultsController *)resultsController {
    if (!_resultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STHTHippodrome"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"address" ascending:NO selector:@selector(compare:)]];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
    }
    return _resultsController;
}

#pragma mark - Table view data source & delegate

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
    
    static NSString *cellIdentifier = @"spotCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
    STHTHippodrome *hippodrome = (STHTHippodrome *)[[sectionInfo objects] objectAtIndex:indexPath.row];
    
    if (hippodrome.label) {
        cell.textLabel.text = hippodrome.label;
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    }
    if (hippodrome.address) {
        cell.detailTextLabel.text = hippodrome.address;
    } else {
        cell.detailTextLabel.text = @"no address";
    }

    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
        STHTHippodrome *hippodrome= (STHTHippodrome *)[[sectionInfo objects] objectAtIndex:indexPath.row];
        [self.session.document.managedObjectContext deleteObject:hippodrome];
    }

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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"spotControllerDidChangeContent" object:self];
    [self saveChanges];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //    NSLog(@"controller didChangeObject");
    
    if ([[self.session status] isEqualToString:@"running"]) {
        
        
        if (type == NSFetchedResultsChangeDelete) {
            
            //        NSLog(@"NSFetchedResultsChangeDelete");
            
//            if ([self.tableView numberOfRowsInSection:indexPath.section] == 1) {
//                [self.tableView reloadData];
//            } else {
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
//            }
            
        } else if (type == NSFetchedResultsChangeInsert) {
            
            //        NSLog(@"NSFetchedResultsChangeInsert");
            
//            [self.tableView reloadData];
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            
        } else if (type == NSFetchedResultsChangeUpdate) {
            
            //        NSLog(@"NSFetchedResultsChangeUpdate");
            
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            
        }
        
    }
}

@end
