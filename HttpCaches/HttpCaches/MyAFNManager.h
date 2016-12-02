//
//  MyAFNManager.h
//  HttpCaches
//
//  Created by Mia on 16/8/9.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface MyAFNManager : AFHTTPSessionManager

+(instancetype)shareMyManager;

@end
