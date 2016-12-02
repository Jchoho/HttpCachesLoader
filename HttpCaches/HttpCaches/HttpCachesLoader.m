//
//  HttpCachesLoader.m
//  HttpCaches
//
//  Created by Mia on 16/8/11.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import "HttpCachesLoader.h"
#import "MyAFNManager.h"
#import "FMDatabaseQueue+Tools.h"
#import "NSDate+LocalTime.h"

@interface HttpCachesLoader ()

/** 数据db */
@property (nonatomic,strong)FMDatabase *db;

/** 数据库队列 */
@property (nonatomic,strong)FMDatabaseQueue *queue;

/** 网络请求管理者 */
@property (nonatomic,strong)MyAFNManager *mgr;

@end

@implementation HttpCachesLoader

-(MyAFNManager *)mgr{
    return [MyAFNManager shareMyManager];
}

-(void)setup{
    //初始化缓冲有效期
    _timeLimit = MINUTE ;
    
    //打开数据库连接
    [_queue openDataBase];
    
    //创建缓冲数据库表
    [_queue createTable:@"HttpRequestCaches" columnDict:@{@"time":@"varchar(1000)",@"url":@"varchar(8000)",@"request":@"varchar(8000)", @"response":@"text"}];
}

-(void)dealloc{
    //关闭数据库连接
    [self.queue closeDataBase];
}

-(instancetype)init{
    if (self = [super init]) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"defaultHttpCaches.db"];
        NSLog(@"---默认数据库存放地址---:%@",path);
        _queue = [FMDatabaseQueue databaseQueueWithPath:path];
        [self setup];
    }
    return self;
}

+(instancetype)loaderDefault{
    HttpCachesLoader *loader = [[self alloc]init];
    return loader;
}

+(instancetype)loaderWithPath:(NSString *)path{
    HttpCachesLoader *loader = [[self alloc]initWithPath:path];
    return loader;
}

+(instancetype)loaderWithFMDatabaseQueue:(FMDatabaseQueue *)queue{
    HttpCachesLoader *loader = [[self alloc]initWithFMDatabaseQueue:queue];
    return loader;
}

-(instancetype)initWithPath:(NSString *)path{
    if (self = [super init]) {
        _queue = [FMDatabaseQueue databaseQueueWithPath:path];
        [self setup];
    }
    return self;
}

-(instancetype)initWithFMDatabaseQueue:(FMDatabaseQueue *)queue{
    if (self = [super init]) {
        _queue = queue;
        [self setup];
    }
    return self;
}

//对字典排序并返回组合成的字符串
-(NSString *)sortParameter:(NSDictionary *)dict{
    NSMutableArray *paraArrM = [NSMutableArray array];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        
        for (id nestedKey in [dict.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = dict[nestedKey];
            if (nestedValue) {
                [paraArrM addObject: [NSString stringWithFormat:@"%@=%@",nestedKey,dict[nestedKey]]];
            }
        }
        return [paraArrM componentsJoinedByString:@"&"];
    }
    
    return nil;
    
}



-(void)GET:(NSString *)url  parameters:(NSDictionary *)dict completion:(void(^)(id))block{
    [self loadData:url parameters:dict method:HttpRequestMethodGet immediately:NO completion:^(NSData * data){
        if (block) {
            if (data) {
                block([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]);
            }else{
                block(nil);
            }
        }
    }];
}

-(void)GET:(NSString *)url  parameters:(NSDictionary *)dict immediately:(BOOL)immediately completion:(void(^)(id))block{
    [self loadData:url parameters:dict method:HttpRequestMethodGet immediately:immediately completion:^(NSData * data) {
        if (block) {
            if (data) {
                block([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]);
            }else{
                block(nil);
            }
        }
    }];
}

-(void)POST:(NSString *)url  parameters:(NSDictionary *)dict completion:(void(^)(id))block{
    [self loadData:url parameters:dict method:HttpRequestMethodPost immediately:NO completion:^(NSData *data) {
        if (block) {
            if (data) {
                block([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]);
            }else{
                block(nil);
            }
        }
    }];
}

-(void)POST:(NSString *)url  parameters:(NSDictionary *)dict immediately:(BOOL)immediately completion:(void(^)(id))block{
    [self loadData:url parameters:dict method:HttpRequestMethodPost immediately:immediately completion:^(NSData *data) {
        if (block) {
            if (data) {
                block([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]);
            }else{
                block(nil);
            }
        }
    }];
}

-(void)loadData:(NSString *)url  parameters:(NSDictionary *)dict method:(HttpRequestMethod)method immediately:(BOOL)immediately completion:(void(^)(NSData *))block{
    
    //返回的NSData数据
    __block NSData *dataResult = nil;
    
    //拼接url和参数
    NSString *url_parameters = [NSString stringWithFormat:@"%@?%@",url,[self sortParameter:dict]];
    
    //根据url_parameters查找是否已经缓冲数据
    NSString *sqlSelect = [NSString stringWithFormat:@"select * from HttpRequestCaches where request = '%@'",url_parameters];
    
    __block BOOL isCaches = NO;
    __block BOOL isCachesTimeOut = NO;
   
    //重开数据库连接
    [self.queue restartDataBase];
    
    //先到数据查询是否有相应的记录
    [self.queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:sqlSelect];
        
        if ((isCaches =[result next])) {
   
            NSTimeInterval cachesInterval = [[NSDate localDate] timeIntervalSinceDate:[NSDate dateFromString:[result stringForColumn:@"time"]]];
                
            isCachesTimeOut = cachesInterval > self.timeLimit;
            
            if (!isCachesTimeOut) dataResult = [result dataForColumn:@"response"];

            [result close];
        }
    }];
    
    //数据操作
    NSString *sqlUpdateOrInsert;
    
    if (!isCaches) {
        //如果没有缓冲过，执行插入输入库操作
        sqlUpdateOrInsert = @"insert into HttpRequestCaches (time,response,url,request) values (?,?,?,?)";
        NSLog(@"没有缓冲过，执行插入输入库操作");
    }else{
        //如果缓冲没有超时，而且请求为immediately=NO的话，证明数据库中的缓冲还符合要求，取出结果返回。结束请求
        if (!immediately && !isCachesTimeOut) {
            if (block) {
                NSLog(@"缓冲没有超时，而且请求为immediately=NO的话，证明数据库中的缓冲还符合要求，取出结果返回。结束请求");
                block(dataResult);
            }
            return;
        }
        //如果缓冲过但是已经超时，或者请求为immediately=YES的话，执行跟新数据库操作
        sqlUpdateOrInsert = @"update HttpRequestCaches set time = ? ,response = ? ,url = ? where request = ?";
        NSLog(@"缓冲过但是已经超时，或者请求为immediately=YES的话，执行跟新数据库操作");
    }
    
    if (method == HttpRequestMethodGet) {//GET请求
        
        [self.mgr GET:url parameters:dict progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"---请求成功---%@",task.currentRequest.URL);
            NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
            [self.queue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:sqlUpdateOrInsert,[NSDate stringFromLocalDate],data,url,url_parameters];
            }];
            
            dataResult = data;
            if (block) {
                block(dataResult);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"---请求失败---%@",error);
            [self.queue inDatabase:^(FMDatabase *db) {
                FMResultSet *timeoutResult = [db executeQuery:sqlSelect];
                if ([timeoutResult next]) {
                    dataResult = [timeoutResult dataForColumn:@"response"];
                    [timeoutResult close];
                }
            }];
            if (block) {
                block(dataResult);
            }
        }];
        
    }else if(method == HttpRequestMethodPost){//POST请求
        
        [self.mgr POST:url parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"---请求成功---%@",task.currentRequest.URL);
            NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
            [self.queue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:sqlUpdateOrInsert,[NSDate stringFromLocalDate],data,url,url_parameters];
            }];
            dataResult = data;
            if (block) {
                block(dataResult);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"---请求失败---%@",error);
            [self.queue inDatabase:^(FMDatabase *db) {
                FMResultSet *timeoutResult = [db executeQuery:sqlSelect];
                if ([timeoutResult next]) {
                    dataResult = [timeoutResult dataForColumn:@"response"];
                    [timeoutResult close];
                }
                if (block) {
                    block(dataResult);
                }
            }];
        }];
        
    }
    
}


@end
