//
//  STHTDatum.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/13/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface STDatum : NSManagedObject

@property (nonatomic, retain) NSDate * cts;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * lts;
@property (nonatomic, retain) NSDate * sqts;
@property (nonatomic, retain) NSDate * sts;
@property (nonatomic, retain) NSDate * ts;
@property (nonatomic, retain) NSData * xid;

@end
