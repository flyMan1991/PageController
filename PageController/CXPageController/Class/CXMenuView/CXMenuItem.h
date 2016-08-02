//
//  CXMenuItem.h
//  PageController
//
//  Created by mac on 16/8/2.
//  Copyright © 2016年 CES. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CXMenuItem;

typedef NS_ENUM(NSUInteger, CXMenuItemState) {
    CXMenuItemStateSelected,
    CXMenuItemStateNormal,
};
@protocol CXMenuItemDelegate <NSObject>

@optional
- (void)didPressedMenuItem:(CXMenuItem *)menuItem;
@end
@interface CXMenuItem : UILabel
/** 设置rate,并刷新标题状态 */
@property (nonatomic, assign) CGFloat rate;

/** normal状态的字体大小，默认大小为15 */
@property (nonatomic, assign) CGFloat normalSize;

/** selected状态的字体大小，默认大小为18 */
@property (nonatomic, assign) CGFloat selectedSize;

/** normal状态的字体颜色，默认为黑色 (可动画) */
@property (nonatomic, strong) UIColor *normalColor;

/** selected状态的字体颜色，默认为红色 (可动画) */
@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, weak) id<CXMenuItemDelegate> delegate;
/** 进度条的速度因数，默认为 15，越小越快， 大于 0 */
@property (nonatomic, assign) CGFloat speedFactor;

- (void)selectedItemWithoutAnimation;
- (void)deselectedItemWithoutAnimation;
@end
