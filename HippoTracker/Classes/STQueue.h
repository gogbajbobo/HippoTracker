//
//  STQueue.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/18/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STQueue : NSMutableArray

@property (nonatomic) NSInteger queueLength;
@property (nonatomic) BOOL filled;

- (id)enqueue:(id)anObject;
- (id)head;
- (id)tail;
- (void)clear;

@end
