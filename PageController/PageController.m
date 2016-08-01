//
//  PageController.m
//  PageController
//
//  Created by mac on 16/7/29.
//  Copyright © 2016年 CES. All rights reserved.
//

#import "PageController.h"
#import <objc/runtime.h>
@interface PageController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic) NSMutableArray *mutableMenuItems;
@property (nonatomic,strong) UIScrollView   * menuItemScrollView;
@property (nonatomic,strong) UIScrollView   * contentScrollView;
@property (nonatomic,strong) NSMutableArray * controllerArray;
@property (nonatomic,strong) NSMutableArray * menuItems;
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
    [_controllerArray addObjectsFromArray:controllers];
    [_menuItems addObjectsFromArray:titles];
    self.view.frame = frame;
    return self;
}
- (void)initValues {
    _mutableMenuItems = [NSMutableArray array];
    _menuHeight = 40.0;
    _menuItemWidth = 111.0;
    _menuMargin = 20;
    _currentPageIndex = 0;
    _menuItemFont = [UIFont systemFontOfSize:15];
    _menuHariLineColor = [UIColor whiteColor];
    _menuItemSelectTextColor = [UIColor purpleColor];
    _menuItemNormalTextColor = [UIColor blackColor];
    _menuItemSelectBackColor = [UIColor whiteColor];
    _menuItemNormalBackColor = [UIColor whiteColor];
    _addBottomMenuHairline = YES;
    _controllerArray = [NSMutableArray array];
    _menuItems = [NSMutableArray array];
}
/**
 *  加入视图控制器
 1、先加入ChildViewController   无
 2、设置frame                   VC会调用viewDidLoad方法
 3、加入superView               VC会调用viewWillApper、viewDidApper方法
 */
- (void)addContentVC {
    _contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width * (CGFloat)_controllerArray.count, self.view.frame.size.height - _menuHeight);
    for (int i = 0; i < _controllerArray.count; i ++) {
//        //默认加载第一页
        if (i == _currentPageIndex) {
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
    _contentScrollView.delegate = self;
    _contentScrollView.scrollsToTop = NO;
    [self.view addSubview:_contentScrollView];
    [self addContentVC];
}
- (void)configmenuItemScrollView {
    _menuItemScrollView = [[UIScrollView alloc] init];
    _menuItemScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, _menuHeight);
//    _menuItemScrollView.backgroundColor = [UIColor purpleColor];
    _menuItemScrollView.showsVerticalScrollIndicator = NO;
    _menuItemScrollView.showsHorizontalScrollIndicator = NO;
    _menuItemScrollView.userInteractionEnabled = YES;
    _menuItemScrollView.scrollsToTop = NO;
    [self.view addSubview:_menuItemScrollView];
    // disable scroll bars
}
// MARK:布局UI
- (void)configureUserInterface {
    // 得到menuItemWidth
    CGFloat itemWidth = [self getMaxLength:_menuItems];
    _menuItemWidth = itemWidth;
    // 不能回滚到顶部
    CGFloat menuScrollviewWidth = (_menuItemWidth + _menuMargin) * (CGFloat)_controllerArray.count + _menuMargin;
    if (menuScrollviewWidth <= self.view.frame.size.width) {
        _menuItemScrollView.scrollEnabled = YES;
        _menuItemWidth = (self.view.frame.size.width - _menuMargin*(_controllerArray.count + 1))/_controllerArray.count;
        _menuItemScrollView.contentSize = CGSizeMake(self.view.frame.size.width, _menuHeight);
    }else{
        _menuItemScrollView.contentSize = CGSizeMake(menuScrollviewWidth, _menuHeight);
    }
    [self setUpMenuScrollviewSubview];
}
- (void)setUpMenuScrollviewSubview {
    // 移除menuItemScrollView所有子视图
    for (UIView * titleView in _menuItemScrollView.subviews) {
        [titleView removeFromSuperview];
    }
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
        if (i == _currentPageIndex) {
//            button.backgroundColor = _menuItemSelectBackColor;
            [button setTitleColor:_menuItemSelectTextColor forState:UIControlStateNormal];
        }else{
//            button.backgroundColor = _menuItemNormalBackColor;
            [button setTitleColor:_menuItemNormalTextColor forState:UIControlStateNormal];
        }
    }
}
- (void)refreshMenuScrollviewSubview {
    [self configureUserInterface];
}
//改变频道按钮的坐标
- (void)scrollHeadScrollView {
    
    CGFloat x = (_currentPageIndex - 2) * (_menuItemWidth + _menuMargin) ;
    
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
    [self.contentScrollView setContentOffset:CGPointMake(self.view.frame.size.width * currentPage, 0) animated:NO];
    [self loadScrollViewWithPage:(int)currentPage];
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
            [menuBtn setTitleColor:_menuItemSelectTextColor forState:UIControlStateNormal];
        }else{
            [menuBtn setTitleColor:_menuItemNormalTextColor forState:UIControlStateNormal];
        }
    }
    //判断页面是否已经显示，如果未显示则让其显示
    UIViewController * VC = _controllerArray[page];
    if ([_delegate respondsToSelector:@selector(didMoveToPage:index:)]) {
        [_delegate didMoveToPage:VC index:(NSInteger)_currentPageIndex];
    }
    if (![VC isViewLoaded]) {
        VC.view.frame = [self getRect:page];
        [self addChildViewController:VC];
        [self.contentScrollView addSubview:VC.view];
            }else {
        return;
    }
}
#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _contentScrollView) {
        CGFloat pageWidth = self.view.frame.size.width;
        _currentPageIndex = floor(scrollView.contentOffset.x /pageWidth);
        UIViewController * currentController = _controllerArray[_currentPageIndex];
        if ([_delegate respondsToSelector:@selector(willMoveToPage:index:)]) {
            [_delegate willMoveToPage:currentController index:(NSInteger)currentController];
        }
    }
}
//用户滑动屏幕切换频道的情景：ScrollView滚动停止的时候调用该方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _contentScrollView) {
//        NSLog(@"+++++");
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
// MARK: - insert and delete
- (void)insertPageAtIndex:(NSInteger)index VCType:(UIViewController *)type title:(NSString *)title{
    
    [_controllerArray addObject:type];
    [_menuItems addObject:title];
    [type willMoveToParentViewController:self];
    [self refreshMenuScrollviewSubview];
    [self scrollHeadScrollView];
    [self addContentVC];
    [type willMoveToParentViewController:self];
    [type didMoveToParentViewController:self];
}
- (void)deletePageAtIndex:(NSInteger)index {
    if (_controllerArray.count <= 3 || _controllerArray.count < index) {
        return;
    }
    _currentPageIndex = 0;
    UIViewController * indexVC = _controllerArray[index];
    [_controllerArray removeObjectAtIndex:index];
    [_menuItems removeObjectAtIndex:index];
    [indexVC.view removeFromSuperview];
    [indexVC removeFromParentViewController];
    [indexVC willMoveToParentViewController:nil];
    [self refreshMenuScrollviewSubview];
    [self scrollHeadScrollView];
    [self addContentVC];
    [indexVC didMoveToParentViewController:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark 视图完全出现时候,加载布局子视图
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self configcontentScrollView];
    [self configmenuItemScrollView];
    if (_menuItemScrollView.subviews.count == 0) {
        [self configureUserInterface];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
