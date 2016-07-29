//
//  PageController.m
//  PageController
//
//  Created by mac on 16/7/29.
//  Copyright © 2016年 CES. All rights reserved.
//

#import "PageController.h"

@interface PageController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic) NSMutableArray *mutableMenuItems;
@property (nonatomic,strong) UIScrollView * menuItemScrollView;
@property (nonatomic,strong) UIScrollView * contentScrollView;
@end

@implementation PageController
NSString * const PageMenuOptionSelectionIndicatorHeight             = @"selectionIndicatorHeight";
NSString * const PageMenuOptionMenuItemSeparatorWidth               = @"menuItemSeparatorWidth";
NSString * const PageMenuOptionScrollMenuBackgroundColor            = @"scrollMenuBackgroundColor";
NSString * const PageMenuOptionViewBackgroundColor                  = @"viewBackgroundColor";
NSString * const PageMenuOptionBottomMenuHairlineColor              = @"bottomMenuHairlineColor";
NSString * const PageMenuOptionSelectionIndicatorColor              = @"selectionIndicatorColor";
NSString * const PageMenuOptionMenuItemSeparatorColor               = @"menuItemSeparatorColor";
NSString * const PageMenuOptionMenuMargin                           = @"menuMargin";
NSString * const PageMenuOptionMenuHeight                           = @"menuHeight";
NSString * const PageMenuOptionSelectedMenuItemLabelColor           = @"selectedMenuItemLabelColor";
NSString * const PageMenuOptionUnselectedMenuItemLabelColor         = @"unselectedMenuItemLabelColor";
NSString * const PageMenuOptionUseMenuLikeSegmentedControl          = @"useMenuLikeSegmentedControl";
NSString * const PageMenuOptionMenuItemSeparatorRoundEdges          = @"menuItemSeparatorRoundEdges";
NSString * const PageMenuOptionMenuItemFont                         = @"menuItemFont";
NSString * const PageMenuOptionMenuItemSeparatorPercentageHeight    = @"menuItemSeparatorPercentageHeight";
NSString * const PageMenuOptionMenuItemWidth                        = @"menuItemWidth";
NSString * const PageMenuOptionEnableHorizontalBounce               = @"enableHorizontalBounce";
NSString * const PageMenuOptionAddBottomMenuHairline                = @"addBottomMenuHairline";
NSString * const PageMenuOptionMenuItemWidthBasedOnTitleTextWidth   = @"menuItemWidthBasedOnTitleTextWidth";
NSString * const PageMenuOptionScrollAnimationDurationOnMenuItemTap = @"scrollAnimationDurationOnMenuItemTap";
NSString * const PageMenuOptionCenterMenuItems                      = @"centerMenuItems";
NSString * const PageMenuOptionHideTopMenuBar                       = @"hideTopMenuBar";

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles controllers:(NSArray<UIViewController *> *)controllers frame:(CGRect)frame options:(NSDictionary<NSString *,id> *)options {
    self = [super init];
    if (!self) {
        return  nil;
    }
    [self initValues];
    _controllerArray = controllers;
    _menuItems = titles;
    self.view.frame = frame;
    [self configcontentScrollView];
    [self configmenuItemScrollView];
    if (_menuItemScrollView.subviews.count == 0) {
        [self configureUserInterface];

    }
    return self;
}
- (void)initValues {
    _mutableMenuItems = [NSMutableArray array];
    _menuHeight = 40.0;
    _menuItemWidth = 111.0;
    _menuMargin = 20;
    _menuItemFont = [UIFont systemFontOfSize:15];
    _menuHariLineColor = [UIColor whiteColor];
    _menuItemSelectTextColor = [UIColor whiteColor];
    _menuItemNormalTextColor = [UIColor blackColor];
    _menuItemSelectBackColor = [UIColor whiteColor];
    _menuItemNormalBackColor = [UIColor whiteColor];
    _addBottomMenuHairline = YES;
}
/**
 *  加入视图控制器
 1、先加入ChildViewController   无
 2、设置frame                   VC会调用viewDidLoad方法
 3、加入superView               VC会调用viewWillApper、viewDidApper方法
 */
- (void)addContentVC {
    for (int i = 0; i < _controllerArray.count; i ++) {
        UIViewController  * VC = _controllerArray[i];
        [self addChildViewController:VC];
        //默认加载第一页
        if (i == 0) {
            [self loadScrollViewWithPage:i];
        }
    }
}
- (void)configcontentScrollView {
    _contentScrollView = [[UIScrollView alloc] init];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.bounces = NO;
    _contentScrollView.frame = CGRectMake(0, _menuHeight, self.view.frame.size.width, self.view.frame.size.height - _menuHeight);
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width * (CGFloat)_controllerArray.count, self.view.frame.size.height - _menuHeight);
    [self.view addSubview:_contentScrollView];
    [self addContentVC];
}
- (void)configmenuItemScrollView {

    _menuItemScrollView = [[UIScrollView alloc] init];
    _menuItemScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, _menuHeight);
    _menuItemScrollView.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:_menuItemScrollView];
    // disable scroll bars
    _menuItemScrollView.showsVerticalScrollIndicator = NO;
    _menuItemScrollView.showsHorizontalScrollIndicator = NO;
}
// MARK:布局UI
- (void)configureUserInterface {
    // 得到menuItemWidth
    CGFloat itemWidth = [self getMaxLength:_menuItems];
    _menuItemWidth = itemWidth;
    // 不能回滚到顶部
    _menuItemScrollView.scrollsToTop = NO;
    _contentScrollView.scrollsToTop = NO;
    CGFloat menuScrollviewWidth = (_menuItemWidth + _menuMargin) * (CGFloat)_controllerArray.count + _menuMargin;
    if (menuScrollviewWidth <= self.view.frame.size.width) {
        _menuItemScrollView.scrollEnabled = NO;
        _menuItemWidth = (self.view.frame.size.width - _menuMargin*(_controllerArray.count + 1))/_controllerArray.count;
        _menuItemScrollView.contentSize = CGSizeMake(self.view.frame.size.width, _menuHeight);
    }else{
        _menuItemScrollView.contentSize = CGSizeMake(menuScrollviewWidth, _menuHeight);
    }
    _contentScrollView.delegate = self;
    _menuItemScrollView.userInteractionEnabled = YES;
    [self setUpMenuScrollviewSubview];
}
- (void)setUpMenuScrollviewSubview {
    for (int i = 0; i < _menuItems.count; i ++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(_menuMargin * (i + 1) + _menuItemWidth * i, 0, _menuItemWidth, _menuHeight);
        [button setTitle:_menuItems[i] forState:UIControlStateNormal];
        [button setTag:1000 + i];
        [button.titleLabel setFont:_menuItemFont];
        button.userInteractionEnabled = YES;
        [_menuItemScrollView addSubview:button];
        
        [button addTarget:self action:@selector(headScrollViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //默认当前为第一个频道
        if (i == 0) {
//            button.backgroundColor = _menuItemSelectBackColor;
            [button setTitleColor:_menuItemSelectTextColor forState:UIControlStateNormal];
        }else{
//            button.backgroundColor = _menuItemNormalBackColor;
            [button setTitleColor:_menuItemNormalTextColor forState:UIControlStateNormal];
        }
        
    }
}
//改变频道按钮的坐标
- (void)scrollHeadScrollView {
    
    CGFloat x = _currentPageIndex * _menuItemWidth + _menuItemWidth * 0.5 - self.view.frame.size.width * 0.5;
    if (x >= 0) {
        if (x >= self.menuItemScrollView.contentSize.width - self.view.frame.size.width) {
            x = self.menuItemScrollView.contentSize.width - self.view.frame.size.width;
            [self.menuItemScrollView setContentOffset:CGPointMake(x, 0) animated:YES];   //向右滚动到尽头
        }else
            [self.menuItemScrollView setContentOffset:CGPointMake(x, 0) animated:YES];
    }else
        [self.menuItemScrollView setContentOffset:CGPointMake(0, 0) animated:YES];  //向左滚动到尽头

}

//点击频道按钮切换
- (void)headScrollViewButtonAction:(UIButton *)button {
    NSInteger currentPage = button.tag - 1000;
    [self loadScrollViewWithPage:(int)currentPage];
    [self.contentScrollView setContentOffset:CGPointMake(self.view.frame.size.width * currentPage, _menuHeight) animated:NO];
}
- (CGRect)getRect:(int)currentPage {
    CGRect rect = CGRectMake(self.view.frame.size.width * currentPage, 0, self.view.frame.size.width,self.view.frame.size.height -  _menuHeight);
    return rect;
}
- (void)loadScrollViewWithPage:(int)page {
    _currentPageIndex = page;
    if (page < 0 || page >= _menuItems.count) {
        return;
    }
    for (int i = 0; i < _menuItems.count; i++) {
        UIButton * menuBtn = (UIButton *)[_menuItemScrollView viewWithTag:1000 + i];
        //默认当前为第一个频道
        if (i == _currentPageIndex) {
            //            menuBtn.backgroundColor = _menuItemSelectBackColor;
            [menuBtn setTitleColor:_menuItemSelectTextColor forState:UIControlStateNormal];
        }else{
            //            menuBtn.backgroundColor = _menuItemNormalBackColor;
            [menuBtn setTitleColor:_menuItemNormalTextColor forState:UIControlStateNormal];
        }
    }
    //判断页面是否已经显示，如果未显示则让其显示
    UIViewController * VC = [self.childViewControllers objectAtIndex:page];
    if (VC.view.superview == nil) {
        VC.view.frame = [self getRect:page];
        [self.contentScrollView addSubview:VC.view];
    }else {
        return;
    }
    
}
#pragma mark UIScrollViewDelegate 
//用户滑动屏幕切换频道的情景：ScrollView滚动停止的时候调用该方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView == _contentScrollView) {
        CGFloat pageWidth = self.view.frame.size.width;
        _currentPageIndex = floor(scrollView.contentOffset.x /pageWidth);
        //加载页面
        [self loadScrollViewWithPage:(int)_currentPageIndex];
        //滚动标题栏
        [self scrollHeadScrollView];
    }
}

//用户点击导航频道切换内容的情景：
// 调用以下函数，来自动滚动到想要的位置，此过程中设置有动画效果，停止时，触发该函数
// UIScrollView的setContentOffset:animated:
// UIScrollView的scrollRectToVisible:animated:
// UITableView的scrollToRowAtIndexPath:atScrollPosition:animated:
// UITableView的selectRowAtIndexPath:animated:scrollPosition:
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:self.contentScrollView];
}


//用户滑动屏幕的情况：实时改变频道按钮的大小
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
   
    
}


// MARK: - GET maxLength of menuitem title
- (CGFloat)getMaxLength:(NSArray *)menuItems {
    CGFloat maxLength = 0.0;
    for (NSString * itemTitles in menuItems) {
        CGRect  itemWithRect = [itemTitles boundingRectWithSize:CGSizeMake(1000, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_menuItemFont} context:nil];
        maxLength = itemWithRect.size.width >= maxLength ? itemWithRect.size.width :maxLength;
    }
    return maxLength + 20;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
