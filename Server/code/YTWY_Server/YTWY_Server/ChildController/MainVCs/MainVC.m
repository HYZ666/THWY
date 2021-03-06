//
//  MainVC.m
//  YTWY_Server
//
//  Created by 史秀泽 on 2016/7/26.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "MainVC.h"
#import "MainNavigationViewController.h"
#import "UserVO.h"
#import "UDManager.h"
//#import "PersonInfoViewController.h"
#import "DropMenuTableView.h"

#define topMargin  5.0/375*My_ScreenW

@interface MainVC ()<DropTableMenuDelegate>

@property (strong, nonatomic) UIButton *userInfoView;
@property (strong, nonatomic) UIImageView *headImage;
@property (strong, nonatomic) UILabel *username;
@property (strong, nonatomic) UILabel *addr;

@property (strong, nonatomic) DropMenuTableView *dropView;

@property (strong, nonatomic) UIButton *leftButton;

@property (strong, nonatomic) UIScrollView *bgScrollView;

@property (strong, nonatomic) NSDictionary *updateData;

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNVBar];
    [self initUserInfoView];
    [self initModuleViews];
    
    [My_NoteCenter addObserver:self selector:@selector(loginInFunc) name:Login_Success object:nil];
    [My_NoteCenter addObserver:self selector:@selector(versionUpdateFunc:) name:VersionUpdateInfo object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    if (My_ServicesManager.remoteNotification && [My_ServicesManager isLogin]) {
        [SVProgressHUD showWithStatus:@"正在加载数据,请稍等..."];
    }
    [self refreshUserInfo];
   
}

-(void)viewDidAppear:(BOOL)animated
{
    if (My_ServicesManager.remoteNotification && [My_ServicesManager isLogin]) {
        MainNavigationViewController* mainNav = (MainNavigationViewController* )self.navigationController;
        [mainNav popWithUserInfo:My_ServicesManager.remoteNotification];
        My_ServicesManager.remoteNotification = nil;
        [SVProgressHUD dismiss];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (self.dropView.superview) {
        [self leftItemOnclicked:self.leftButton];
    }
}

- (void)loginInFunc{
    //获取更新数据
    [My_ServicesManager getUpdate:^(NSString *errorMsg, BOOL haveUpdata, NSDictionary *data) {
        if(errorMsg){
        }else{
            if (data) {
                [[NSNotificationCenter defaultCenter] postNotificationName:VersionUpdateInfo object:nil userInfo:@{@"haveUpdate":@(haveUpdata),@"data":data}];
                //推送更新
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:data[@"title"] message:data[@"detail"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"前往更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@",APPID];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                }];
                [alert addAction:cancel];
                [alert addAction:confirm];
                
                UIViewController *vc = [UIViewController getCurrentVC];
                [vc presentViewController:alert animated:YES completion:^{
                    
                }];
                
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:VersionUpdateInfo object:nil userInfo:@{@"haveUpdate":@(haveUpdata)}];
            }
            
        }
    }];
    [self refreshUserInfo];
    
}

- (void)versionUpdateFunc:(NSNotification *)notification{
    BOOL haveUpdate = [notification.userInfo[@"haveUpdate"] boolValue];
    self.updateData = notification.userInfo[@"data"];
    if (haveUpdate) {
        [self.dropView refreshUpdateIcon:haveUpdate];
    }
    
}

- (void)getVersionUpdate{
    if (self.updateData) {
        //推送更新
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.updateData[@"title"] message:self.updateData[@"detail"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"前往更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *str = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@",APPID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }];
        [alert addAction:cancel];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"当前为最新版本" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:alert completion:^{
                    
                }];
            });
        }];
    }
    
}

- (void)refreshUserInfo{
    
    if ([UDManager getUD].getUser) {
        UserVO *user = [UDManager getUD].getUser;
        if (user.photo.length > 0) {
            [self.headImage sd_setImageWithURL:[NSURL URLWithString: user.photo] placeholderImage:[UIImage imageNamed:@"头像1"]];
        }else
        {
            self.headImage.image = [UIImage imageNamed:@"Avatar"];
        }
        self.username.text = user.real_name;
        self.addr.text = [user.up_group project];
    }
    
    if ([My_ServicesManager isLogin]) {
        [My_ServicesManager getUserInfoOnComplete:^(NSString *errorMsg, UserVO *user) {
            if (errorMsg) {
                [SVProgressHUD showErrorWithStatus:errorMsg];
                return ;
            }
            
            if (user) {
                if (user.photo.length > 0) {
                    
                    [self.headImage sd_setImageWithURL:[NSURL URLWithString: user.photo] placeholderImage:[UIImage imageNamed:@"头像1"]];
                }else
                {
                    self.headImage.image = [UIImage imageNamed:@"Avatar"];
                }
                self.username.text = user.real_name;
                self.addr.text = [user.up_group project];
            }
        }];
    }
    
}

- (void)initNVBar{
    self.title = @"业主客服系统";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [self.leftButton setImage:[UIImage imageNamed:@"main_快捷菜单"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(leftItemOnclicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    self.navigationItem.leftBarButtonItem  = left;
    
    self.dropView = [[DropMenuTableView alloc] initWithWidth:145.f itemHeight:45.f itemNames:@[@"我要报修", @"物业公告", @"账号信息", @"推送设置", @"技术支持"] ItemImages:@[@"main_1", @"main_2", @"main_6", @"main_4", @"main_5"]];
    self.dropView.backColor = My_Color(2, 134, 200);
    self.dropView.textColor = [UIColor whiteColor];
    
    self.dropView.dropDelegate = self;
}

- (void)leftItemOnclicked:(UIButton *)button{
    
    if (self.dropView.superview) {
        [self.dropView removeFromSuperview];
        [self.leftButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        return;
    }else{
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [window addSubview:self.dropView];
        [self.leftButton setBackgroundImage:[UIImage imageNamed:@"main_anxia"] forState:UIControlStateNormal];
    }
}

- (void)itemSelected:(NSInteger)index{
    UIButton *button = [[UIButton alloc] init];
    button.tag = 0;
    switch (index) {
        case 0:{
            button.tag = 101;
            [self showVC:button];
            break;
        }
        case 1:{
            button.tag = 107;
            [self showVC:button];
            break;
        }
        case 2:{
            button.tag = 110;
            [self showVC:button];
            break;
        }
        case 3:{
            button.tag = 111;
            [self showVC:button];
            break;
        }
        case 4:{
            button.tag = 112;
            [self showVC:button];
            break;
        }
        case 5:{
            [self getVersionUpdate];
            break;
        }
        default:
            break;
    }
    [self.dropView removeFromSuperview];
    [self.leftButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];

}

- (void)dropMenuHidden{
    [self.leftButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
}

#pragma mark - UserInfo
//用户信息
- (void)initUserInfoView{
    
    self.userInfoView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, My_ScreenW, 1/4.0 * My_ScreenH - topMargin*2)];
    [self.userInfoView setBackgroundImage:[UIImage imageNamed:@"main_背景"] forState:UIControlStateNormal];
    [self.userInfoView addTarget:self action:@selector(showUserInfoVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.userInfoView];
    
    self.headImage = [[UIImageView alloc] init];
    self.headImage.image = [UIImage imageNamed:@"Avatar"];
    self.headImage.userInteractionEnabled = NO;
    self.headImage.layer.cornerRadius = self.userInfoView.bounds.size.height/3;
    [self.userInfoView addSubview:self.headImage];
    
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.userInfoView.mas_centerY);
        make.left.mas_equalTo(self.userInfoView).offset(30/375.0*My_ScreenW);
        make.height.mas_equalTo(self.userInfoView.mas_height).multipliedBy(0.7);
        make.width.mas_equalTo(self.headImage.mas_height);
    }];
    [self.view layoutIfNeeded];
    self.headImage.clipsToBounds = YES;
    
    self.username = [[UILabel alloc] init];
    self.username.font = FontBoldSize(CONTENT_FONT+3);
    self.username.textColor = My_Color(44, 191, 114);
    [self.userInfoView addSubview:self.username];
    
    [self.username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headImage.mas_centerY).multipliedBy(0.8);
        make.left.mas_equalTo(self.headImage.mas_right).offset(15);
    }];
    
    self.addr = [[UILabel alloc] init];
    self.addr.font = FontBoldSize(CONTENT_FONT+5);
    self.addr.textColor = My_Color(44, 191, 114);
    [self.userInfoView addSubview:self.addr];
    [self.addr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.username.mas_left);
        make.top.mas_equalTo(self.username.mas_bottom).offset(6);
    }];
    
    UIImageView *more = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_箭头"]];
    [self.userInfoView addSubview:more];
    [more mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userInfoView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(12, 20));
        make.right.mas_equalTo(self.userInfoView.mas_right).offset(-30);
    }];

}

#pragma mark - 各模块控件
- (void)initModuleViews{
    
    self.bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.userInfoView.bottom + 2.5/375.0*My_ScreenW, self.view.width, 3/4.0 * (My_ScreenH-64)+2*topMargin)];
    self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.width, (My_ScreenW-3*topMargin)*0.5/297*170.0*2 + (My_ScreenW-3*topMargin)*0.5 * 1.19 + topMargin*9);
    self.bgScrollView.backgroundColor = [UIColor clearColor];
    self.bgScrollView.showsVerticalScrollIndicator = NO;
    self.bgScrollView.showsHorizontalScrollIndicator = NO;
    self.bgScrollView.bounces = NO;
    [self.view addSubview:self.bgScrollView];
    
    UIButton *woyaobaoxiu = [[UIButton alloc] init];
    woyaobaoxiu.tag = 101;
    [woyaobaoxiu setBackgroundImage:[UIImage imageNamed:@"main_我要报修"] forState:UIControlStateNormal];
    [woyaobaoxiu setBackgroundImage:[UIImage imageNamed:@"main_我要报修按下"] forState:UIControlStateHighlighted];
    [self.bgScrollView addSubview:woyaobaoxiu];
    [woyaobaoxiu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgScrollView.mas_left).offset(topMargin);
        make.top.mas_equalTo(self.bgScrollView.mas_top).offset(topMargin);
        make.size.mas_equalTo(CGSizeMake((My_ScreenW-3*topMargin)*0.5, (My_ScreenW-3*topMargin)*0.5/297*170.0));
    }];
    
    UIButton *baoxiujilu = [[UIButton alloc] init];
    baoxiujilu.tag = 102;
    [baoxiujilu setBackgroundImage:[UIImage imageNamed:@"main_报修记录"] forState:UIControlStateNormal];
    [baoxiujilu setBackgroundImage:[UIImage imageNamed:@"main_报修记录按下"] forState:UIControlStateHighlighted];
    [self.bgScrollView addSubview:baoxiujilu];
    [baoxiujilu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(woyaobaoxiu.mas_left);
        make.top.mas_equalTo(woyaobaoxiu.mas_bottom).offset(topMargin*1.3);
        make.width.and.height.mas_equalTo(woyaobaoxiu);
    }];
    
    UIButton *gongzuorizhi = [[UIButton alloc] init];
    gongzuorizhi.tag = 103;
    [gongzuorizhi setBackgroundImage:[UIImage imageNamed:@"main_工作日志"] forState:UIControlStateNormal];
    [gongzuorizhi setBackgroundImage:[UIImage imageNamed:@"main_工作日志按下"] forState:UIControlStateHighlighted];
    [self.bgScrollView addSubview:gongzuorizhi];
    [gongzuorizhi mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(baoxiujilu.mas_left);
        make.top.mas_equalTo(baoxiujilu.mas_bottom).offset(topMargin*1.3);
        make.width.mas_equalTo(woyaobaoxiu.mas_width);
        make.height.mas_equalTo(baoxiujilu.mas_width).multipliedBy(1.19);
    }];
    
    UIButton *baoxiujiedan = [[UIButton alloc] init];
    baoxiujiedan.tag = 104;
    [baoxiujiedan setBackgroundImage:[UIImage imageNamed:@"main_报修接单"] forState:UIControlStateNormal];
    [baoxiujiedan setBackgroundImage:[UIImage imageNamed:@"main_报修接单按下"] forState:UIControlStateHighlighted];
    [self.bgScrollView addSubview:baoxiujiedan];
    [baoxiujiedan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(woyaobaoxiu.mas_right).offset(topMargin);
        make.top.mas_equalTo(woyaobaoxiu.mas_top);
        make.height.mas_equalTo(baoxiujilu);
        make.width.mas_equalTo(baoxiujilu.mas_width).multipliedBy(0.5).offset(-topMargin*0.5);
    }];
    
    UIButton *baoxiutongji = [[UIButton alloc] init];
    baoxiutongji.tag = 105;
    [baoxiutongji setBackgroundImage:[UIImage imageNamed:@"main_报修统计"] forState:UIControlStateNormal];
    [baoxiutongji setBackgroundImage:[UIImage imageNamed:@"main_报修统计按下"] forState:UIControlStateHighlighted];
    [self.bgScrollView addSubview:baoxiutongji];
    [baoxiutongji mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(baoxiujiedan.mas_right).offset(topMargin);
        make.top.mas_equalTo(woyaobaoxiu.mas_top);
        make.width.and.height.mas_equalTo(baoxiujiedan);
    }];
    
    UIButton *wodehaoyou = [[UIButton alloc] init];
    wodehaoyou.tag = 106;
    [wodehaoyou setBackgroundImage:[UIImage imageNamed:@"main_我的好友"] forState:UIControlStateNormal];
    [wodehaoyou setBackgroundImage:[UIImage imageNamed:@"main_我的好友按下"] forState:UIControlStateHighlighted];
    [self.bgScrollView addSubview:wodehaoyou];
    [wodehaoyou mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(baoxiujilu.mas_right).offset(topMargin);
        make.top.mas_equalTo(baoxiujilu.mas_top);
        make.height.mas_equalTo(baoxiujilu);
        make.width.mas_equalTo(baoxiujilu.mas_width).multipliedBy(0.5).offset(-topMargin*0.5);
    }];
    
    UIButton *wuyegonggao = [[UIButton alloc] init];
    wuyegonggao.tag = 107;
    [wuyegonggao setBackgroundImage:[UIImage imageNamed:@"main_物业公告"] forState:UIControlStateNormal];
    [wuyegonggao setBackgroundImage:[UIImage imageNamed:@"main_物业公告按下"] forState:UIControlStateHighlighted];
    [self.bgScrollView addSubview:wuyegonggao];
    [wuyegonggao mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wodehaoyou.mas_right).offset(topMargin);
        make.top.mas_equalTo(wodehaoyou.mas_top);
        make.width.and.height.mas_equalTo(wodehaoyou);
    }];
    
    UIButton *xindebiji = [[UIButton alloc] init];
    xindebiji.tag = 108;
    [xindebiji setBackgroundImage:[UIImage imageNamed:@"main_心得笔记"] forState:UIControlStateNormal];
    [xindebiji setBackgroundImage:[UIImage imageNamed:@"main_心得笔记按下"] forState:UIControlStateHighlighted];
    [self.bgScrollView addSubview:xindebiji];
    [xindebiji mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(baoxiujiedan.mas_left);
        make.top.mas_equalTo(gongzuorizhi.mas_top);
        make.width.mas_equalTo(woyaobaoxiu);
        make.height.mas_equalTo(gongzuorizhi.mas_height).multipliedBy(0.5).offset(-topMargin*0.5);
    }];
    
    UIButton *ipbaimingdan = [[UIButton alloc] init];
    ipbaimingdan.tag = 109;
    [ipbaimingdan setBackgroundImage:[UIImage imageNamed:@"main_ip白名单"] forState:UIControlStateNormal];
    [ipbaimingdan setBackgroundImage:[UIImage imageNamed:@"main_ip白名单按下"] forState:UIControlStateHighlighted];
    [self.bgScrollView addSubview:ipbaimingdan];
    [ipbaimingdan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(xindebiji.mas_left);
        make.top.mas_equalTo(xindebiji.mas_bottom).offset(topMargin);
        make.width.and.height.mas_equalTo(xindebiji);
    }];

    
    NSArray *buttons = @[woyaobaoxiu, baoxiujilu, gongzuorizhi, baoxiujiedan, baoxiutongji, wodehaoyou, wuyegonggao, xindebiji, ipbaimingdan];
    for (UIButton *button in buttons) {
        [button addTarget:self action:@selector(showVC:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}
//pushVC
- (void)showVC:(UIButton *)button{
//    if (button.tag-101 == 0) {
//        [SVProgressHUD showWithStatus:@"加载中..."];
//    }
    
    NSArray *VCNames = @[@"WantRepairesVC",//我要报修 101
                         @"RepairRecordsVC",//报修记录 102
                         @"WorkRecordViewController",//工作日志 103
                         @"RepairAcceptOrderVC",//报修接单 104
                         @"RepairStatistisVC",//报修统计 105
                         @"MyFriendViewController",//我的好友 106
                         @"ProclamationViewController",//物业公告 107
                         @"NoteBookViewController",//心得笔记 108
                         @"WhiteListViewController",//ip白名单 109
                         @"PersonInfoViewController",//个人信息 110
                         @"PushSettingVC",//推送设置 //111
                         @"TechSupportVC"];//技术支持 //112
    
    id vc = [[NSClassFromString(VCNames[button.tag-101]) alloc]init];
    
    if (vc) {
        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    }else{
        NSLog(@"vc  is  nill");
    }
}

- (void)showUserInfoVC{
    UIButton *button = [[UIButton alloc] init];
    button.tag = 110;
    [self showVC:button];
}

- (void)signOut{
    [self.dropView removeFromSuperview];
    [super signOut];
}

- (void)dealloc{
    [My_NoteCenter removeObserver:self name:Login_Success object:nil];
    [My_NoteCenter removeObserver:self name:VersionUpdateInfo object:nil];
}

#pragma  mark - MemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
