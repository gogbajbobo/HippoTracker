//
//  STGTSessionManager.h
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSessionManagement.h"
#import "STRequestAuthenticatable.h"
#import "STSession.h"

@interface STSessionManager : NSObject <STSessionManager>


@property (nonatomic, strong) NSMutableDictionary *sessions;
@property (nonatomic, strong) NSString *currentSessionUID;
@property (nonatomic, strong) id <STSession> currentSession;

- (void)startSessionForUID:(NSString *)uid authDelegate:(id <STRequestAuthenticatable>)authDelegate;
- (void)startSessionForUID:(NSString *)uid authDelegate:(id <STRequestAuthenticatable>)authDelegate settings:(NSDictionary *)settings;
- (void)stopSessionForUID:(NSString *)uid;
- (void)sessionCompletionFinished:(id <STSession>)session;
- (void)cleanCompletedSessions;
- (void)removeSessionForUID:(NSString *)uid;

+ (STSessionManager *)sharedManager;


@end
