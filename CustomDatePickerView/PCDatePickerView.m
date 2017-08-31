//
//  PCDatePickerView.m
//  PetCommunity
//
//  Created by jinwenwu on 2017/8/28.
//  Copyright © 2017年 jinwenwu. All rights reserved.
//

#import "PCDatePickerView.h"

#define PC_NUMBER_ROWS  16384
#define PC_ROW_HEIGHT   32
#define PC_TOOLBAR_HEIGHT  44
#define PC_DATEPICKER_HEIGHT 200
#define PC_NUMBER_YEARROWS 10000
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define UIColorFromHexWithAlpha(hexValue,a) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:a]
#define UIColorFromHex(hexValue)            UIColorFromHexWithAlpha(hexValue,1.0)
#define PC_SEPARATOR_COLOR           UIColorFromHex(0xcccccc)

#ifndef isIOS8
#define isIOS8   ([[[UIDevice currentDevice]systemVersion]integerValue] >= 8.0)
#endif

@interface PCDatePickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *datePicker;
@property (nonatomic ,strong) dispatch_source_t timer;
@property (nonatomic, strong) UIView *dateView;
@property (nonatomic, strong) UIToolbar *actionToolBar;
@property (nonatomic, assign) NSInteger selectedYear;
@property (nonatomic, assign) NSInteger selectedMonth;
@property (nonatomic, assign) NSInteger selectedDay;
@property (nonatomic, assign) NSInteger selectedHour;
@property (nonatomic, assign) NSInteger selectedMinute;

@property (nonatomic, assign) NSInteger currentYear;
@property (nonatomic, assign) NSInteger currentMonth;
@property (nonatomic, assign) NSInteger currentDay;
@property (nonatomic, assign) NSInteger currentHour;
@property (nonatomic, assign) NSInteger currentMinute;
@end

@implementation PCDatePickerView

#pragma mark - init
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    self.frame = CGRectMake(0, CGRectGetHeight(window.frame), SCREEN_WIDTH, PC_TOOLBAR_HEIGHT+PC_DATEPICKER_HEIGHT);
    _dateView = [[UIView alloc] initWithFrame:CGRectMake(0, PC_TOOLBAR_HEIGHT, SCREEN_WIDTH, PC_DATEPICKER_HEIGHT)];
    [self addSubview:_dateView];
    self.datePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PC_DATEPICKER_HEIGHT)];
    self.datePicker.delegate = self;
    self.datePicker.dataSource = self;
    self.datePicker.showsSelectionIndicator = YES;
    [_dateView addSubview:_datePicker];
    
    _actionToolBar = [[UIToolbar alloc]init];
    _actionToolBar.barStyle = UIBarStyleDefault;
    [_actionToolBar sizeToFit];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(actionCancel:)];
    //cancelBtn.width = 60.0f;
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(actionDone:)];
    //doneBtn.width = 60.0f;
    [_actionToolBar setItems:[NSArray arrayWithObjects:cancelBtn,flexSpace,doneBtn, nil] animated:YES];
    [self addSubview:_actionToolBar];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 5;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 3 || component == 4 || component == 1 || component == 2) {
        return PC_NUMBER_ROWS;
    }
    return PC_NUMBER_YEARROWS;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *str = nil;
    if (component == 0) {
        str = [NSString stringWithFormat:@"%ld%@",(long)row,@"年"];
    }else if(component == 1){
        str = [NSString stringWithFormat:@"%ld%@",(long)row%12,@"月"];
    }else if(component == 2){
        str = [NSString stringWithFormat:@"%ld%@",(long)row%31+1,@"日"];
    }else if(component == 3){
        str = [NSString stringWithFormat:@"%ld%@",(long)row%24,@"时"];
    }else{
        str = [NSString stringWithFormat:@"%ld%@",(long)row%60,@"分"];
    }
    return str;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return PC_ROW_HEIGHT;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *str = @"";
    if (component == 0) {
        str = [NSString stringWithFormat:@"%ld%@",(long)row,@"年"];
    }else if(component == 1){
        str = [NSString stringWithFormat:@"%ld%@",(long)row%12+1,@"月"];
    }else if(component == 2){
        str = [NSString stringWithFormat:@"%ld%@",(long)row%31+1,@"日"];
    }else if(component == 3){
        str = [NSString stringWithFormat:@"%ld%@",(long)row%24,@"时"];
    }else{
        str = [NSString stringWithFormat:@"%ld%@",(long)row%60,@"分"];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, PC_ROW_HEIGHT)];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = str;
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        if (!self.canChoicePastTime) {
            [self judgeDate:row inComponent:0];
        }else{
            _selectedYear = row;
        }
        NSInteger numOfDays = [NSDate getNumberOfDaysInMonth:_selectedMonth Year:_selectedYear];
        if (_selectedDay > numOfDays) {
            [self.datePicker selectRow:numOfDays-1 + 6200 inComponent:2 animated:YES];
            _selectedDay = numOfDays;
        }
    }else if(component == 1){
        if (!self.canChoicePastTime) {
            [self judgeDate:row  inComponent:1];
        }else{
           _selectedMonth = row%12+1;
        }
        NSInteger numOfDays = [NSDate getNumberOfDaysInMonth:_selectedMonth Year:_selectedYear];
        if (_selectedDay > numOfDays) {
            [self.datePicker selectRow:numOfDays-1 + 6200 inComponent:2 animated:YES];
            _selectedDay = numOfDays;
        }
    }else if (component == 2) {
        if (!self.canChoicePastTime) {
            [self judgeDate:row inComponent:2];
        }
        NSInteger numOfDays = [NSDate getNumberOfDaysInMonth:_selectedMonth Year:_selectedYear];
        if (row%31+1 > numOfDays) {
            [self.datePicker selectRow:numOfDays-1 + 6200 inComponent:2 animated:YES];
            _selectedDay = numOfDays;
        }else{
            _selectedDay = row%31+1;
        }
    }else if(component == 3){
        if (!self.canChoicePastTime) {
            [self judgeDate:row inComponent:3];
        }else{
            _selectedHour = row%24;
        }
    }else if(component == 4){
        if (!self.canChoicePastTime) {
            [self judgeDate:row inComponent:4];
        }else{
             _selectedMinute = row%60;
        }
    }
    [self judgeTime];
}
//判断选择的时间是否小于当前时间
- (void)judgeDate:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        if (row < _currentYear) {
            [self.datePicker selectRow:_currentYear inComponent:0 animated:YES];
            [self judgeDate:_currentYear inComponent:0];
        }else if (row == _currentYear){
             _selectedYear = row;
            [self judgeDate:_selectedMonth-1 inComponent:1];
        }else{
            _selectedYear = row;
        }
    }else if (component == 1){
        if (row%12+1 < _currentMonth && _selectedYear == _currentYear) {
            [self.datePicker selectRow:_currentMonth-1 + 4800 inComponent:1 animated:YES];
            [self judgeDate:_currentMonth-1+ 4800  inComponent:1];
        }else if(row%12+1 == _currentMonth && _selectedYear == _currentYear){
            _selectedMonth = row%12+1;
            [self judgeDate:_selectedDay-1 inComponent:2];
        }else{
            _selectedMonth = row%12+1;
        }
    }else if (component == 2){
        if (row%31+1 < _currentDay && _selectedYear == _currentYear && _selectedMonth == _currentMonth) {
            [self.datePicker selectRow:_currentDay-1 + 6200 inComponent:2 animated:YES];
            [self judgeDate:_currentDay-1+6200 inComponent:2];
        }else if(row%31+1 == _currentDay && _selectedYear == _currentYear && _selectedMonth == _currentMonth){
            _selectedDay = row%31+1;
            [self judgeDate:_selectedHour inComponent:3];
        }else{
            _selectedDay = row%31+1;
        }
    }else if(component == 3){
        if (row%24 < _currentHour && _selectedYear == _currentYear && _selectedMonth == _currentMonth && _selectedDay == _currentDay) {
            [self.datePicker selectRow:_currentHour+4800 inComponent:3 animated:YES];
            [self judgeDate:_currentHour+4800 inComponent:3];
        }else if(row%24 == _currentHour && _selectedYear == _currentYear && _selectedMonth == _currentMonth && _selectedDay == _currentDay){
            _selectedHour = row%24;
            [self judgeDate:_selectedMinute inComponent:4];
        }else{
            _selectedHour = row%24;
        }
    }else{
        if (row%60 < _currentMinute && _selectedYear == _currentYear && _selectedMonth == _currentMonth && _selectedDay == _currentDay && _selectedHour == _currentHour) {
            [self.datePicker selectRow:_currentMinute + 6000 inComponent:4 animated:YES];
            _selectedMinute = _currentMinute;
        }else{
            _selectedMinute = row%60;
        }
    }
}

//判断选择的时间是否大于最大时间或者最小时间
- (void)judgeTime
{
    NSDate *date = [self getDateByPickerview];
    if (self.minimumDate && [date compare:self.minimumDate] == NSOrderedAscending) {
        NSDateComponents *minComponents = [NSDate dateComponentsFromDate:self.minimumDate];
        [self configData:minComponents];
    }else if (self.maximumDate && [date compare:self.maximumDate] == NSOrderedDescending) {
        NSDateComponents *maxComponents = [NSDate dateComponentsFromDate:self.maximumDate];
        [self configData:maxComponents];
        
    }
}

#pragma mark - Action
- (void)actionCancel:(UIBarButtonItem *)sender
{
    [self hide];
}

- (void)actionDone:(UIBarButtonItem *)sender
{
    if (_doneAction) {
        NSDate *date = [self getDateByPickerview];
        _doneAction(date);
    }
    [self hide];
}

//获取选择的时间
- (NSDate *)getDateByPickerview
{
    NSString *year = [NSString stringWithFormat:@"%ld",(long)_selectedYear];
    NSString *month = [NSString stringWithFormat:@"%ld",(long)_selectedMonth];
    NSString *day = [NSString stringWithFormat:@"%ld",(long)_selectedDay];
    NSString *hour = [NSString stringWithFormat:@"%ld",(long)_selectedHour];
    NSString *minute = [NSString stringWithFormat:@"%ld",(long)_selectedMinute];
    NSString *str = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",year,month,day,hour,minute];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [dateFormatter dateFromString:str];
    return date;
}

#pragma mark - Show/Dismiss
- (void)showView
{
    [self configPickView];
    UIViewController *vc = [self getCurrentViewController:self];
    PCDatePickerView *datePickerView = [self getPCDatePickerView];
    [UIView animateWithDuration:.3 animations:^{
        datePickerView.frame = CGRectMake(0, CGRectGetHeight(vc.view.frame) - self.frame.size.height, SCREEN_WIDTH, self.frame.size.height);
    }];
}

- (void)hide
{
    PCDatePickerView *datePickerView = [self getPCDatePickerView];
    UIViewController *vc = [self getCurrentViewController:self];
    [UIView animateWithDuration:0.3 animations:^{
        datePickerView.frame = CGRectMake(0, CGRectGetHeight(vc.view.frame), SCREEN_WIDTH, self.frame.size.height);
    }];

}
//获取当前显示的viewController
-(UIViewController *)getCurrentViewController:(UIView *) currentView
{
    for (UIView* next = [currentView superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (PCDatePickerView *)getPCDatePickerView
{
    UIViewController *vc = [self getCurrentViewController:self];
    NSArray *subViews = [vc.view subviews];
    PCDatePickerView *datePickerView = nil;
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[PCDatePickerView class]]) {
            datePickerView = (PCDatePickerView *)view;
            return datePickerView;
        }
    }
    return nil;
}

//显示view是配置相关属性
- (void)configPickView
{
    _dateView.backgroundColor = self.backGroundColor ? self.backGroundColor:PC_SEPARATOR_COLOR;
    NSDateComponents *components;
    if (self.date) {
        components = [NSDate dateComponentsFromDate:self.date];
    }else{
        components = [NSDate dateComponentsFromDate:nil];
    }
    if (self.minimumDate || self.maximumDate) {
        self.canChoicePastTime = YES;
    }
    if (!self.canChoicePastTime) {
        _currentYear = components.year;
        _currentMonth = components.month;
        _currentDay = components.day;
        _currentHour = components.hour;
        _currentMinute = components.minute;
    }
    [self configData:components];
}

- (void)configData:(NSDateComponents *)components
{
    [self.datePicker selectRow:components.year inComponent:0 animated:YES];
    [self.datePicker selectRow:components.month-1 + 4800 inComponent:1 animated:YES];
    [self.datePicker selectRow:components.day-1 + 6200 inComponent:2 animated:YES];
    [self.datePicker selectRow:components.hour + 4800 inComponent:3 animated:YES];
    [self.datePicker selectRow:components.minute + 6000 inComponent:4 animated:YES];
    _selectedYear = components.year;
    _selectedMonth = components.month;
    _selectedDay = components.day;
    _selectedHour = components.hour;
    _selectedMinute = components.minute;
    
}
@end

@implementation NSDate (PC)
+ (NSDateComponents *)dateComponentsFromDate:(NSDate *)date
{
    if (!date) {
        date = [NSDate date];
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *_dateComponents = [calendar components:self.UnitFlags fromDate:date];
    return _dateComponents;
}
/* 获取当前月的天数*/
+ (NSUInteger)getNumberOfDaysInMonth:(NSInteger)month Year:(NSInteger)year
{
    if((month == 1)||(month == 3)||(month == 5)||(month == 7)||(month == 8)||(month == 10)||(month == 12))
        return 31 ;
    if((month == 4)||(month == 6)||(month == 9)||(month == 11))
        return 30;
    if((year%4 == 1)||(year%4 == 2)||(year%4 == 3)){
        return 28;
    }
    if(year%400 == 0)return 29;
    if(year%100 == 0)return 28;
    return 29;
}

+ (unsigned)UnitFlags
{
    unsigned unitFlags = 0;
#ifdef isIOS8
    unitFlags = kCFCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|kCFCalendarUnitHour|kCFCalendarUnitMinute|kCFCalendarUnitSecond|NSCalendarUnitWeekday|kCFCalendarUnitWeekdayOrdinal;
#else
    unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit ;
#endif
    return unitFlags;
}
@end
