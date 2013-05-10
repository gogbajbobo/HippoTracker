//
//  STHTLogMessage.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STHTDatum.h"


@interface STHTLogMessage : STHTDatum

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * type;

@end
