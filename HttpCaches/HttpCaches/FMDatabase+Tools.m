//
//  FMDatabase+Tools.m
//  HttpCaches
//
//  Created by Mia on 16/8/10.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import "FMDatabase+Tools.h"

@implementation FMDatabase (Tools)



-(BOOL)restart{
    return ([self close] && [self open]) ;
}
/**
 *  根据表名查询表的全部字段并返回
 *
 *  @param tableName 表名
 */
-(NSArray *)selectFromTable:(NSString *)tableName{
    //重新打开下数据库
    [self restart];
    
    NSMutableArray *resultArr = [NSMutableArray array];
    
    NSString *sqlSelect = [NSString stringWithFormat:@"select * from %@",tableName];
    NSString *sqlTableInfo = [NSString stringWithFormat:@" PRAGMA  table_info(%@)",tableName];
    
    NSMutableArray *columnName = [NSMutableArray array];
    NSMutableArray *columnTpye = [NSMutableArray array];
    
    FMResultSet *resultTableInfo = [self executeQuery:sqlTableInfo];
    
    while ([resultTableInfo next]) {
        [columnName addObject:[resultTableInfo stringForColumnIndex:1]];
        [columnTpye addObject:[resultTableInfo stringForColumnIndex:2]];
    }
    
    [resultArr addObject:columnName];
    [resultArr addObject:columnTpye];
    
    
    FMResultSet *resultSelect = [self executeQuery:sqlSelect];
    
    while ([resultSelect next]) {
        
        NSMutableArray *queryArr = [NSMutableArray array];
        
        for (int i = 0;i < columnTpye.count; i++) {
            
            NSString *type = columnTpye[i];
            
            if ([type containsString:@"int"]) {
                //int类型
                [queryArr addObject: @([resultSelect intForColumnIndex:i])?@([resultSelect intForColumnIndex:i]):@"NULL"];
            }else if([type containsString:@"double"] ||[type containsString:@"float"]){
                //float类型
                [queryArr addObject: [resultSelect doubleForColumnIndex:i]?@([resultSelect doubleForColumnIndex:i]):@"NULL"];
            }else if([type containsString:@"text"]){
                //NSData类型
                [queryArr addObject:[resultSelect dataForColumnIndex:i]?[resultSelect dataForColumnIndex:i]:@"NULL"];
            }else {
                //NSString类型
                [queryArr addObject:[resultSelect stringForColumnIndex:i]?[resultSelect stringForColumnIndex:i]:@"NULL"];
            }
            
        }
        
        [resultArr addObject:queryArr];
    }
    
    return resultArr;
    
}

//-(BOOL)insertToTable:(NSString *)tableName valuesArr:(NSArray *)valuesDict{
//    NSString *sqlStr1 = [NSString stringWithFormat:@" PRAGMA  table_info(%@)",tableName];
////    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)",
//    FMResultSet *result = [self.db executeQuery:sqlStr1];
//    while ([result next]) {
//        NSString *str0 = [result stringForColumnIndex:0];
//
//        NSLog(@"%@",str0);
//
//        NSString *str1 = [result stringForColumnIndex:1];
//
//        NSLog(@"%@",str1);
//    }
//    NSLog(@"%@",[self.db executeQuery:sqlStr1]) ;
//
//    return YES;
//}

//使用字典来插入数据
-(BOOL)insertToTable:(NSString *)tableName values:(NSDictionary *)valuesDict{
    NSArray *keyArr = [valuesDict allKeys];
    NSString *columnName = @"" ;
    NSString *columnValue = @"" ;
    for (NSString *key in keyArr) {
        columnName = [NSString stringWithFormat:@"%@ %@ ,",columnName,key];
        if ([valuesDict[key] isKindOfClass:[NSString class]]) {
            columnValue = [NSString stringWithFormat:@"%@ '%@' ,",columnValue,valuesDict[key]];
        }else{
            columnValue = [NSString stringWithFormat:@"%@ %@ ,",columnValue,valuesDict[key]];
        }
    }
    NSRange rang = [columnName rangeOfString:@"," options:NSBackwardsSearch];
    columnName = [columnName substringToIndex:rang.location];
    
    NSRange rang1 = [columnValue rangeOfString:@"," options:NSBackwardsSearch];
    columnValue = [columnValue substringToIndex:rang1.location];
    
    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)",tableName,columnName,columnValue];
    
    return [self executeUpdate:sqlStr];
}


/**
 *  根据参数创建表格
 *
 *  @param tableName  表名
 *  @param columnDict 字段的字典
 字段名  字段类型     字段名   字段类型           字段名  字段类型
 @{@"ccc":  @"num",  @"ccc1":@"varchar(10)",   @"ccc2":@"char"  };
 *
 *  @return 成功创建返回YES，否则返回NO
 */
- (BOOL)createTable:(NSString *)tableName columnDict:(NSDictionary <NSString *,NSString *>*)columnDict{
    NSString *sqlStr = [NSString stringWithFormat:@"create table if not exists %@",tableName];
    NSArray *keyArr = [columnDict allKeys];
    
    NSString *columnStr = @"";
    for (NSString *key in keyArr) {
        columnStr = [NSString stringWithFormat:@"%@ %@ %@ ,",columnStr,key,columnDict[key]];
    }
    NSRange rang = [columnStr rangeOfString:@"," options:NSBackwardsSearch];
    columnStr = [columnStr substringToIndex:rang.location];
    sqlStr = [NSString stringWithFormat:@"%@(%@);",sqlStr,columnStr];
    
    return [self executeUpdate:sqlStr];
}


@end
