//
//  STHTCheckTVC.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/16/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STHTLap.h"
#import <STManagedTracker/STSessionManager.h>

@interface STHTCheckTVC : UITableViewController

@property (nonatomic, strong) STHTLap *lap;
@property (nonatomic, strong) STSession *session;

@end
