//
//  STGTLocationTracker.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTracker.h"
#import "STHTTrack.h"

@interface STHTLocationTracker : STTracker

- (void)startNewTrack;
- (void)deleteTrack:(STHTTrack *)track;
- (void)splitTrack;

@end
