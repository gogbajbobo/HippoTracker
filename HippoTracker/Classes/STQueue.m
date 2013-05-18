//
//  STQueue.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/18/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STQueue.h"

@implementation STQueue

@synthesize queueLength = _queueLength;

- (BOOL)filled {
    return (self.count >= self.queueLength);
}

-(NSInteger)queueLength {
    if (!_queueLength) {
        _queueLength = 4;
    }
    return _queueLength;
}

- (void)setQueueLength:(NSInteger)queueLength {
    if (queueLength > 1 && queueLength != _queueLength) {
        if (queueLength < self.count) {
            NSRange range;
            range.location = 0;
            range.length = self.count - queueLength;
            [self removeObjectsInRange:range];
        }
        _queueLength = queueLength;
    }
}

- (id)dequeue {
    id dequeueObject = [self head];
    if (dequeueObject) {
        [self removeObjectAtIndex:0];
    }
    return dequeueObject;
}

- (id)enqueue:(id)anObject {
    id dequeueObject = nil;
    if (anObject) {
        if (self.filled) {
            dequeueObject = [self dequeue];
        }
        [self addObject:anObject];
    }
    return dequeueObject;
}

- (id)head {
    if (self.count != 0) {
        return [self objectAtIndex:0];
    } else {
        return nil;
    }
}

- (id)tail {
    if (self.count != 0) {
        return [self lastObject];
    } else {
        return nil;
    }
}

@end
