//
//  STHTAuthBasic.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/20/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UDPushAuth/UDOAuthBasicAbstract.h>
#import "STRequestAuthenticatable.h"

@interface STHTAuthBasic : UDOAuthBasicAbstract <STRequestAuthenticatable>

- (NSString *) reachabilityServer;
+ (id) tokenRetrieverMaker;


@end
