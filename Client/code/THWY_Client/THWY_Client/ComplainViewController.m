//
//  ComplainViewController.m
//  THWY_Client
//
//  Created by HuangYiZhe on 16/7/29.
//  Copyright © 2016年 SXZ. All rights reserved.
//
#import "ComplainDetailViewController.h"
#import "ComplainViewController.h"
#import "ServicesManager.h"
#import "Masonry.h"
#import "ReviseBtn.h"
#import "ComplainAlertView.h"
@interface ComplainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property UITableView *tableView;
@property NSMutableArray *data;
@property NSArray *contentHead;
@property NSMutableArray *contentEnd;
@property int pageNumber;
@property ComplainAlertView *alertview;
@end

@implementation ComplainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ViewInitSetting];
    [self getData];
    [self createUI];
    // Do any additional setup after loading the view.
}

- (void)ViewInitSetting
{
    self.title = @"我要投诉";
    UIImage *backgroundImage = [UIImage imageNamed:@"背景2"];
    self.view.layer.contents = (id) backgroundImage.CGImage;
    
    self.contentHead = @[@"投诉类型：",@"所在项目：",@"投诉人：",@"联系电话：",@"投诉日期："];
    self.contentEnd = [NSMutableArray array];
    self.data = [NSMutableArray array];
    
}

- (void)getData
{
    [SVProgressHUD showWithStatus:@"正在加载数据，请稍等······"];

    [[ServicesManager getAPI] getComplaints:self.pageNumber onComplete:^(NSString *errorMsg, NSArray *list) {
        
        if (errorMsg) {
            [SVProgressHUD showErrorWithStatus:errorMsg];
        }
        
        else if (list.count == 0)
        {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            [SVProgressHUD setMinimumDismissTimeInterval:1];
            [SVProgressHUD showInfoWithStatus:@"没有更多数据..."];
        }
        else
        {
            [self.data addObjectsFromArray:list];
            
            for (ComplaintVO *temp in list) {
                NSArray *array = @[temp.complaint_type_name,temp.estate,temp.complaint_person,temp.complaint_phone,temp.ctime,temp.Id];
                [self.contentEnd addObject:array];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView.mj_footer endRefreshing];
                [self.tableView.mj_header endRefreshing];
                
                [SVProgressHUD dismiss];

            });
        }
    }];
        
}

- (void)createUI
{
    if (self.data) {
        self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        
        self.tableView.backgroundColor = [UIColor clearColor];
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
//        self.tableView.bounces = NO;
        [self.tableView setSeparatorColor:My_Color(241, 244, 244)];
        
        if (self.data) {
            self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                self.pageNumber = 1;
                [self.data removeAllObjects];
                [self.contentEnd removeAllObjects];
                [self getData];
            }];
            self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                self.pageNumber++;
                [self getData];
            }];
            
        }
        
        [self.view addSubview:self.tableView];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.bottom.mas_equalTo(-80);
        }];
        
        UIView *view = [[UIView alloc]init];
        
        
        view.backgroundColor = [UIColor whiteColor];
        view.alpha = 0.8;
        [self.view addSubview:view];

        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.tableView.mas_bottom).with.offset(10);
            make.bottom.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            
        }];
        
        ReviseBtn *btn = [[ReviseBtn alloc]initWithFrame:CGRectMake(40, 15, self.view.width - 80, 40)];
        [btn setLeftImageView:@"建议意见 添加" andTitle:@"添加"];
        [btn addTarget:self action:@selector(clickAdd) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        

        
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == self.data.count) {
        
        return 1;
    }
    return self.contentHead.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        //    cell.textLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        if (indexPath.row != 4) {
            cell.preservesSuperviewLayoutMargins = NO;
            cell.separatorInset = UIEdgeInsetsZero;
            cell.layoutMargins = UIEdgeInsetsZero;
//        }
    
        if (self.data && indexPath.section < self.data.count) {
            if (indexPath.row < 4) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@%@",self.contentHead[indexPath.row],self.contentEnd[indexPath.section][indexPath.row]];
            }
            else
            {
                NSString *time = [NSString stringDateFromTimeInterval:[self.contentEnd[indexPath.section][indexPath.row] intValue] withFormat:@"YYYY-MM-dd HH:mm"];
                
                cell.textLabel.text = [NSString stringWithFormat:@"%@%@",self.contentHead[indexPath.row],time];
            }
        }
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

        return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{

    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor clearColor];
        UIImageView *iamgeView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 4, tableView.width, 2)];
        iamgeView.image = [UIImage imageNamed:@"分割线"];
        [view addSubview:iamgeView];
    
        return view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.data.count) {
        return 60;
    }
    else
    {
        return 40;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ComplainDetailViewController *pushView = [[ComplainDetailViewController alloc]init];
    
    pushView.complianId = [self.contentEnd[indexPath.section] lastObject];
    
    [self.navigationController pushViewController:pushView animated:YES];
}

- (void)clickAdd
{
    self.alertview = [[ComplainAlertView alloc]initWithFrame:CGRectMake(10, 0, self.view.width - 20, 0)];
//    [self.alertview updateWithComplainVo:[[UDManager getUD]getUser]];
    [self.alertview show];
    [self.alertview addLeftBtnTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
}

- (void)submit
{
    
    for (int i = 0; i < self.alertview.houseSourceBtnArray.count; i ++) {
        
        BlueRedioButton *btn = self.alertview.houseSourceBtnArray[i];
        
        if (btn.chooseStatu) {
            
            ComplaintVO *postItem = [[ComplaintVO alloc]init];
            UserVO *user = [[UDManager getUD] getUser];
            postItem.complaint_person = self.alertview.personTf.text;
            postItem.complaint_type = self.alertview.typeBtn.postID;
            postItem.complaint_phone = self.alertview.phoneTf.text;
            postItem.house_id = btn.house.Id;
            postItem.estate_id = btn.house.estate_id;
            postItem.complaint_content = self.alertview.textView.text;
            
            if(self.alertview.textView.text.length == 0)
            {
                [SVProgressHUD showErrorWithStatus:@"内容不能为空"];
            }
            else{
                
                [[ServicesManager getAPI] addComplaint:postItem onComplete:^(NSString *errorMsg) {
                    
                    if (errorMsg) {
                        [SVProgressHUD showErrorWithStatus:errorMsg];
                        
                    }
                    else
                    {
                        [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                        [self.alertview hideInWindow];
                        self.pageNumber = 1;
                        [self.data removeAllObjects];
                        [self.contentEnd removeAllObjects];
                        [self getData];
                    }
                    
                }];

                break;
            }
        }

    }
    
}


//#pragma mark --设置sectionHeaderView固定
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat sectionHeaderHeight = 6;
//    if(scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0,0);
//    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
