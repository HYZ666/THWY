//
//  AlerView.m
//  THWY_Server
//
//  Created by HuangYiZhe on 16/8/24.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "AlerView.h"
#import "ServicesManager.h"
#import "SVProgressHUD.h"
@interface AlerView()<UIGestureRecognizerDelegate,UITextFieldDelegate>
@property UITextField *userTF;
@property NSMutableArray *ipTFArray;
@property UIButton *btn;
@end
@implementation AlerView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide) name:UIKeyboardDidHideNotification object:nil];
        [self addObserver:self forKeyPath:@"method" options:NSKeyValueObservingOptionNew context:nil];
        self.ipTFArray = [NSMutableArray array];
        
        CGFloat left = 10;
        CGFloat top = 10;
        CGFloat width = self.width - left * 2;
        CGFloat height = 35;
        UILabel *userLabel = [[UILabel alloc]initWithFrame:CGRectMake(left, top, width, height)];
        userLabel.text = @"使用者";
        userLabel.font = FontSize(CONTENT_FONT);

        userLabel.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:userLabel];
        
        self.userTF = [[UITextField alloc]initWithFrame:CGRectMake(left, userLabel.bottom + top, width, height)];
        self.userTF.layer.borderWidth = 0.5;
        self.userTF.layer.borderColor = CellUnderLineColor.CGColor;
        self.userTF.delegate = self;
        self.userTF.tag = 301;
        [self addSubview:self.userTF];
        
        UILabel *ipLabel = [[UILabel alloc]initWithFrame:CGRectMake(left, self.userTF.bottom + top, width, height)];
        
        ipLabel.text = @"IP地址";
        ipLabel.font = FontSize(CONTENT_FONT);
        ipLabel.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:ipLabel];
        
        CGFloat tf_L = 10;
        CGFloat tf_W = self.width/7.5;
        CGFloat tf_H = 35;
        CGFloat tf_Y =ipLabel.bottom + 10;
        
        int ipTfTag = 302;
        
        for (int i = 0; i < 7; i ++) {
            if (i % 2 == 0) {
                
                UITextField *ipTF = [[UITextField alloc]initWithFrame:CGRectMake(tf_L + tf_W * i, tf_Y, tf_W, tf_H)];
                ipTF.layer.borderWidth = 0.5;
                ipTF.layer.borderColor = CellUnderLineColor.CGColor;
                ipTF.delegate = self;
                ipTF.keyboardType = UIKeyboardTypeNumberPad;
                ipTF.textAlignment = NSTextAlignmentCenter;
                ipTF.tag = ipTfTag;
                ipTfTag ++;
                [ipTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                
                if (i != 6) {
                    ipTF.returnKeyType = UIReturnKeyNext;
                }
                else
                {
                    ipTF.returnKeyType = UIReturnKeyDone;
                }
                [self.ipTFArray addObject:ipTF];
                
                [self addSubview:ipTF];
            }
            else if (i % 2 == 1)
            {
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(tf_L + tf_W * i, tf_Y, tf_W, tf_H)];
                label.text = @"—";
                label.textAlignment = NSTextAlignmentCenter;
                
                [self addSubview:label];
            }
        }
        
        UITextField *temp = [self.ipTFArray firstObject];
        
        CGFloat btnY = temp.bottom + 25;
        
        self.btn = [[UIButton alloc]initWithFrame:CGRectMake(left, btnY, width, 40)];
        
        self.btn.backgroundColor = My_NAV_BG_Color;
        
        [self.btn setTitle:@"添加" forState:UIControlStateNormal];
        
        [self addSubview:self.btn];
        
        [self.btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
        
        
        self.height = self.btn.bottom + 25;
        
        self.backgroundColor = [UIColor whiteColor];

    }
    return self;
}

- (void)clickBtn
{
//    NSLog(@"添加");
    
    BOOL isError = NO;
    
    if (self.method == Edit) {
        
        IPAllowVO *temp = [[IPAllowVO alloc]init];
        temp.Id = self.allowId;
        temp.the_user = self.userTF.text;
        NSMutableString *ipString = [[NSMutableString alloc]init];
        for (int i = 0 ;i < self.ipTFArray.count; i ++) {
            
            UITextField *temp = self.ipTFArray[i];
//            if (temp.text.length ==0) {
//                [SVProgressHUD showErrorWithStatus:@"ip地址格式错误"];
//                isError = YES;
//            }
            [ipString appendString:temp.text];
            if (i != self.ipTFArray.count - 1) {
                [ipString appendString:@"."];
            }
            
        }
        temp.ip = ipString;
        if (!isError) {
            [[ServicesManager getAPI]editAIpAllow:temp onComplete:^(NSString *errorMsg) {
                [self endEditing:YES];
                if (errorMsg) {
                    [SVProgressHUD showErrorWithStatus:errorMsg];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PostSuccess" object:nil];
                    [self hide];
                }
                
            }];
        }
        
    }
    else
    {
        IPAllowVO *temp = [[IPAllowVO alloc]init];
        temp.the_user = self.userTF.text;
        NSMutableString *ipString = [[NSMutableString alloc]init];
        for (int i = 0 ;i < self.ipTFArray.count; i ++) {
            
            UITextField *temp = self.ipTFArray[i];
//            if (temp.text.length ==0 || [temp.text intValue] >255) {
//                [SVProgressHUD showErrorWithStatus:@"ip地址格式错误"];
//                isError = YES;
//            }
            [ipString appendString:temp.text];
            if (i != self.ipTFArray.count - 1) {
                [ipString appendString:@"."];
            }
            
        }
        temp.ip = ipString;
        if (!isError) {
            [[ServicesManager getAPI] addAIpAllow:temp onComplete:^(NSString *errorMsg) {
                [self endEditing:YES];
                if (errorMsg) {
                    [SVProgressHUD showErrorWithStatus:errorMsg];
                }
                
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PostSuccess" object:nil];
                    [self hide];
                }
                
            }];
        }
        
    }
    
}

- (void)setUser:(NSString *)user IP:(NSString *)ip
{
    self.userTF.text = user;
    self.userTF.font = FontSize(CONTENT_FONT);
    
    NSArray *ipArray = [ip componentsSeparatedByString:@"."];
    
    for (int i = 0; i < self.ipTFArray.count; i ++) {
        UITextField *temp = self.ipTFArray[i];
        
        temp.text = ipArray[i];
        temp.font = FontSize(CONTENT_FONT);
    }
    
    
    
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
//    [self hide];
    [self endEditing:YES];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"AlerView"]) {
        return NO;
    }
    return  YES;
}
#pragma mark -- uitextfield代理方法
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (void)textFieldDidChange:(UITextField *)textfield
{
    if (textfield.text.length >= 3 && textfield.tag != 301) {
       textfield.text = [textfield.text substringToIndex:3];
        
        if (textfield.tag < 305) {
            UITextField *tempTf = [self viewWithTag:textfield.tag + 1];
            
            [tempTf becomeFirstResponder];
        }
        
    }
}

#pragma 键盘监听
- (void)keyboardShow:(NSNotification *)notification
{
    NSLog(@"弹出键盘");
    
    NSDictionary *info = notification.userInfo;
    
    NSValue *value = [info valueForKey:UIKeyboardFrameBeginUserInfoKey];
    
    CGRect rect = [value CGRectValue];
    
    NSLog(@"------------keyboradHeight%f,self.frame.y%f,self.frame.bottom%f",rect.size.height,self.y,self.bottom);
    
    
    
    if ([UIScreen mainScreen].bounds.size.height - rect.size.height - self.height - 40 > 20 ) {
        
        self.y = [UIScreen mainScreen].bounds.size.height - rect.size.height - self.height - 40;
    }
    else
    {
        self.y = 20;
    }
    
}

- (void)keyboardHide
{
    [UIView animateWithDuration:0.3 animations:^{
        self.center = self.superview.center;

    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (self.method == Edit ) {
        
        [self.btn setTitle:@"修改" forState:UIControlStateNormal];
    }
    else
    {
        [self.btn setTitle:@"添加" forState:UIControlStateNormal];

    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"method"];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
