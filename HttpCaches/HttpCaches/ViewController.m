//
//  ViewController.m
//  HttpCaches
//
//  Created by Mia on 16/8/8.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import "ViewController.h"

#import "HttpCachesLoader.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *testView = [[UIView alloc]init];
    testView.frame = self.view.bounds;
    testView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    [self.view addSubview:testView];
}

//点击发送请求，注意。该号为免费测试账号，请求次数只有几十次。慎点
- (IBAction)loadDataClick:(UIButton *)sender {
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"appkey"] = @"a6f70781b55b54a185d3bd773976fd23";
    dictM[@"pkg"] = @"com.thinkland.test";
    dictM[@"barcode"] = @6923450605332;
    dictM[@"cityid"] = @1;
    
    HttpCachesLoader *loader = [HttpCachesLoader loaderDefault];
    
    [loader GET:@"http://api.juheapi.com/jhbar/bar" parameters:dictM completion:^(id data) {
        NSLog(@"%@",data);
    }];
}


@end
