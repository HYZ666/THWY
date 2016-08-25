//
//  WRAlertView.m
//  THWY_Server
//
//  Created by HuangYiZhe on 16/8/25.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "WRAlertView.h"
@interface WRAlertView()<UIGestureRecognizerDelegate>
@property UITextField *title;
@property UITextView *textView;
@property UIButton *leftBtn;
@property UIButton *rightBtn;
@property NSInteger number;
@property UILabel *placeholderLabel;
@end
@implementation WRAlertView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.textView.text = @"";
        
        [self addSubview:self.title];
        
        CGFloat heighAndWidth = 50;
        
        self.leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, heighAndWidth, heighAndWidth)];
        [self.leftBtn setImage:[UIImage imageNamed:@"√"] forState:UIControlStateNormal];
        self.leftBtn.contentEdgeInsets = UIEdgeInsetsMake(15, 14.5,  15 , 14.5);
        [self addSubview:self.leftBtn];
        
        self.rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.right - heighAndWidth - 10, 0, heighAndWidth, heighAndWidth)];
        
        [self.rightBtn setImage:[UIImage imageNamed:@"X"] forState:UIControlStateNormal];
        //        self.rightBtn.backgroundColor = [UIColor blackColor];
        
        self.rightBtn.contentEdgeInsets = UIEdgeInsetsMake(15, 14.5,15, 14.5);
        
        
        [self.rightBtn addTarget:self action:@selector(clickRight) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightBtn];
        
        self.title = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.width - self.leftBtn.right * 2, 50)];
        self.number = 1;
        self.title.text = @"";
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.font = [UIFont systemFontOfSize:20];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.title.frame), self.width, 0.5)];
        label.backgroundColor = CellUnderLineColor;
        [self addSubview:label];
        
        self.textView = [[UITextView alloc]init];
        self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textView.textAlignment = NSTextAlignmentLeft;
        //        self.textView.font = FontSize(CONTENT_FONT);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide) name:UIKeyboardDidHideNotification object:nil];
        
        
    }
    return self;
}

- (void)clickRight
{
    [self hide];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

- (void)showInWindow
{
    if (self.superview == nil) {
        
        UIView *backgroundView = [[UIView alloc]initWithFrame:My_KeyWindow.bounds];
        backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        backgroundView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        tap.delegate = self;
        [backgroundView addGestureRecognizer:tap];
        [My_KeyWindow addSubview:backgroundView];
        
        self.center = backgroundView.center;
        
        [backgroundView addSubview:self];
        
    }
    
}

- (void)hide
{
    if (self.superview) {
        [self.superview removeFromSuperview];
    }
}

- (void)tap
{
    [self hide];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"AlerView"]) {
        return NO;
    }
    return  YES;
}

- (void)keyboardHide
{
    NSLog(@"收回键盘");
    
    [UIView animateWithDuration:0.2 animations:^{
        self.center = [self superview].center;
    }];
    
    
}

- (void)addLeftBtnTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.leftBtn addTarget:target action:action forControlEvents:controlEvents];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
