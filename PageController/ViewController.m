//
//  ViewController.m
//  PageController
//
//  Created by mac on 16/7/27.
//  Copyright © 2016年 CES. All rights reserved.
//

#import "ViewController.h"
#import "ContentViewController.h"
#import "PageController.h"
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEADSCROLLVIEW_HEIGHT 40
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic,assign) int currentPage;
@property (nonatomic,strong) UIScrollView * headScrollView;
@property (nonatomic,strong) UIScrollView * contentScrollView;
@property (nonatomic,copy)NSArray * controlArray;
@property (nonatomic,strong) NSArray * headTitleArray;
@property (nonatomic,strong) PageController * pageController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self configHeadScrollView];
//    [self configContentScrollView];
    [self configPageController];
    [self click];
    [self deleteBtn];
}
- (void)configPageController {
    self.pageController = [[PageController alloc] initWithTitles:self.headTitleArray controllers:self.controlArray frame:CGRectMake(0, 20, self.view.frame.size.width, 300) options:nil];
    [self.view addSubview:self.pageController.view];
}
- (void)click {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(40, 400, 100, 40);
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"增加" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(handle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
- (void)deleteBtn {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(200, 400, 100, 40);
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"减少" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(deleteVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
- (void)handle:(UIButton *)sender {
    ContentViewController * vc = [[ContentViewController alloc] init];
    [self.pageController insertPageAtIndex:0 VCType:vc title:@"新标题"];
}
- (void)deleteVC:(UIButton *)sender {
    [self.pageController deletePageAtIndex:3];
}
//频道列表
-(NSArray *)headTitleArray {
    if (!_headTitleArray) {
        _headTitleArray = [NSArray arrayWithObjects:@"头条",@"娱乐",@"热点",@"体育",@"广州",@"财经",@"科技", nil];
    }
    return _headTitleArray;
}
- (NSArray *)controlArray
{
    if (!_controlArray) {
        
        NSMutableArray * temps = [NSMutableArray array];
        for (int i = 0; i < 7; i++) {
            ContentViewController * VC = [[ContentViewController alloc] init];
            VC.typeName = self.headTitleArray[i];
            [temps addObject:VC];
        }
        _controlArray = [NSArray arrayWithArray:temps];
    }
    return _controlArray;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
