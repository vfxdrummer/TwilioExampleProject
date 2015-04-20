//
//  NSString+FocusCalling.m
//  FocusCalling
//
//  Created by Allen Wu on 11/13/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "NSString+FocusCalling.h"

@implementation NSString (FocusCalling)

- (BOOL)isNotBlank {
  return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
}

- (NSString *)trimWhitespace {
  return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
