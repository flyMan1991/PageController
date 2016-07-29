//
//  ContentViewController.m
//  PageController
//
//  Created by mac on 16/7/27.
//  Copyright © 2016年 CES. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()
@property (nonatomic,strong)UILabel * contentLabel;
@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.contentLabel];
    self.contentLabel.text = self.typeName;
}
- (UILabel *)contentLabel {
    if (!_contentLabel) {
        self.contentLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.backgroundColor = [UIColor redColor];
    }
    return _contentLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
