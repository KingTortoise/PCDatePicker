# PCDatePicker
五级时间选择器（年月日时分）


# 效果展示

![默认效果.gif](https://github.com/KingTortoise/PCDatePicker/blob/master/gif/%E9%BB%98%E8%AE%A4%E6%95%88%E6%9E%9C.gif)


![手动设置时间.gif](https://github.com/KingTortoise/PCDatePicker/blob/master/gif/%E6%89%8B%E5%8A%A8%E8%AE%BE%E7%BD%AE%E6%97%B6%E9%97%B4.gif)


![最大最小时间.gif](https://github.com/KingTortoise/PCDatePicker/blob/master/gif/%E6%9C%80%E5%A4%A7%E6%9C%80%E5%B0%8F%E6%97%B6%E9%97%B4.gif)

# 相关属性
## 常用属性 ##
maximumDate: 最大值<br />
minimumDate: 最小值<br />
date: 用于手动设置时间<br />
doneAction: 用于回调<br />
canChoicePastTime: 是否可以选择过去的时间 默认是NO(不可选)<br />
backGroundColor: 选择器背景颜色<br />

## 常用方法 ## 
-(void)hide; 隐藏视图<br /> 
-(void)showView; 显示视图<br />

# 使用实例
```
PCDatePickerView *datePicker = [[PCDatePickerView alloc]init];
[self.view addSubViews:datePicker]; 

NSString *time = @"2017-08-31 15:06";
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
NSDate *date = [dateFormatter dateFromString:time];
datePicker.date =  date;

NSString *minTime = @"2000-12-21 08:10";
NSDate *minDate = [dateFormatter dateFromString:minTime];
datePicker.minimumDate = minDate;

NSString *maxTime = @"2030-05-05 11:11";
NSDate *maxDate = [dateFormatter dateFromString:maxTime];
datePicker.maximumDate = maxDate;

datePicker.canChoicePastTime = self.isSelected;

[datePicker showView];
```
# 总结
无论是几级的选择器，基本的原理是一样的，但是随着级数的增加，其中的逻辑处理也会增加。

# 简书地址 <br />
如果觉得对你还有些用，给一颗star吧。你的支持是我继续的动力。<br />
[Github地址](https://github.com/KingTortoise/PCDatePicker.git)<br />
[简书地址](http://www.jianshu.com/p/176c66c7f841)

