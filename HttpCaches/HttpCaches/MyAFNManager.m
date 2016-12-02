//
//  MyAFNManager.m
//  HttpCaches
//
//  Created by Mia on 16/8/9.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import "MyAFNManager.h"

@implementation MyAFNManager

+(instancetype)shareMyManager{
    
    static MyAFNManager *mgr;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        mgr  = [[self alloc]initWithBaseURL:[NSURL URLWithString:@"http://api.budejie.com/api/api_open.php/"]];
        mgr = [MyAFNManager manager];
    });
    
    return mgr;
}



@end
