//
//  WorkRecordViewController.m
//  THWY_Server
//
//  Created by HuangYiZhe on 16/8/23.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "WorkRecordViewController.h"

#import "Masonry.h"
#import "ProclamationTableViewCell.h"
#import "ProclamationInfoViewController.h"
#import "ReviseBtn.h"
#define TopViewH 60
@interface WorkRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
@property UITableView *tableView;
@property UISegmentedControl *segmentedControl;
@property NSMutableArray *data;
@property UIView *topView;
@property UIImageView *segementBackgroundImageView;
@property GetMethod method;
@property int page;
@property NSDictionary *rowAndHeight;
@end

@implementation WorkRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ViewInitSetting];
    [self getData];
    [self createUI];
    // Do any additional setup after loading the view.
}

- (void)ViewInitSetting
{
    self.title = @"物业公告";
    
    UIImage *image = [UIImage imageNamed:@"背景2"];
    
    self.view.layer.contents = (id)image.CGImage;
    
    self.data = [NSMutableArray array];
    self.method = GetAdministrationData;
    self.page = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(change:) name:@"giveHeight" object:nil];
    
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    //    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)getData
{
    [SVProgressHUD showWithStatus:@"加载数据中，请稍等..."];
    if (self.method == GetAdministrationData) {
        [[ServicesManager getAPI]getNotice:self.page onComplete:^(NSString *errorMsg, NSArray *list) {
            
            if (errorMsg) {
                [SVProgressHUD showErrorWithStatus:errorMsg];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView.mj_footer endRefreshing];
                    [self.tableView.mj_header endRefreshing];
                });
                self.page --;
            }
            else if (list.count == 0 && errorMsg == nil) {
                [self.tableView.mj_footer endRefreshing];
                [SVProgressHUD dismiss];
            }
            
            else
            {
                [self.data addObjectsFromArray:list];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    
                    [SVProgressHUD dismiss];
                    [self.tableView.mj_footer endRefreshing];
                    [self.tableView.mj_header endRefreshing];
                });
            }
            
        }];
    }
    
    else
    {
        [[ServicesManager getAPI]getAds:self.page onComplete:^(NSString *errorMsg, NSArray *list) {
            
            if (errorMsg) {
                [SVProgressHUD showErrorWithStatus:errorMsg];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView.mj_footer endRefreshing];
                    [self.tableView.mj_header endRefreshing];
                });
                self.page --;
            }
            else if (list.count == 0 && errorMsg == nil) {
                [self.tableView.mj_footer endRefreshing];
                [SVProgressHUD dismiss];
            }
            else
            {
                [self.data addObjectsFromArray:list];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    
                    [SVProgressHUD dismiss];
                    [self.tableView.mj_footer endRefreshing];
                    [self.tableView.mj_header endRefreshing];
                });
            }
        }];
    }
    
}

- (void)createUI
{
    
    self.topView = [[UIImageView alloc]init];
    
    self.topView.backgroundColor = [UIColor clearColor];
    
    self.topView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.topView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(TopViewH);
    }];
    self.segmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"行政公告",@"商圈公告"]];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.frame = CGRectMake(40, 15,My_ScreenW - 100 ,  40);
    self.segmentedControl.center = CGPointMake(My_ScreenW/2, self.segmentedControl.center.y);
    self.segmentedControl.layer.cornerRadius = 10;
    self.segmentedControl.clipsToBounds = YES;
    self.segmentedControl.layer.borderWidth = 1;
    self.segmentedControl.layer.borderColor = My_NAV_BG_Color.CGColor;
    self.segmentedControl.tintColor = My_NAV_BG_Color;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:My_NAV_BG_Color,NSForegroundColorAttributeName,FontSize(CONTENT_FONT + 2),NSFontAttributeName ,nil];
    [self.segmentedControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    [self.topView addSubview:self.segmentedControl];
    
    [self.segmentedControl addTarget:self action:@selector(change) forControlEvents:UIControlEventValueChanged];
    
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.alpha = 1;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    self.tableView.bounces = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.data removeAllObjects];
        self.page = 0;
        [self getData];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self getData];
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom).with.offset(0);
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.bottom.mas_equalTo(0);
    }];
    
    
}

#pragma mark --tableViewDelegate与tableViewDataSource方法的实现
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProclamationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[ProclamationTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    NSString *time = [NSString stringDateFromTimeInterval:[[self.data[indexPath.section] ctime] intValue] withFormat:@"YYYY-MM-dd HH:mm"];
    [cell setTitle:[self.data[indexPath.section] title] time:time content:[self.data[indexPath.section] content] width:tableView.width];
    cell.preservesSuperviewLayoutMargins = NO;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.data) {
        //        NSLog(@"%f",tableView.width);
        NSArray *cellArray = @[[NSNumber numberWithFloat:200],[NSNumber numberWithFloat:tableView.width]];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"cellHeight" object:cellArray];
        
        NSString *rowS = [self.rowAndHeight allKeys][0];
        
        if (rowS != nil && indexPath.section == [rowS integerValue]) {
            
            return [self.rowAndHeight[rowS] integerValue];
        }
        else
        {
            //添加上面固定内容的高度 + 下面内容的高度 + 与下边界的距离
            return 200;
        }
    }
    else
    {
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == self.data.count - 1) {
        return 80;
    }
    return 0.01;
}


- (void)change
{
    self.method =(int)self.segmentedControl.selectedSegmentIndex;
    [self.data removeAllObjects];
    self.rowAndHeight = nil;
    [self getData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProclamationInfoViewController *pushView = [[ProclamationInfoViewController alloc]init];
    pushView.proclamationId = [self.data[indexPath.section] Id];
    pushView.type = self.method;
    [self.navigationController pushViewController:pushView animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)change:(NSNotification *)notification
{
    //    self.changeHeightStatu = YES;
    //    self.cellHeight = [[notification.object firstObject] floatValue];
    self.rowAndHeight = notification.object;
    [self.tableView reloadData];
}

@end