//
//  STHTSpotImage.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/9/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STHTImage.h"

@class STHTSpot;

@interface STHTSpotImage : STHTImage

@property (nonatomic, retain) STHTSpot *spot;

@end
