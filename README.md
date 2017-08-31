# PCDatePicker
五级时间选择器（年月日时分）


# 效果展示

![默认效果.gif](http://upload-images.jianshu.io/upload_images/2633493-233a160705043cb8.gif?imageMogr2/auto-orient/strip)


![手动设置时间.gif](http://upload-images.jianshu.io/upload_images/2633493-836385b2acae4448.gif?imageMogr2/auto-orient/strip)


![最大最小时间.gif](http://upload-images.jianshu.io/upload_images/2633493-14588613abf6885c.gif?imageMogr2/auto-orient/strip)

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

