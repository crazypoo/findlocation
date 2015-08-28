//
//  ViewController.m
//  FindLocationDemo
//
//  Created by 邓杰豪 on 15/8/28.
//  Copyright (c) 2015年 邓杰豪. All rights reserved.
//

#import "ViewController.h"
#import "LFindLocationViewController.h"

@interface ViewController ()<LFindLocationViewControllerDelegete>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [btn setTitle:@"点我" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnTap:) forControlEvents:UIControlEventTouchDragInside];
    [self.view addSubview:btn];
}

-(void)btnTap:(UIButton *)sender
{
    LFindLocationViewController *find = [[LFindLocationViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:find];
    find.delegete = self;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)cityViewdidSelectCity:(NSString *)city anamation:(BOOL)anamation
{
    NSLog(@">>>>>>>>>>>>%@",city);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
