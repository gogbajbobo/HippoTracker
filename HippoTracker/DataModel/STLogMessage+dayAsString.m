//
//  STGTLogMessage+dayAsString.m
//  geotracker
//
//  Created by Maxim Grigoriev on 5/8/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STLogMessage+dayAsString.h"

@implementation STLogMessage (dayAsString)

- (NSString *)dayAsString {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy/MM/dd";
    });
    
    return [formatter stringFromDate:self.ts];
}


@end
