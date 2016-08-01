//
//  PageController.h
//  PageController
//
//  Created by mac on 16/7/29.
//  Copyright © 2016年 CES. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PageController;
#pragma mark -Delegate functions

@protocol PageControllerDelegate <NSObject>

@optional
- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index;
- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index;
@end

@interface MenuItemVie : UIView


@property (nonatomic,strong)UILabel * titleLabel;
@property (nonatomic,strong)UIView * menuItemSeparator;
- (void)setUpMenuItemView:(CGFloat)menuItemWidth menuScrollViewHeight:(CGFloat)menuScrollViewHeight indicatorHeight:(CGFloat)indicatorHeight separatorPercentageHeight:(CGFloat)separatorPercentageHeight separatorWidth:(CGFloat)separatorWidth separatorRoundEdges:(BOOL)separatorRoundEdges menuItemSeparatorColor:(UIColor *)menuItemSeparatorColor;

- (void)setTitleText:(NSString *)text;

@end




@interface PageController : UIViewController

@property (nonatomic) NSInteger currentPageIndex;
@property (nonatomic) CGFloat menuHeight;
@property (nonatomic) CGFloat menuItemWidth;
@property (nonatomic) UIFont *menuItemFont;
@property (nonatomic) CGFloat menuMargin;

@property (nonatomic) BOOL addBottomMenuHairline;
@property (nonatomic) BOOL menuItemWidthBasedOnTitleTextWidth;
@property (nonatomic) BOOL useMenuLikeSegmentedControl;
@property (nonatomic,copy)id<PageControllerDelegate> delegate;
@property (nonatomic,strong)UIColor * menuHariLineColor; // 下划线颜色
@property (nonatomic,strong)UIColor * menuItemSelectTextColor;  // 每个题目选中文字的颜色
@property (nonatomic,strong)UIColor * menuItemNormalTextColor;  // 每个题目正常文字的颜色

@property (nonatomic,strong)UIColor * menuItemSelectBackColor;  // 每个选中按钮的背景色
@property (nonatomic,strong)UIColor * menuItemNormalBackColor;  // 每个按钮的正常背景色

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles
                   controllers:(NSArray<UIViewController *> *)controllers
                         frame:(CGRect)frame
                       options:(NSDictionary<NSString *,id> *)options;
#pragma mark    delete and insert
- (void)deletePageAtIndex:(NSInteger)index;
- (void)insertPageAtIndex:(NSInteger)index
                   VCType:(UIViewController *)type
                    title:(NSString *)title;
extern NSString * const PageMenuOptionSelectionIndicatorHeight;
extern NSString * const PageMenuOptionMenuItemSeparatorWidth;
extern NSString * const PageMenuOptionScrollMenuBackgroundColor;
extern NSString * const PageMenuOptionViewBackgroundColor;
extern NSString * const PageMenuOptionBottomMenuHairlineColor;
extern NSString * const PageMenuOptionSelectionIndicatorColor;
extern NSString * const PageMenuOptionMenuItemSeparatorColor;
extern NSString * const PageMenuOptionMenuMargin;
extern NSString * const PageMenuOptionMenuHeight;
extern NSString * const PageMenuOptionSelectedMenuItemLabelColor;
extern NSString * const PageMenuOptionUnselectedMenuItemLabelColor;
extern NSString * const PageMenuOptionUseMenuLikeSegmentedControl;
extern NSString * const PageMenuOptionMenuItemSeparatorRoundEdges;
extern NSString * const PageMenuOptionMenuItemFont;
extern NSString * const PageMenuOptionMenuItemSeparatorPercentageHeight;
extern NSString * const PageMenuOptionMenuItemWidth;
extern NSString * const PageMenuOptionEnableHorizontalBounce;
extern NSString * const PageMenuOptionAddBottomMenuHairline;
extern NSString * const PageMenuOptionMenuItemWidthBasedOnTitleTextWidth;
extern NSString * const PageMenuOptionScrollAnimationDurationOnMenuItemTap;
extern NSString * const PageMenuOptionCenterMenuItems;
extern NSString * const PageMenuOptionHideTopMenuBar;
@end
