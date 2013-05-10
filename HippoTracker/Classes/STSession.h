//
//  STGTSession.h
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSessionManagement.h"
#import "STSessionManager.h"
#import "STManagedDocument.h"
#import "STSyncer.h"
#import "STHTLocationTracker.h"
#import "STHTSettings.h"
#import "STHTSettingsController.h"
#import "STLogger.h"
#import "STHTSpotController.h"

@interface STSession : NSObject <STSession>

@property (strong, nonatomic) STManagedDocument *document;
@property (strong, nonatomic) STSyncer *syncer;
@property (strong, nonatomic) STHTLocationTracker *locationTracker;
@property (weak, nonatomic) id <STSessionManager> manager;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *status;
@property (nonatomic, strong) id <STRequestAuthenticatable> authDelegate;
@property (nonatomic, strong) STHTSettingsController *settingsController;
@property (nonatomic, strong) STLogger *logger;
@property (nonatomic, strong) STHTSpotController *spotController;

+ (STSession *)initWithUID:(NSString *)uid authDelegate:(id <STRequestAuthenticatable>)authDelegate;
+ (STSession *)initWithUID:(NSString *)uid authDelegate:(id <STRequestAuthenticatable>)authDelegate settings:(NSDictionary *)settings;
- (void)completeSession;
- (void)dismissSession;
- (void)settingsLoadComplete;

@end
