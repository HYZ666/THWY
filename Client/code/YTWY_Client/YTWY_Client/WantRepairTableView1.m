//
//  WantRepairTableView1.m
//  THWY_Client
//
//  Created by wei on 16/8/5.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "WantRepairTableView1.h"

#import "TextFieldCell.h"
#import "HouseSourceCell.h"
#import "RepaireCategorysCell.h"
#import "UploadCell.h"
#import "DescribeCell.h"
#import "PaigongCatogerysCell.h"
#import "ProjectCell.h"

#import "AlertTableView.h"

@interface WantRepairTableView1 ()<UITableViewDelegate, UITableViewDataSource, AlertTableViewDelegate, DescribeCellDelegate, UploadCellDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) AlertTableView *alertView;

@property (strong, nonatomic) AddRepairVO *repairVO;

@property (strong, nonatomic) NSMutableArray *housesArray;

@property (strong, nonatomic) NSMutableArray *cells;

@end

@implementation WantRepairTableView1

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    
    if (self = [super initWithFrame:frame style:style]) {
        
        self.repairVO = [[AddRepairVO alloc] init];
        self.repairVO.videoPath = @"";
        self.repairVO.cls = @"";
        self.repairVO.image = [[UIImage alloc] init];
        self.cells = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@"",@"",@"",@""]];
        
        [self getHouses];
        
        //[self initTableHeaderView];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.separatorColor = My_LineColor;
//        self.bounces = NO;
        self.showsVerticalScrollIndicator = NO;
        self.sectionFooterHeight = 0;
        
        [self registerNib:[UINib nibWithNibName:@"TextFieldCell" bundle:nil] forCellReuseIdentifier:@"textFieldCell"];
        [self registerClass:[HouseSourceCell class] forCellReuseIdentifier:@"HouseSourceCell"];
        [self registerNib:[UINib nibWithNibName:@"RepaireCategorysCell" bundle:nil] forCellReuseIdentifier:@"RepaireCategorysCell"];
        [self registerNib:[UINib nibWithNibName:@"UploadCell" bundle:nil] forCellReuseIdentifier:@"UploadCell"];
        [self registerNib:[UINib nibWithNibName:@"DescribeCell" bundle:nil] forCellReuseIdentifier:@"DescribeCell"];
        [self registerNib:[UINib nibWithNibName:@"PaigongCatogerysCell" bundle:nil] forCellReuseIdentifier:@"PaigongCatogerysCell"];
        
    }
    return self;
    
}

- (void)getHouses{
    self.housesArray = [NSMutableArray arrayWithArray:[[[UDManager getUD] getUser] houses]];
}

#pragma mark - tabelViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    switch (row) {
        case 0:{
            PaigongCatogerysCell *cell = (PaigongCatogerysCell *)[tableView dequeueReusableCellWithIdentifier:@"PaigongCatogerysCell" forIndexPath:indexPath];
            if ([self.cells[0] isKindOfClass:[PaigongCatogerysCell class]]) {
                cell.flag = [(PaigongCatogerysCell *)self.cells[0] flag];
                cell.showPikerView = [(PaigongCatogerysCell *)self.cells[0] showPikerView];
            }
            self.cells[0] = cell;
            cell.tableView = tableView;
            return cell;
            break;
        }

        case 1:{
  
            TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"textFieldCell" forIndexPath:indexPath];
            cell.icon.image = [UIImage imageNamed:@"repaire_姓名"];
            cell.label.text = @"业主名称:";
            if( !cell.textField || [cell.textField.text isEqualToString:@""]){
                cell.textField.text = [[[UDManager getUD] getUser] real_name];
            }
            self.cells[row] = cell;
            return cell;
            
            break;
        }
        case 2:{

            TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"textFieldCell" forIndexPath:indexPath];
            cell.icon.image = [UIImage imageNamed:@"repaire_call"];
            cell.label.text = @"联系电话:";
            if( !cell.textField || [cell.textField.text isEqualToString:@""]){
                cell.textField.text = [[[UDManager getUD] getUser] cellphone];
            }
            self.cells[row] = cell;
            return cell;
        
            break;
        }
        case 3:{

            HouseSourceCell *cell = (HouseSourceCell *)[tableView dequeueReusableCellWithIdentifier:@"HouseSourceCell" forIndexPath:indexPath];
            cell.housesArray = self.housesArray;
            [cell updateFrame];
            self.cells[row] = cell;
            return cell;
            
        }
        case 4:{
            RepaireCategorysCell *cell = (RepaireCategorysCell *)[tableView dequeueReusableCellWithIdentifier:@"RepaireCategorysCell" forIndexPath:indexPath];
            cell.icon.image = [UIImage imageNamed:@"repaire_有偿保修"];
            cell.label.text = @"有偿报修类别: ";
            self.cells[row] = cell;
            return cell;
            
        }
        case 5:{
            RepaireCategorysCell *cell = (RepaireCategorysCell *)[tableView dequeueReusableCellWithIdentifier:@"RepaireCategorysCell" forIndexPath:indexPath];
            cell.icon.image = [UIImage imageNamed:@"repaire_保修类别"];
            cell.label.text = @"无偿报修类别: ";
            self.cells[row] = cell;
            return cell;
        }
        case 6:{
            UploadCell *cell = (UploadCell *)[tableView dequeueReusableCellWithIdentifier:@"UploadCell" forIndexPath:indexPath];
            cell.icon.image = [UIImage imageNamed:@"repaire_图片"];
            cell.label.text = @"上传图片:";
            cell.descLabel.text = @"上传图片不能超过2M, 图片格式为jpg, png";
            cell.delegate = self;
            cell.selectType = ImageType;
            self.cells[row] = cell;
            return cell;
        }
        case 7:{
            UploadCell *cell = (UploadCell *)[tableView dequeueReusableCellWithIdentifier:@"UploadCell" forIndexPath:indexPath];
            cell.icon.image = [UIImage imageNamed:@"repaire_视频"];
            cell.label.text = @"上传视频:";
            cell.descLabel.text = @"上传视频不能超过8M, 视频格式为flv、f4v、mp4、mov";
            cell.delegate = self;
            cell.selectType = VideoType;
            self.cells[row] = cell;
            return cell;
        }
        case 8:{
            DescribeCell *cell = (DescribeCell *)[tableView dequeueReusableCellWithIdentifier:@"DescribeCell" forIndexPath:indexPath];
            cell.delegate = self;
//            self.separatorStyle = UITableViewCellSeparatorStyleNone;
//            cell.textView.delegate = self;
            self.cells[row] = cell;
            return cell;
        }
        default:
            break;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 3) {
        return (60.0+self.housesArray.count*30)/713*My_ScreenH;
    }else if (indexPath.row == 6 || indexPath.row == 7) {
        return 90.0/713*My_ScreenH;
    }else if (indexPath.row == 8){
        if ([[UIDevice platformString] isEqualToString:@"iPhone 4s"]) {
            return 340;
        }else{
            return 350.0/713*My_ScreenH;
        }
    }else if (indexPath.row == 0){
//        CGFloat topMargin = 5;
        if ([self.cells[0] isKindOfClass:[PaigongCatogerysCell class]]) {
            if ([(PaigongCatogerysCell *)self.cells[0] showPikerView]) {
                return 60.0/713*My_ScreenH + 60*2-15;
            }else{
                return 60.0/713*My_ScreenH;
            }
        }else{
            return 60.0/713*My_ScreenH;
        }
    }
    return 60.0/713*My_ScreenH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 4:{
            //有偿弹框
            [self initAlertView];
            self.alertView.data = self.repaireClassArrayPay;
            self.alertView.flag = 1;
            [self.alertView initViews];
            if(self.repaireClassArrayPay.count == 0 || !self.repaireClassArrayPay){
                [SVProgressHUD showErrorWithStatus:@"请检查网络"];
                return;
            }
            [self.alertView showInWindow];
            break;
        }
        case 5:{
            //无偿弹框
            [self initAlertView];
            self.alertView.data = self.repaireClassArrayFree;
            self.alertView.flag = 2;
            [self.alertView initViews];
            if(self.repaireClassArrayFree.count == 0 || !self.repaireClassArrayFree){
                [SVProgressHUD showErrorWithStatus:@"请检查网络"];
                return;
            }
            [self.alertView showInWindow];
            break;
        }
        default:
            [[(UIViewController *)self.repairDelegate view] endEditing:YES];
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [(PaigongCatogerysCell *)cell updateView];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

//弹出框
- (void)initAlertView{
    
    self.alertView = [[AlertTableView alloc] initWithFrame:CGRectMake(20/375.0*My_ScreenW, 20/375.0*My_ScreenW, 337/375.0*My_ScreenW, My_ScreenH-20/375.0*My_ScreenW*2)];
    self.alertView.AlertDelegate = self;

}

//弹出框代理函数
- (void)confirm:(NSMutableArray *)reslult flag:(NSInteger)flag{

    NSMutableString *clsName = [NSMutableString stringWithFormat:@""];
    NSMutableString *clsPath = [NSMutableString stringWithString:@""];
    if (flag == 1){
    //有偿
        for (NSIndexPath *indexpath in reslult) {
            if (![clsPath isEqualToString:@""]) {
                [clsName appendString:@","];
                [clsPath appendString:@","];
            }
            [clsName appendString:[[self.repaireClassArrayPay[indexpath.section] child][indexpath.row] class_name]];
            [clsPath appendString:[[self.repaireClassArrayPay[indexpath.section] child][indexpath.row] Id]];
        }
        UITableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        RepaireCategorysCell *newcell = (RepaireCategorysCell *)cell;
        newcell.detailLabel.text = clsName;
        if ([self.repairVO.cls isEqualToString:@""]) {
            self.repairVO.cls = [NSString stringWithFormat:@"%@%@", self.repairVO.cls, clsPath];
        }else {
            self.repairVO.cls = [NSString stringWithFormat:@"%@,%@", self.repairVO.cls, clsPath];
        }
//        self.repairVO.cls = clsPath;
        
    }else if (flag == 2){
    //无偿
        for (NSIndexPath *indexpath in reslult) {
            if (![clsPath isEqualToString:@""]) {
                [clsName appendString:@","];
                [clsPath appendString:@","];
            }
            [clsName appendString:[[self.repaireClassArrayFree[indexpath.section] child][indexpath.row] class_name]];
            [clsPath appendString:[[self.repaireClassArrayFree[indexpath.section] child][indexpath.row] Id]];
        }
        UITableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
        RepaireCategorysCell *newcell = (RepaireCategorysCell *)cell;
        newcell.detailLabel.text = clsName;
        if ([self.repairVO.cls isEqualToString:@""]) {
            self.repairVO.cls = [NSString stringWithFormat:@"%@%@", self.repairVO.cls, clsPath];
        }else {
            self.repairVO.cls = [NSString stringWithFormat:@"%@,%@", self.repairVO.cls, clsPath];
        }
//        self.repairVO.cls = clsPath;
    }
    
}

//选择图片和视频结果
- (void)select:(id)content type:(SelectType)type{
    if (type == ImageType) {
        self.repairVO.image = (UIImage *)content;
    }else if (type == VideoType){
        self.repairVO.videoPath = content;
    }
}


//提交报修对象
- (void)commit{
    
    [[(UIViewController *)self.repairDelegate view] endEditing:YES];
    
    for (int i = 0; i < self.cells.count; i++) {
        if ([self.cells [i] isKindOfClass:[NSString class]]) {
            continue;
        }

        UITableViewCell *cell = self.cells[i];
        switch (i) {
            case 0:{
                self.repairVO.kb = [(PaigongCatogerysCell *)cell flag];
                self.repairVO.order_timestamp = [(PaigongCatogerysCell *)cell order_timestamp];
                break;
            }
            case 1:{
                self.repairVO.call_person = [((TextFieldCell *)cell) textField].text;
                break;
            }
            case 2:{
                self.repairVO.call_phone = [((TextFieldCell *)cell) textField].text;
                break;
            }
            case 3:{
                if ([(HouseSourceCell *)cell selectedIndex] == -1) {
                    [SVProgressHUD showErrorWithStatus:@"请选择所在项目"];
                    return;
                }
                self.repairVO.house_id = [self.housesArray[[(HouseSourceCell *)cell selectedIndex]] Id];
                break;
            }
//            case 3:{
//                if (![[[(RepaireCategorysCell *)cell detailLabel] text] isEqualToString:@""] && [[(RepaireCategorysCell *)cell detailLabel] text] != nil) {
//                    self.repairVO.cls = [NSString stringWithFormat:@"%@%@", self.repairVO.cls, [[(RepaireCategorysCell *)cell detailLabel] text]];
//                }
//                break;
//            }
//            case 4:{
//                if (![[[(RepaireCategorysCell *)cell detailLabel] text] isEqualToString:@""] && [[(RepaireCategorysCell *)cell detailLabel] text] != nil) {
//                    self.repairVO.cls = [NSString stringWithFormat:@"%@%@", self.repairVO.cls, [[(RepaireCategorysCell *)cell detailLabel] text]];
//                }
//                break;
//            }
            case 8:{
                self.repairVO.detail = [[(DescribeCell *)cell textView] text];
                break;
            }
            default:
                break;
        }
        
    }

    
    NSString *errorMsg = @"";
    
    if ([self.repairVO.call_person isEqualToString:@""]) {
        errorMsg = @"请输入业主名字";
    }else if ([self.repairVO.call_phone isEqualToString:@""]){
        errorMsg = @"请输入业主联系方式";
    }else if ([self.repairVO.house_id isEqualToString:@""]){
        errorMsg = @"请选择房源";
    }else if ([self.repairVO.cls isEqualToString:@""]){
        errorMsg = @"请选择报修类型";
    }
//    else if ([self.repairVO.image isEqual:nil]){
//        errorMsg = @"请选择图片";
//    }
    else if ([self.repairVO.detail isEqualToString:@""]){
        errorMsg = @"描述不能为空";
    }
    
    if (![errorMsg isEqualToString:@""]){
        [SVProgressHUD showErrorWithStatus:errorMsg];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"我要报修" message:@"确定提交报修操作吗?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"提交" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (![self.repairVO.videoPath isEqualToString:@""]){
            
            switch (My_ServicesManager.status) {
                case NotReachable:
                    [SVProgressHUD showErrorWithStatus:@"网络未连接"];
                    
                    break;
                case ReachableViaWWAN:{
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"当前处于非WiFi状态" message:@"你确定上传视频吗?" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"提交" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [SVProgressHUD showWithStatus:@"加载数据中，请稍等..."];
                        
                        [My_ServicesManager addRepair:self.repairVO onComplete:^(NSString *errorMsg) {
                            
                            [self.repairDelegate commitComplete:errorMsg];
                            
                        }];
                        
                    }];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        return ;
                    }];
                    
                    [alert addAction:confirm];
                    [alert addAction:cancel];
                    
                    [(UIViewController *)self.repairDelegate presentViewController:alert animated:YES completion:^{
                        
                    }];
                    
                    break;
                }
                case ReachableViaWiFi:{
                    
                    [SVProgressHUD showWithStatus:@"加载数据中，请稍等..."];
                    
                    [My_ServicesManager addRepair:self.repairVO onComplete:^(NSString *errorMsg) {
                        
                        [self.repairDelegate commitComplete:errorMsg];
                        
                    }];
                    break;
                }
                default:
                    break;
            }
        }else{
            [SVProgressHUD showWithStatus:@"加载数据中，请稍等..."];
            
            [My_ServicesManager addRepair:self.repairVO onComplete:^(NSString *errorMsg) {
                
                [self.repairDelegate commitComplete:errorMsg];
                
            }];
            
        }
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        return ;
    }];
    
    [alert addAction:confirm];
    [alert addAction:cancel];
    
    [(UIViewController *)self.repairDelegate presentViewController:alert animated:YES completion:^{
        
    }];

    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.repairDelegate tableViewDidScroll];
    
}

@end
