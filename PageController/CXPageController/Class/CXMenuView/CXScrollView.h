//
//  CXScrollView.h
//  PageController
//
//  Created by mac on 16/8/2.
//  Copyright © 2016年 CES. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXScrollView : UIScrollView<UIGestureRecognizerDelegate>
/// 左滑时同时启用其他手势，比如系统左滑、sidemenu左滑。默认 NO
@property (assign, nonatomic) BOOL otherGestureRecognizerSimultaneously;
@end
