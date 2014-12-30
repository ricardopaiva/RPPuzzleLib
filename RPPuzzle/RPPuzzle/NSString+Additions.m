//
//  NSString+Additions.m
//  RPPuzzle
//
//  Created by Ricardo Paiva on 28/12/14.
//  Copyright (c) 2014 Ricardo Paiva. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

+ (NSString *)stringFromString:(NSString *)string characterAtIndex:(NSInteger)index
{
    unichar ch = [string characterAtIndex:index];
    return [NSString stringWithFormat:@"%C", ch];
}

@end
