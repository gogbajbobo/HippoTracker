//
//  STHTSpotController.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSessionManagement.h"
#import "STHTSpot.h"

@interface STHTSpotController : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) id <STSession> session;
@property (nonatomic, weak) UITableView *tableView;

- (STHTSpot *)newSpot;
- (void)saveChanges;

@end
