//
//  RepaireDetailController.m
//  THWY_Client
//
//  Created by wei on 16/8/3.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "RepairDetailController.h"
#import "RecordsDetailCell.h"
#import "RecordImageCell.h"
#import "RecordVideoCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface RepairDetailController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) RepairVO *model;

@end

@implementation RepairDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"报修记录详情";
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"repaire_背景2"]]];
    
    [self initViews];
    [self getRepairVO];
}

- (void)getRepairVO{
    [SVProgressHUD showWithStatus:@"加载数据中，请稍等..."];
    [My_ServicesManager getARepair:self.type repairId:self.repairVOId onComplete:^(NSString *errorMsg, RepairVO *list) {
        if (errorMsg) {
            [SVProgressHUD showErrorWithStatus:errorMsg];
        }else{
            self.model = list;
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        }
    }];
    
}

- (void)initViews{
    CGFloat topMargrin = 10.0/375*My_ScreenW;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(topMargrin, topMargrin, My_ScreenW-topMargrin*2.0, 2)];
    imageView.image = [UIImage imageNamed:@"records_彩条"];
//    [self.view addSubview:imageView];
    
    //tableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(topMargrin, topMargrin+2, My_ScreenW-topMargrin*2.0, My_ScreenH-topMargrin*2.0-74) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableHeaderView = imageView;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];

    [self.tableView registerClass:[RecordsDetailCell class] forCellReuseIdentifier:@"RecordsDetailCell"];
    [self.tableView registerClass:[RecordImageCell class] forCellReuseIdentifier:@"RecordImageCell"];
    [self.tableView registerClass:[RecordVideoCell class] forCellReuseIdentifier:@"RecordVideoCell"];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:{
            return 4;
            break;
        }
        case 1:{
            return 3;
            break;
        }
        case 2:{
            return 2;
            break;
        }
        case 3:{
            return 3;
            break;
        }
        case 4:{
            if (self.model.pic && ![self.model.pic isEqualToString:@""]) {
                return 1;
            }else{
                return 0;
            }

            break;
        }
        case 5:{
            if (self.model.vdo && ![self.model.vdo isEqualToString:@""]) {
                return 1;
            }else{
                return 0;
            }
            break;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 4) {
        RecordImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordImageCell" forIndexPath:indexPath];
        [cell loadDataWithModel:self.model];
        return cell;
    }else if (indexPath.section == 5){
        RecordVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordVideoCell" forIndexPath:indexPath];
        [cell loadDataWithModel:self.model];
        return cell;
    }else{
        RecordsDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordsDetailCell" forIndexPath:indexPath];
        cell.type = self.type;
        [cell loadDataWithModel:self.model indexpath:indexPath];
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 4) {
        if (self.model.pic && ![self.model.pic isEqualToString:@""]) {
            return My_ScreenH*0.4+40;
        }else{
            return 0;
        }
    }else if (indexPath.section == 5) {
        if (self.model.vdo && ![self.model.vdo isEqualToString:@""]) {
            return 240/667.0*My_ScreenH;
        }else{
            return 0;
        }

    }else if (indexPath.section == 1 && indexPath.row == 1){
        if (self.model.classes_str && ![self.model.classes_str isEqualToString:@""]) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:My_RegularFontName size:15.0],NSFontAttributeName, nil];
            CGRect rect = [self.model.classes_str boundingRectWithSize:CGSizeMake(self.tableView.width*3.0/4, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
            return rect.size.height+20;
        }else{
            return 44;
        }
    }else{
        return 44;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIImageView *head = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 1)];
    head.image = [UIImage imageNamed:@"records_虚线"];
    return head;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 4) {
        if (self.model.pic && ![self.model.pic isEqualToString:@""]) {
            return 1;
        }else{
            return 0;
        }
    }else if (section == 5) {
        if (self.model.vdo && ![self.model.vdo isEqualToString:@""]) {
            return 1;
        }else{
            return 0;
        }
        
    }else{
        return 1;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
