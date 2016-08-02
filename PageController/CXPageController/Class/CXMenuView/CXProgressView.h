//
//  CXProgressView.h
//  PageController
//
//  Created by mac on 16/8/2.
//  Copyright © 2016年 CES. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXProgressView : UIView
@property (nonatomic,strong)NSArray * itemFrames;
@property (nonatomic,assign)CGColorRef color;
@property (nonatomic,assign)CGFloat progress;
//进度条的速度因数,默认为15,越快越好,大于0
@property (nonatomic,assign)CGFloat speedFactor;
@property (nonatomic,assign)CGFloat cornerRadius;
@property (nonatomic,assign)BOOL hollow;
@property (nonatomic,assign)BOOL hasBorder;
- (void)setProgressWithOutAnimate:(CGFloat)progress;
- (void)moveToPostion:(NSInteger)pos;
@end
