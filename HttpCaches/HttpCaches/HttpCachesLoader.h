//
//  HttpCachesLoader.h
//  HttpCaches
//
//  Created by Mia on 16/8/11.
//  Copyright © 2016年 Mia. All rights reserved.
//
@class FMDatabaseQueue;
#import <Foundation/Foundation.h>

#define MINUTE 60
#define HOUR 60*60
#define DAY HOUR*24
#define MONTH DAY*30
#define YEAR MONTH*12

typedef NS_ENUM(NSInteger , HttpRequestMethod) {
    HttpRequestMethodGet ,
    HttpRequestMethodPost
};

@interface HttpCachesLoader : NSObject


/** 缓冲有效期 单位:秒  默认1min*/
@property (nonatomic,assign)double timeLimit;

/**
 *  默认的类方法，会在沙河的caches路径创建一个数据库，并且建立一个存放缓冲的表HttpRequestCaches
 *
 *  @return 返回一个HttpCachesLoader对象
 */
+(instancetype)loaderDefault;


+(instancetype)loaderWithPath:(NSString *)path;

+(instancetype)loaderWithFMDatabaseQueue:(FMDatabaseQueue *)queue;

-(instancetype)initWithPath:(NSString *)path;

-(instancetype)initWithFMDatabaseQueue:(FMDatabaseQueue *)queue;


/**
 *  通过GET请求方式
 *
 *  @param url   请求地址
 *  @param dict  请求参数
 *  @param block 请求完成后的回调，id类型存放请求返回的数据
 */
-(void)GET:(NSString *)url  parameters:(NSDictionary *)dict completion:(void(^)(id))block;

-(void)GET:(NSString *)url  parameters:(NSDictionary *)dict immediately:(BOOL)immediately completion:(void(^)(id))block;

-(void)POST:(NSString *)url  parameters:(NSDictionary *)dict completion:(void(^)(id))block;

-(void)POST:(NSString *)url  parameters:(NSDictionary *)dict immediately:(BOOL)immediately completion:(void(^)(id))block;

@end
