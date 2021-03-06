//
//  AlertEstateTableView.m
//  THWY_Client
//
//  Created by wei on 16/8/5.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "AlertEstateTableView.h"
#import "EstateVO.h"

@interface AlertEstateTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation AlertEstateTableView

- (void)initViews{
    
    NSInteger height = 50.0;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, height)];
    headerView.backgroundColor = [UIColor whiteColor];
    UIButton *confirm = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, height, height)];
    confirm.contentEdgeInsets = UIEdgeInsetsMake(15, 14.5,  15 , 14.5);
    [confirm setImage:[UIImage imageNamed:@"√"] forState:UIControlStateNormal];
    [confirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:confirm];
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(self.width-confirm.width, 0, height, height)];
    cancel.contentEdgeInsets = UIEdgeInsetsMake(15, 14.5,  15 , 14.5);
    [cancel setImage:[UIImage imageNamed:@"X"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:cancel];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, headerView.height-0.2, headerView.width, 0.2)];
    line.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:line];
    [self addSubview:headerView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, headerView.height, self.width, self.height-headerView.height) style:UITableViewStylePlain];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
   
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    self.tableView.rowHeight = 44.0;
    self.tableView.sectionFooterHeight = 0;
    self.selectedIndex = -1;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    self.tableView.showsVerticalScrollIndicator =  NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.tableView];
    
}

- (void)confirm{
    
    if (self.selectedIndex == -1) {
        [SVProgressHUD showErrorWithStatus:@"请选择项目"];
        return;
    }
    
    [self.AlertDelegate commit:self.selectedIndex];
    [self hideView];
}

- (void)cancel{
    [self hideView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.data.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == self.selectedIndex) {
         cell.imageView.image = [UIImage scaleImage:[UIImage imageNamed:@"repaire_selected"] toScale:0.5];
    }else{
        cell.imageView.image = [UIImage scaleImage:[UIImage imageNamed:@"repaire_unselected"] toScale:0.5];
    }

    switch (self.type) {
        case 1:{
            EstateVO *model = self.data[indexPath.row];
            cell.textLabel.text = model.estate_name;
            break;
        }
        default:
            if ([self.data[indexPath.row] isKindOfClass:[NSString class]]) {
                cell.textLabel.text = self.data[indexPath.row];
            }else if ([self.data[indexPath.row] isKindOfClass:[NSNumber class]]){
                cell.textLabel.text = [self.data[indexPath.row] stringValue];
            }
            break;
    }
    cell.textLabel.font = FontSize(CONTENT_FONT+1);
    cell.textLabel.textColor = [UIColor darkGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (self.selectedIndex != -1) {
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
        oldCell.imageView.image = [UIImage scaleImage:[UIImage imageNamed:@"repaire_unselected"] toScale:0.5];
    }
    
    self.selectedIndex = indexPath.row;
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
    newCell.imageView.image = [UIImage scaleImage:[UIImage imageNamed:@"repaire_selected"] toScale:0.5];

}


@end
