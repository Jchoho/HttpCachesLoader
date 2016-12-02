//
//  NSDate+LocalTime.m
//  HttpCaches
//
//  Created by Mia on 16/8/10.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import "NSDate+LocalTime.h"

@implementation NSDate (LocalTime)




/**
 *  将日期转换为当前时区的日期
 *
 *  @param forDate 要转换的日期
 *
 *  @return 转换过的日期
 */
+ (NSDate *)convertDateToLocalTime: (NSDate *)forDate {
    
    NSTimeZone *nowTimeZone = [NSTimeZone localTimeZone];
    NSInteger timeOffset = [nowTimeZone secondsFromGMTForDate:forDate];
    NSDate *newDate = [forDate dateByAddingTimeInterval:timeOffset];
    return newDate;
}


+(NSDate *)localDate{
    return [self convertDateToLocalTime:[NSDate date]];
}

+(NSString *)stringFromLocalDate{
    return [[self date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

/**
 *  通过format格式将当前日期转换为String格式
 *
 *  @param format 格式样式
 *
 *  @return 转换后得到的String
 */
- (NSString *) stringWithFormat: (NSString *) format {
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = format;
    
    return [formatter stringFromDate:self];
}


//把时间字符串转化成NSDate 注意时区不同
+ (NSDate *) dateFromString: (NSString *)dateString{
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date=[formatter dateFromString:dateString];
    
    NSTimeZone *zome = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zome secondsFromGMTForDate: date];
    
    return [date  dateByAddingTimeInterval: interval];
}
@end
