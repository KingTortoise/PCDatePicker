//
//  PCDatePickerView.h
//  PetCommunity
//
//  Created by jinwenwu on 2017/8/28.
//  Copyright © 2017年 jinwenwu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ToolBarAction)(NSDate *);

@interface PCDatePickerView : UIView
/**
 * @property maximumDate: 最大值
 */
@property (nonatomic, strong) NSDate *maximumDate;
/**
 * @property minimumDate: 最小值
 */
@property (nonatomic, strong) NSDate *minimumDate;
/**
 * @property date: 用于手动设置时间
 */
@property (nonatomic, strong) NSDate *date;
/**
 * @property doneAction: 用于回调
 */
@property (nonatomic, copy) ToolBarAction doneAction;
/**
 * @property canChoicePastTime: 是否不可选择过去的时间 默认是NO
 */
@property (nonatomic, assign) BOOL canChoicePastTime;
/**
 * @property backGroundColor: 选择器背景颜色
 */
@property (nonatomic, strong) UIColor *backGroundColor;

/**
 * 隐藏视图
 */
- (void)hide;

/**
 * 显示视图
 */
- (void)showView;
@end

@interface NSDate (PC)
+ (NSDateComponents *)dateComponentsFromDate:(NSDate *)date;
+ (NSUInteger)getNumberOfDaysInMonth:(NSInteger)month Year:(NSInteger)year;
@end
