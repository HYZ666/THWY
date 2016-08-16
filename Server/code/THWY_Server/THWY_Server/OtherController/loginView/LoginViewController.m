//
//  LoginViewController.m
//  THWY_Client
//
//  Created by HuangYiZhe on 16/7/27.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "LoginViewController.h"
#import "Masonry.h"
#import "UIView+Extension.h"
#import "userAndPassWordTextField.h"
#import "BlueCheckButton.h"
#import "ServicesManager.h"
#import "MainVC.h"
@interface LoginViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UIScrollView* introScrollView;
@property ZYKeyboardUtil* keyboardUtil;
@property UIImageView *LogoView;
@property userAndPassWordTextField *userTF;
@property userAndPassWordTextField *passWordTF;
@property BlueCheckButton *rememberPassWordBtn;
@property BlueCheckButton *findPsdBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.keyboardUtil = [[ZYKeyboardUtil alloc] init];
    My_WeakSelf;
    [self.keyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(ZYKeyboardUtil *keyboardUtil) {
        [keyboardUtil adaptiveViewHandleWithController:weakSelf adaptiveView:weakSelf.view, nil];
    }];
    
    [self showIntroView];
    
    [self ViewInitSetting];
    [self createLogoImageView];
    [self createUserAndPasswordTextfiled];
    [self createButton];
}


-(void)showIntroView
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud objectForKey:@"DidLaunch"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ud setObject:[NSNumber numberWithBool:YES] forKey:@"DidLaunch"];
            [ud synchronize];
        });
        self.introScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, My_ScreenW, My_ScreenH)];
        self.introScrollView.bounces = NO;
        self.introScrollView.backgroundColor = My_clearColor;
        self.introScrollView.contentSize = CGSizeMake(My_ScreenW * 4, My_ScreenH);
        self.introScrollView.pagingEnabled = YES;
        self.introScrollView.showsVerticalScrollIndicator = NO;
        self.introScrollView.showsHorizontalScrollIndicator = NO;
        
        for (int i = 0; i<4; i++) {
            NSString* imageName = [NSString stringWithFormat:@"yitai引导页%d",i+1];
            UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*self.introScrollView.width, 0, self.introScrollView.width, self.introScrollView.height)];
            imageView.image = [UIImage imageNamed:imageName];
            
            if (i == 3) {
                imageView.userInteractionEnabled = YES;
                UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(0, imageView.height/9*7, imageView.width/2, imageView.height/10)];
                button.backgroundColor = My_AlphaColor(0.1, 0.1, 0.1, 0.0001);
                button.x = imageView.width/2 - button.width/2;
                [button addTarget:self action:@selector(tapOnLastImage:) forControlEvents:UIControlEventTouchUpInside];
                [imageView addSubview:button];
            }
            [self.introScrollView addSubview:imageView];
            
        }
        [My_KeyWindow addSubview:self.introScrollView];
    }
}

-(void)tapOnLastImage:(UIButton* )sender
{
    sender.enabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.introScrollView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.introScrollView removeFromSuperview];
    }];
}

- (void)ViewInitSetting
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    
    backgroundImageView.image = [UIImage imageNamed:@"大背景"];
    
    [self.view addSubview:backgroundImageView];
}

- (void)createLogoImageView
{
    self.LogoView = [[UIImageView alloc]init];
    
    self.LogoView.image = [UIImage imageNamed:@"yitailogo"];
    
    [self.view addSubview:self.LogoView];
    
    [self.LogoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.view.height * 0.1);
        make.width.mas_equalTo(self.view.width *0.6);
        make.height.equalTo(@28);
    }];
}

- (void)createUserAndPasswordTextfiled
{
    CGFloat userAndPassWordTFWidth = self.view.width *0.9;
    CGFloat userTFTop = self.view.height * 0.1;
    CGFloat userAndPassWordHeight = self.view.height * 0.08;
    
    UIView *TFbackgroundView = [[UIView alloc]init];
    
    TFbackgroundView.layer.cornerRadius = 5;
    TFbackgroundView.clipsToBounds = YES;
    
//    TFbackgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:TFbackgroundView];
    
    [TFbackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.LogoView.mas_bottom).with.offset(userTFTop);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(userAndPassWordTFWidth);
        make.height.mas_equalTo(userAndPassWordHeight *2 +1);
        
    }];
    
    self.userTF =[[userAndPassWordTextField alloc]initWithFrame:CGRectMake(0, 0, userAndPassWordTFWidth, userAndPassWordHeight)];
    self.userTF.delegate = self;
    [TFbackgroundView addSubview:self.userTF];
    

    
//    [self.userTF mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.LogoView.mas_bottom).with.offset(userTFTop);
//        make.centerX.equalTo(self.view.mas_centerX);
//        make.width.mas_equalTo(userAndPassWordTFWidth);
//        make.height.mas_equalTo(userAndPassWordHeight);
//
//    }];
    
    [self.userTF setLeftIcon:@"账号" placeholder:@"请输入账号" backgroundColor:[UIColor whiteColor]];
    
    self.userTF.text = [[UDManager getUD]getUserName];
    
    NSLog(@"%@",[[UDManager getUD]getUserName]);
    NSLog(@"%@",[[UDManager getUD]getPassWord]);
    
    self.passWordTF =[[userAndPassWordTextField alloc]initWithFrame:CGRectMake(0, self.userTF.bottom + 1, userAndPassWordTFWidth, userAndPassWordHeight)];
    self.passWordTF.delegate = self;
    [self.passWordTF setSecureTextEntry:YES];
    [TFbackgroundView addSubview:self.passWordTF];
    
    
//    [self.passWordTF mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.userTF.mas_bottom).with.offset(passWordTFTop);
//        make.centerX.equalTo(self.view.mas_centerX);
//        make.width.mas_equalTo(userAndPassWordTFWidth);
//        make.height.mas_equalTo(userAndPassWordHeight);
//    }];
    
    [self.passWordTF setLeftIcon:@"登录密码" placeholder:@"请输入密码" backgroundColor:[UIColor whiteColor]];
    
    if ([[UDManager getUD]showPassWord]) {
        self.passWordTF.text = [[UDManager getUD]getPassWord];
    }
}

- (void)createButton
{
    self.rememberPassWordBtn = [[BlueCheckButton alloc]initDefaultImageName:@"框不带勾" choosedImageName:@"框带勾" title:@"记住密码"];
    self.rememberPassWordBtn.chooseStatu = [[UDManager getUD]showPassWord];
    [self.view addSubview:self.rememberPassWordBtn];

    CGFloat rememberPassWordBtnLeft = self.view.width *0.056;
    CGFloat topOffset = self.view.height * 0.03;
    CGFloat rememberPassWordBtnWidth = self.view.width *0.26;
    CGFloat rememberPassWordBtnHeight = self.view.height *0.02;
    
    [self.rememberPassWordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rememberPassWordBtnLeft);
        make.top.equalTo(self.passWordTF.mas_bottom).with.offset(topOffset);
        make.width.mas_equalTo(rememberPassWordBtnWidth);
        make.height.mas_equalTo(rememberPassWordBtnHeight);
    }];
    
    self.rememberPassWordBtn.titleLabel.font = [UIFont systemFontOfSize:rememberPassWordBtnHeight];

    
    [self.rememberPassWordBtn addTarget:self action:@selector(clickRememberPassWordBtn) forControlEvents:UIControlEventTouchUpInside];
    
    self.findPsdBtn = [[BlueCheckButton alloc]initDefaultImageName:@"" choosedImageName:@"" title:@"密码找回"];
    [self.view addSubview:self.findPsdBtn];
    
    //隐藏按钮
    self.findPsdBtn.alpha = 0;
    CGFloat adminLoginBtnRightOffset = -self.view.width *0.036;
    CGFloat adminLoginBtnWidth = self.view.width *0.2;
    CGFloat adminLoginBtnHeight = self.view.height *0.02;
    
    [self.findPsdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).with.offset(adminLoginBtnRightOffset);
        make.top.equalTo(self.passWordTF.mas_bottom).with.offset(topOffset);
        make.width.mas_equalTo(adminLoginBtnWidth);
        make.height.mas_equalTo(adminLoginBtnHeight);
    }];
    
    self.findPsdBtn.titleLabel.font = [UIFont systemFontOfSize:adminLoginBtnHeight];
    
    
    [self.findPsdBtn addTarget:self action:@selector(clickAdminLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *LoginBtn = [[UIButton alloc]init];
    
    [LoginBtn setImage:[UIImage imageNamed:@"登录"] forState:UIControlStateNormal];
    [LoginBtn setImage:[UIImage imageNamed:@"登录按下"] forState:UIControlStateHighlighted];
    
    [self.view addSubview:LoginBtn];
    
    CGFloat LoginBtnBottomOffset = -self.view.height * 0.4;
    CGFloat LoginBtnWidth = self.view.width * 0.8;
    CGFloat LoginBtnHeight = self.view.height * 0.08;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, LoginBtnWidth, LoginBtnHeight)];
    label.text = @"登录";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:label.height/2.668];
    [LoginBtn addSubview:label];
    
    [LoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(LoginBtnBottomOffset);
        make.width.mas_equalTo(LoginBtnWidth);
        make.height.mas_equalTo(LoginBtnHeight);
    }];
    
    [LoginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];

}

- (void)clickAdminLoginBtn
{
    NSLog(@"密码找回");
}

- (void)clickRememberPassWordBtn
{
    [self.rememberPassWordBtn click];
}
- (void)login
{
    if (self.userTF.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入用户名"];
        [self.userTF becomeFirstResponder];
        return;
    }
    
    if (self.passWordTF.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        [self.passWordTF becomeFirstResponder];
        return;
    }
    if (self.userTF.isEditing) {
        [self.userTF endEditing:YES];
    }
    if (self.passWordTF.isEditing) {
        [self.passWordTF endEditing:YES];
    }
    
    [SVProgressHUD showWithStatus:@"登录中..."];
    [[ServicesManager getAPI] login:self.userTF.text password:self.passWordTF.text savePassWord:self.rememberPassWordBtn.chooseStatu onComplete:^(NSString *errorMsg, UserVO *user) {
        NSLog(@"%@",user);
        if (errorMsg) {
            NSLog(@"%@",errorMsg);
            
            [SVProgressHUD showErrorWithStatus:errorMsg];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:Login_Fail object:nil];

        }
        else {
            
            [SVProgressHUD dismiss];
            [[NSNotificationCenter defaultCenter] postNotificationName:Login_Success object:nil];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }];

}

#pragma mark --文本框代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            
            UITextField *textField = (UITextField *)view;
            
            [textField resignFirstResponder];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end