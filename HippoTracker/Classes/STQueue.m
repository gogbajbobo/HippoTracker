//
//  STQueue.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/18/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STQueue.h"

@interface STQueue()

@property (nonatomic, strong) NSMutableArray *backStore;

@end


@implementation STQueue

@synthesize queueLength = _queueLength;
@synthesize backStore = _backStore;

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
//    NSLog(@"anObject %@", anObject);
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

- (void)clear {
    [self removeAllObjects];
}


#pragma mark - override NSMutableArray methods

- (id) init
{
    self = [super init];
    if (self != nil) {
        self.backStore = [NSMutableArray new];
    }
    return self;
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [self.backStore insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.backStore removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject {
    [self.backStore addObject:anObject];
}

- (void)removeLastObject {
    [self.backStore removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [self.backStore replaceObjectAtIndex:index withObject:anObject];
}

- (NSUInteger)count {
    return [self.backStore count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self.backStore objectAtIndex:index];
}

@end
