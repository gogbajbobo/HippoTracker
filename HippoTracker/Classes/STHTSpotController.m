//
//  STHTSpotController.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STHTSpotController.h"

@interface STHTSpotController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end

@implementation STHTSpotController

- (STHTSpot *)newSpot {
    STHTSpot *newSpot = (STHTSpot *)[NSEntityDescription insertNewObjectForEntityForName:@"STHTSpot" inManagedObjectContext:self.session.document.managedObjectContext];
    return newSpot;
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
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STHTSpot"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"label" ascending:NO selector:@selector(compare:)]];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
    }
    return _resultsController;
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
//                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
//                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
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
