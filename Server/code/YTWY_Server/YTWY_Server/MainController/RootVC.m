//
//  RootVC.m
//  YTWY_Server
//
//  Created by 史秀泽 on 2016/7/26.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "RootVC.h"
#import "LoginViewController.h"
#import "FindPasswordVC.h"
#import "MainNavigationViewController.h"

@interface RootVC ()


@end

@implementation RootVC

-(instancetype)init
{
    if (self = [super init]) {
        [My_NoteCenter addObserver:self selector:@selector(netWorkChanged:) name:NetWorkChanged object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self customNVBar];
    
    [self showLogin:NO];
    
    self.keyboardUtil = [[ZYKeyboardUtil alloc] init];
    My_WeakSelf;
    [self.keyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(ZYKeyboardUtil *keyboardUtil) {
        [keyboardUtil adaptiveViewHandleWithController:weakSelf adaptiveView:weakSelf.view, nil];
    }];
    
    [My_NoteCenter addObserver:self selector:@selector(showLoginWithError) name:@"userError" object:nil];
}

-(void)showLoginWithError
{
    if (self == self.navigationController.topViewController && ![self isKindOfClass:[LoginViewController class]] && ![self isKindOfClass:[FindPasswordVC class]]) {
        [My_ServicesManager logOut:^{
            [self login:YES];
        }];
    }
}

-(void)showLogin:(BOOL)animated
{
    if (![My_ServicesManager isLogin]) {
        [self login:animated];
    }
}

-(void)login:(BOOL)animated
{
    LoginViewController *presentView = [[LoginViewController alloc]init];
    MainNavigationViewController* logInNav = [[MainNavigationViewController alloc]initWithRootViewController:presentView];
    
    [self.navigationController presentViewController:logInNav animated:animated completion:nil];
}

- (void)customNVBar{
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [button setBackgroundImage:[UIImage imageNamed:@"main_注销按钮"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(signOut)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)netWorkChanged:(NSNotification*)noti
{
    
}

- (void)signOut{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"退出登录" message:@"您确定要退出吗?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [My_ServicesManager logOut:^{
            [self.navigationController popViewControllerAnimated:YES];
            
            [self login:YES];
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:sure];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    [userdefaults setObject:nil forKey:@"RefrashRows"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
}

@end
