//
//  DPTestViewController.m
//  PetCommunity
//
//  Created by jinwenwu on 2017/8/28.
//  Copyright © 2017年 jinwenwu. All rights reserved.
//

#import "DPTestViewController.h"
#import "PCDatePickerView.h"

@interface DPTestViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITextField *monthTextField;
@property (weak, nonatomic) IBOutlet UITextField *dayTextField;
@property (weak, nonatomic) IBOutlet UITextField *hourTextField;
@property (weak, nonatomic) IBOutlet UITextField *minuteTextField;
@property (weak, nonatomic) IBOutlet UIButton *isSelectedBtn;
@property (weak, nonatomic) IBOutlet UITextField *minTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxTimeTextField;


@property (assign, nonatomic) BOOL isSelected;

@property (nonatomic, strong) PCDatePickerView *datePicker;
@end

@implementation DPTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datePicker = [[PCDatePickerView alloc] init];
    [self.view addSubview:self.datePicker];
    __weak __typeof(&*self) weakSelf = self;
    _datePicker.doneAction = ^(NSDate *date){
        [weakSelf sureDatePickerView:date];
    };
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)sureDatePickerView:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    self.dateLabel.text = strDate;
}


- (IBAction)canSelectPastTimeAction:(id)sender {
    [self.datePicker hide];
    self.isSelected = !self.isSelected;
    NSString *str = self.isSelected ? @"可选择":@"不可选择";
    [self.isSelectedBtn setTitle:str forState:UIControlStateNormal];
}


- (IBAction)btnAction:(id)sender {
    NSString *year = self.yearTextField.text;
    NSString *month = self.monthTextField.text;
    NSString *day = self.dayTextField.text;
    NSString *hour = self.hourTextField.text;
    NSString *minute = self.minuteTextField.text;
    NSString *time = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",year,month,day,hour,minute];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [dateFormatter dateFromString:time];
    self.datePicker.date =  date;
    NSString *minTime = self.minTimeTextField.text;
    NSDate *minDate = [dateFormatter dateFromString:minTime];
    self.datePicker.minimumDate = minDate;
    NSString *maxTime = self.maxTimeTextField.text;
    NSDate *maxDate = [dateFormatter dateFromString:maxTime];
    self.datePicker.maximumDate = maxDate;
    self.datePicker.canChoicePastTime = self.isSelected;
    [self.datePicker showView];
}
@end
