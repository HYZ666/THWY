//
//  GoodsVC.m
//  THWY_Client
//
//  Created by wei on 16/8/8.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "GoodsVC.h"
#import "RecommandMerchantCell.h"

@interface GoodsVC ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *bussnessModels;
@property (assign, nonatomic) int page;

@end

@implementation GoodsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"商品详情";
    self.page = 0;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"repaire_背景"]];
    [self initViews];
    [self getBussnessData];
    
}

- (void)initViews{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 10, self.view.width-20, self.view.height-84)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 100;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandMerchantCell" bundle:nil]forCellReuseIdentifier:@"RecommandMerchantCell"];
//    [self initRefreshView];
    [self.view addSubview:self.tableView];

    
}

//设置上拉下拉刷新
- (void)initRefreshView{
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getBussnessData)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    //自动更改透明度
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    // self.tableView.mj_footer.automaticallyChangeAlpha = YES;
    
}

- (void)loadMoreData{
    [SVProgressHUD showWithStatus:@"数据加载中..."];
    
    [[ServicesManager getAPI] getRecommendGoods:++self.page onComplete:^(NSString *errorMsg, NSArray *list) {
        
        if (errorMsg){
            [SVProgressHUD showErrorWithStatus:errorMsg];
        }
        
        for (GoodVO *model in list) {
            [self.bussnessModels addObject:model];
        }
        
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
        [SVProgressHUD dismiss];
        
    }];
    
}

- (void)getBussnessData{
    
    [SVProgressHUD showWithStatus:@"数据加载中..."];
    self.bussnessModels = [NSMutableArray array];
    [My_ServicesManager getAGood:self.good.Id onComplete:^(NSString *errorMsg, GoodVO *merchant) {

        if (errorMsg){
            
            [SVProgressHUD showErrorWithStatus:errorMsg];
        }
        [self.bussnessModels addObject:merchant];
        
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.bussnessModels.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RecommandMerchantCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecommandMerchantCell" forIndexPath:indexPath];
    [cell loadDataFromMercharge:self.bussnessModels[indexPath.row]];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    BussnessDetailVC *detail = [[BussnessDetailVC alloc] init];
    //    detail.merchant = self.bussnessModels[indexPath.row];
    
}


@end
