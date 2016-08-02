//
//  SuggestViewController.m
//  THWY_Client
//
//  Created by HuangYiZhe on 16/7/30.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "SuggestViewController.h"
#import "Masonry/Masonry.h"
#import "ProclamationTableViewCell.h"
#import "ReviseBtn.h"
#define TopViewH 70
@interface SuggestViewController ()<UITableViewDelegate,UITableViewDataSource>
@property UITableView *tableView;
@property UISegmentedControl *segmentedControl;
@property NSMutableArray *FeedBackTypeArray;
@property NSArray *data;
@end

@implementation SuggestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ViewInitSetting];
    [self getData:@"1"];
    [self createUI];
    
    // Do any additional setup after loading the view.
}

- (void)ViewInitSetting
{
    self.title = @"建议意见";
    
    UIImage *image = [UIImage imageNamed:@"背景2"];
    
    self.view.layer.contents = (id)image.CGImage;
    
    self.FeedBackTypeArray = [NSMutableArray array];
    
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    //    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)getData:(NSString *)type
{
    [[ServicesManager getAPI] getFeedBackTypes:^(NSString *errorMsg, NSArray *list) {
        
        for (FeedBackTypeVO *temp in list) {
            
            [self.FeedBackTypeArray addObject:temp];
        }
        
        [[ServicesManager getAPI]getFeedBackList:type onComplete:^(NSString *errorMsg, NSArray *list) {
            
            self.data = list;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                
            });
            
        }];
        
    }];
}

- (void)createUI
{
    
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.alpha = 1;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.clipsToBounds = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(TopViewH);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-10);
    }];
    
    UIImageView *topView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,My_ScreenW, TopViewH)];
    topView.contentMode = UIViewContentModeBottomRight;
    topView.image = [UIImage imageNamed:@"背景2"];
    topView.clipsToBounds = YES;
    [self.view addSubview:topView];
    topView.userInteractionEnabled = YES;
    topView.backgroundColor = [UIColor whiteColor];
    self.segmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"建议",@"意见"]];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.frame = CGRectMake(40, 15,My_ScreenW - 80 ,  40);
    
    self.segmentedControl.tintColor = My_NAV_BG_Color;
    [topView addSubview:self.segmentedControl];
    
    [self.segmentedControl addTarget:self action:@selector(change) forControlEvents:UIControlEventValueChanged];
    
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
    NSString *time = [NSString stringDateFromTimeInterval:[[self.data[indexPath.section] ctime] intValue] withFormat:@"YYYY-MM-dd"];
    [cell setTitle:@"" time:time content:[self.data[indexPath.section] content] width:tableView.width];
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == self.data.count - 1) {
        return 50;
    }
    else
    {
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    if (section == self.data.count - 1) {
        ReviseBtn *reviseBtn = [[ReviseBtn alloc]initWithFrame:CGRectMake(40, 5, tableView.width - 80 , 40)];
        reviseBtn.backgroundColor = [UIColor clearColor];
        [reviseBtn setImage:[UIImage imageNamed:@"建议意见 添加"] forState:UIControlStateNormal];
        [reviseBtn setTitle:@"添加" forState:UIControlStateNormal];
        [reviseBtn setBackgroundImage:[UIImage imageNamed:@"信息修改按钮"] forState:UIControlStateNormal];
        [reviseBtn setBackgroundImage:[UIImage imageNamed:@"信息修改按钮按下"] forState:UIControlStateHighlighted];    [reviseBtn addTarget:self action:@selector(clickAddBtn) forControlEvents:UIControlEventTouchUpInside];
        reviseBtn.adjustsImageWhenHighlighted = NO;
        [view addSubview:reviseBtn];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat contenHeight = [[self.data[indexPath.section] content] sizeWithFont:[UIFont systemFontOfSize:CONTENT_FONT] maxSize:CGSizeMake(tableView.width, 4000)].height;
    //添加上面固定内容的高度 + 下面内容的高度 + 与下边界的距离
    return contenHeight + 52 + 8 + 10;
}

- (void)change
{
    
    NSLog(@"%@ld",self.FeedBackTypeArray);
    [self getData:[self.FeedBackTypeArray[self.segmentedControl.selectedSegmentIndex] Id]];
    
}

- (void)clickAddBtn
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
