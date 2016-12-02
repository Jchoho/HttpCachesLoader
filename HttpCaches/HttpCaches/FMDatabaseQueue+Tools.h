//
//  FMDatabaseQueue+Tools.h
//  HttpCaches
//
//  Created by Mia on 16/8/10.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import <FMDB/FMDB.h>

@interface FMDatabaseQueue (Tools)




/**
 *  重启Database
 *
 *  @return 成功重启返回YES，否则返回NO
 */
-(BOOL)restartDataBase;

/**
 *  打开queue里面的数据库
 *
 *  @return 成功打开返回YES ，否则返回NO
 */
-(BOOL)openDataBase;

/**
 *  关闭queue里面的数据库
 *
 *  @return 成功关闭返回YES ，否则返回NO
 */
-(BOOL)closeDataBase;


/**
 *  根据表名查询表的全部字段并返回
 *
 *  @param tableName 表名
 *
 *  @return 查询结果数组 firstObject 是 表的列名  secondObject 是 列的类型
 */
-(NSArray *)selectFromTable:(NSString *)tableName;


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
- (BOOL)createTable:(NSString *)tableName columnDict:(NSDictionary <NSString *,NSString *>*)columnDict;
@end
