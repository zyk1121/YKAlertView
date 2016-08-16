//
//  ViewController.m
//  YKAlertView
//
//  Created by zhangyuanke on 16/8/15.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import "ViewController.h"
#import "YKAlertView.h"

@interface ViewController ()<YKAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)testYKAlertView:(id)sender {
    // 1.默认AlertView
    YKAlertView *alertView1 = [[YKAlertView alloc] init];
    [alertView1 show];
    // 2.一般AlertView
    YKAlertView *alertView2 = [[YKAlertView alloc] initWithTitle:@"title" message:@"message" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"]];
    [alertView2 show];
    // 3.较长Title和Message AlertView
    YKAlertView *alertView3 = [[YKAlertView alloc] initWithTitle:@"较长标题title测试较长标题title测试" message:@"较长message测试较长message测试较长message测试较长message测试" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"]];
    [alertView3 show];
    // 4.多个button情况下的 AlertView
    YKAlertView *alertView4 = [[YKAlertView alloc] initWithTitle:@"标题title" message:@"Message" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@[@"按钮1", @"按钮2", @"按钮3"]];
    [alertView4 show];
}

#pragma mark - YKAlertViewDelegate

- (void)YKAlertViewClickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"YKAlertViewClickedButtonAtIndex:%ld", buttonIndex);
}

@end
