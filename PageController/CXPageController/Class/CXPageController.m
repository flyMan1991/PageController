//
//  CXPageController.m
//  PageController
//
//  Created by mac on 16/8/2.
//  Copyright © 2016年 CES. All rights reserved.
//

#import "CXPageController.h"
#import "CXPageConst.h"

static NSInteger const kWMUndefinedIndex = -1;
static NSInteger const kWMControllerCountUndefined = -1;

@interface CXPageController ()
{
    CGFloat _viewHeight, _viewWidth, _viewX, _viewY, _targetX, _superviewHeight;
    BOOL    _hasInited, _shouldNotScroll;
    NSInteger _initializedIndex, _controllerConut;
}
@property (nonatomic, strong, readwrite) UIViewController *currentViewController;
// 用于记录子控制器view的frame，用于 scrollView 上的展示的位置
@property (nonatomic, strong) NSMutableArray *childViewFrames;
// 当前展示在屏幕上的控制器，方便在滚动的时候读取 (避免不必要计算)
@property (nonatomic, strong) NSMutableDictionary *displayVC;
// 用于记录销毁的viewController的位置 (如果它是某一种scrollView的Controller的话)
@property (nonatomic, strong) NSMutableDictionary *posRecords;
// 用于缓存加载过的控制器
@property (nonatomic, strong) NSCache *memCache;
@property (nonatomic, strong) NSMutableDictionary *backgroundCache;
// 收到内存警告的次数
@property (nonatomic, assign) int memoryWarningCount;
@property (nonatomic, readonly) NSInteger childControllersCount;

@end

@implementation CXPageController
#pragma mark - lazy loading
- (NSMutableDictionary *)posRecords {
    if (!_posRecords) {
        _posRecords = [NSMutableDictionary dictionary];
    }
    return _posRecords;
}
- (NSMutableDictionary *)displayVC {
    if (!_displayVC) {
        _displayVC = [NSMutableDictionary dictionary];
    }
    return _displayVC;
}
#pragma mark - Public Methods
- (instancetype)initWithViewControllerClasses:(NSArray<Class> *)classes andTheirTitles:(NSArray<NSString *> *)titles {
    if (self = [super init]) {
        NSParameterAssert(classes.count == titles.count);
        _viewControllerClasses = [NSArray arrayWithArray:classes];
        _titles = [NSArray arrayWithArray:titles];
        [self cx_setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self cx_setup];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self cx_setup];
    }
    return self;
}
- (void)setMenuViewLayoutMode:(CXMenuViewLayoutMode)menuViewLayoutMode {
    _menuViewLayoutMode = menuViewLayoutMode;
    if (self.menuView.superview) {
        [self wm_resetMenuView];
    }
}
- (void)setCachePolicy:(CXPageControllerPreloadPolicy)cachePolicy {
    _cachePolicy = cachePolicy;
    self.memCache.countLimit = _cachePolicy;
}
- (void)setSelectIndex:(int)selectIndex {
    _selectIndex = selectIndex;
    if (self.menuView) {
        [self.menuView selectItemAtIndex:selectIndex];
    }
}
- (void)setProgressViewWidths:(NSArray *)progressViewWidths {
    _progressViewWidths = progressViewWidths;
    if (self.menuView) {
        self.menuView.progressWidths = progressViewWidths;
    }
}
- (void)setMenuViewContentMargin:(CGFloat)menuViewContentMargin {
    _menuViewContentMargin = menuViewContentMargin;
    if (self.menuView) {
        self.menuView.contentMargin = menuViewContentMargin;
    }
}
- (void)setViewFrame:(CGRect)viewFrame {
    _viewFrame = viewFrame;
    if (self.menuView) {
        _hasInited = NO;
        [self viewDidLayoutSubviews];
    }
}
- (void)reloadData {
    
}
- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index {
    [self.menuView updateTitle:title atIndex:index andWidth:NO];
}
- (void)updateTitle:(NSString *)title andWidth:(CGFloat)width atIndex:(NSInteger)index {
    if (self.itemsWidths && index < self.itemsWidths.count) {
        NSMutableArray * mutableWidths = [NSMutableArray arrayWithArray:self.itemsWidths];
        mutableWidths[index] = @(width);
        self.itemsWidths = [mutableWidths copy];
    }else {
        NSMutableArray *mutableWidths = [NSMutableArray array];
        for (int i = 0 ; i < self.childControllersCount; i++) {
            CGFloat itemWidth = (i == index) ? width :self.menuItemWidth;
            [mutableWidths addObject:@(itemWidth)];
        }
        self.itemsMargins = [mutableWidths copy];
    }
    [self.menuView updateTitle:title atIndex:index andWidth:YES];
}

#pragma mark - Notification
- (void)willResignActive:(NSNotification *)notification {
    for (int i = 0; i < self.childControllersCount; i++) {
        id obj = [self.memCache objectForKey:@(i)];
        if (obj) {
            [self.backgroundCache setObject:obj forKey:@(i)];
        }
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    for (NSNumber *key in self.backgroundCache.allKeys) {
        if (![self.memCache objectForKey:key]) {
            [self.memCache setObject:self.backgroundCache[key] forKey:key];
        }
    }
    [self.backgroundCache removeAllObjects];
}
#pragma mark - delegate 
- (NSDictionary *)infoWithIndex:(NSInteger)index {
    NSString *title = [self titleAtIndex:index];
    return @{@"title": title, @"index": @(index)};
}
- (void)willCachedController:(UIViewController *)vc atIndex:(NSInteger)index {
    if (self.childControllersCount && [self.delegate respondsToSelector:@selector(pageController:willEnterViewController:withInfo:)]) {
        NSDictionary * info = [self infoWithIndex:index];
        [self.delegate pageController:self willEnterViewController:vc withInfo:info];
    }
}
// 完全进入控制器(即停止滑动后调用)
- (void)didEnterController:(UIViewController *)vc atIndex:(NSInteger)index {
    if (!self.childControllersCount) {
        return;
    }
    NSDictionary * info = [self infoWithIndex:index];
    if ([self.delegate respondsToSelector:@selector(pageController:didEnterViewController:withInfo:)]) {
        [self.delegate pageController:self didEnterViewController:vc withInfo:info];
    }
    // 当控制器创建时,调用延迟加载的代理方法
    if (_initializedIndex == index && [self.delegate respondsToSelector:@selector(pageController:lazyLoadViewController:withInfo:)]) {
        [self.delegate pageController:self lazyLoadViewController:vc withInfo:info];
        _initializedIndex = kWMUndefinedIndex;
    }
    // 根据preloadPolicy 预加载控制器
    if (self.preloadPolicy == CXPageControllerPreloadPolicyNever) {
        return;
    }
    int start = 0;
    int end = (int)self.childControllersCount - 1;
    if (index > self.preloadPolicy) {
        start = (int)index - self.preloadPolicy;
    }
    if (self.childControllersCount - 1 > self.preloadPolicy + index) {
        end = (int)index + self.preloadPolicy;
    }
    for (int i = start; i <= end; i++ ) {
        // 如果存在,不需要预加载
        if (![self.memCache objectForKey:@(i)] && !self.displayVC[@(i)]) {
            [self cx_addViewControllerAtIndex:i];
            [self cx_postAddToSuperViewNotificationWithIndex:i];
        }
    }
    _selectIndex = (int)index;
}
#pragma mark - DataSource 
- (NSInteger)childControllersCount {
    if (_controllerConut == kWMControllerCountUndefined) {
        if ([self.dataSource respondsToSelector:@selector(numbersOfChildControllersInPageController:)]) {
            _controllerConut = [self.dataSource numbersOfChildControllersInPageController:self];
        }else {
            _controllerConut = self.viewControllerClasses.count;
        }
    }
    return _controllerConut;
}
- (UIViewController *)initializeViewControllerAtIndex:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(pageController:viewControllerAtIndex:)]) {
        return [self.dataSource pageController:self viewControllerAtIndex:index];
    }
    return [[self.viewControllerClasses[index] alloc] init];
}
#pragma mark - Private Methods
- (void)cx_resetScrollView {
    if (self.scrollView) {
        [self.scrollView removeFromSuperview];
    }
    [self cx_addScrollView];
    [self cx_addViewControllerAtIndex:self.selectIndex];
    self.currentViewController = self.displayVC[@(self.selectIndex)];
}
- (void)cx_clearDatas {
    _controllerConut = kWMControllerCountUndefined;
    _hasInited = NO;
    _selectIndex = self.selectIndex < self.childControllersCount ? self.selectIndex :(int)self.childControllersCount - 1;
    NSArray * displayingViewControllers = self.displayVC.allValues;
    for (UIViewController * vc in displayingViewControllers) {
        [vc.view removeFromSuperview];
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
    self.memoryWarningCount = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cx_growCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cx_growCachePolicyToHigh) object:nil];
    self.currentViewController = nil;
    [self.posRecords removeAllObjects];
    [self.displayVC removeAllObjects];
}
// 当控制器init完成时发送通知
- (void)postAddToSuperViewNotificationWithIndex:(int)index {
    if (!self.postNotification) {
        return;
    }
    NSDictionary *info = @{
                           @"index":@(index),
                           @"title":[self titleAtIndex:index]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:CXControllerDidAddToSuperViewNotification
                                                        object:info];

}
// 当自控制器完全展示在user面前时发送通知
- (void)cx_postFullyDisplayedNotificationWithCurrentIndex:(int)index {
    if (!self.postNotification) { return; }
    NSDictionary *info = @{
                           @"index":@(index),
                           @"title":[self titleAtIndex:index]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:CXControllerDidFullyDisplayedNotification
                                                        object:info];
}
#pragma mark - 初始化一些参数,在init中调用
- (void)cx_setup {
    _titleSizeSelected  = CXTitleSizeSelected;
    _titleColorSelected = CXTitleColorSelected;
    _titleSizeNormal    = CXTitleSizeNormal;
    _titleColorNormal   = CXTitleColorNormal;
    
    _menuBGColor   = CXMenuBGColor;
    _menuHeight    = CXMenuHeight;
    _menuItemWidth = CXMenuItemWidth;
    
    _memCache = [[NSCache alloc] init];
    _initializedIndex = kWMUndefinedIndex;
    _controllerConut  = kWMControllerCountUndefined;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.preloadPolicy = CXPageControllerPreloadPolicyNever;
    self.cachePolicy = CXPageControllerCachePolicyNoLimit;
    
    self.delegate = self;
    self.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}
- (void)cx_addScrollView {
    CXScrollView * scrollView = [[CXScrollView alloc] init];
    scrollView.scrollsToTop = NO;
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = self.bounces;
    scrollView.otherGestureRecognizerSimultaneously = self.otherGestureRecognizerSimultaneously;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    if (!self.navigationController) {
        return;
    }
    for (UIGestureRecognizer * gestureRecognizer in scrollView.gestureRecognizers) {
        [gestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
}
- (void)cx_addMenuView {
    CGFloat menuY = _viewY;
    if (self.showOnNavigationBar && self.navigationController.navigationBar) {
        CGFloat navHeigh = self.navigationController.navigationBar.frame.size.height;
        CGFloat menuHeight = self.menuHeight > navHeigh ? navHeigh :self.menuHeight;
        menuY = (navHeigh - menuHeight)/2;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
