//
//  NSDate+LocalTime.h
//  HttpCaches
//
//  Created by Mia on 16/8/10.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (LocalTime)

+ (NSDate *)convertDateToLocalTime: (NSDate *)forDate;

+(NSDate *)localDate;

+(NSString *)stringFromLocalDate;

-(NSString *)stringWithFormat: (NSString *) format;

+ (NSDate *) dateFromString: (NSString *)dateString;

@end
