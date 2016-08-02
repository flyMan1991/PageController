//
//  CXMenuView.m
//  PageController
//
//  Created by mac on 16/8/2.
//  Copyright © 2016年 CES. All rights reserved.
//

#import "CXMenuView.h"

@interface CXMenuView ()<CXMenuItemDelegate>
@property (nonatomic,weak)CXMenuItem * selItem;
@property (nonatomic,strong)NSMutableArray * frames;
@property (nonatomic,readonly)NSInteger titleCount;
@end
// 下划线的高度
static CGFloat   const CXProgressHeight = 2.0;
static CGFloat   const CXMenuItemWidth  = 60.0;
static NSInteger const CXMenuItemTagOffset  = 6250;
static NSInteger const CXBadgeViewTagOffset = 1212;

@implementation CXMenuView
- (void)setLayoutMode:(CXMenuViewLayoutMode)layoutMode {
    _layoutMode = layoutMode;
    if (self.superview == nil) {
        return;
    }
    [self reload];
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (!self.scrollView) {
        return;
    }
    CGFloat leftMargin = self.contentMargin + self.leftView.frame.size.width;
    CGFloat rightMargin = self.contentMargin + self.rightView.frame.size.width;
    CGFloat contentWidth = self.scrollView.frame.size.width + leftMargin + rightMargin;
    CGFloat startX = self.leftView ? self.leftView.frame.origin.x : self.scrollView.frame.origin.x - self.contentMargin;
    
}


@end
