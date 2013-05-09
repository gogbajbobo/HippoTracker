//
//  STHTImage.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/9/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STHTDatum.h"


@interface STHTImage : STHTDatum

@property (nonatomic, retain) NSData * imageData;

@end
