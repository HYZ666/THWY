//
//  RecordeRepeiringCell.m
//  THWY_Client
//
//  Created by wei on 16/8/3.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "RecordeRepairingCell.h"
#import "RepairVO.h"
#import "RepairDetailController.h"

@interface RecordeRepairingCell ()

@property (strong, nonatomic) UILabel *numberLabel;
@property (strong, nonatomic) RepairVO *model;

@property (strong, nonatomic) UIImageView *caiTiaoImage;
@property (strong, nonatomic) UIImageView *paiGongNumber;
@property (strong, nonatomic) UILabel *paiGongLabel;
@property (strong, nonatomic) UIButton *detail;

@property (strong, nonatomic) UILabel *line;

@property (strong, nonatomic) UILabel *houseSource;
@property (strong, nonatomic) UILabel *houseSourceLabel;

@property (strong, nonatomic) UILabel *repairCatogery;
@property (strong, nonatomic) UILabel *repairCatogeryLabel;

@property (strong, nonatomic) UILabel *line2;

@property (strong, nonatomic) UILabel *repairDesc;
@property (strong, nonatomic) UILabel *repairDescLabel;

@property (strong, nonatomic) UILabel *line3;

@property (strong, nonatomic) UILabel *cellPhone;
@property (strong, nonatomic) UILabel *cellPhoneLabel;

@property (strong, nonatomic) UIButton *callBtn;

@property (strong, nonatomic) UIWebView *phoneCallWebView;

@end

@implementation RecordeRepairingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setFrame:(CGRect)frame {
    frame.origin.y -= 5;      // 让cell的y值增加1(根据自己需要分割线的高度来进行调整)
    frame.size.height -= 10;   // 让cell的高度减1
    [super setFrame:frame];   // 别忘了重写父类方法
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
                
        CGFloat topMagrin = 5.0/375*My_ScreenW;
        self.caiTiaoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, 2)];
        self.caiTiaoImage.image = [UIImage imageNamed:@"records_彩条"];
        [self.contentView addSubview:self.caiTiaoImage];
        [self.caiTiaoImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(2);
            make.left.mas_equalTo(self.contentView.mas_left);
            make.right.mas_equalTo(self.contentView.mas_right);
            make.top.mas_equalTo(self.contentView.mas_top);
        }];
        
        self.detail = [[UIButton alloc] init];
        [self.detail setImage:[UIImage scaleImage:[UIImage imageNamed:@"records_详情"]  toScale:0.7]forState:UIControlStateNormal];
        [self.detail addTarget:self action:@selector(showDetail) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.detail];
        [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.caiTiaoImage.mas_bottom).offset(topMagrin*0.5);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-4.0/375*My_ScreenW);
            make.width.mas_equalTo(self.detail.mas_height);
            make.height.mas_equalTo(40.0/667*My_ScreenH);
        }];

        self.paiGongNumber = [[UIImageView alloc] init];
        [self.contentView addSubview:self.paiGongNumber];
        self.paiGongLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.paiGongLabel];
        self.numberLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.numberLabel];
        
        
        self.paiGongNumber.image = [UIImage imageNamed:@"records_派工单号"];
        [self.paiGongNumber mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(4.0/375*My_ScreenW);
            make.width.mas_equalTo(self.paiGongNumber.mas_height);
            make.height.mas_equalTo(self.detail.mas_height).multipliedBy(0.6);
            make.centerY.mas_equalTo(self.detail.mas_centerY);
        }];
        
        self.paiGongLabel.text = @"派工单号: ";
        [self setLabelAttributes:self.paiGongLabel];
        [self.paiGongLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.paiGongNumber.mas_centerY);
            make.left.mas_equalTo(self.paiGongNumber.mas_right).offset(10.0/375*My_ScreenW);
        }];
        
        self.numberLabel.text = @"WX1223";
        [self setLabelAttributes:self.numberLabel];
        [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.paiGongLabel.mas_centerY);
            make.left.mas_equalTo(self.paiGongLabel.mas_right).offset(10.0/375*My_ScreenW);
        }];
        
        self.line = [[UILabel alloc] init];
        [self.contentView addSubview:self.line];
        [self.line setBackgroundColor:[UIColor lightGrayColor]];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.left.and.right.equalTo(self.contentView);
            make.top.mas_equalTo(self.detail.mas_bottom).offset(topMagrin*0.5);
        }];

        
        self.houseSourceLabel = [[UILabel alloc] init];
        self.houseSource = [[UILabel alloc] init];
        [self.contentView addSubview:self.houseSourceLabel];
        [self.contentView addSubview:self.houseSource];
        
        self.houseSource.text = @"报修房源: ";
        [self setLabelAttributes:self.houseSource];
        
        [self.houseSource mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.paiGongNumber.mas_centerX);
            make.top.mas_equalTo(self.line.mas_bottom).offset(topMagrin);
        }];
        
        [self setLabelAttributes:self.houseSourceLabel];
        [self.houseSourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.houseSource.mas_centerY);
            make.left.mas_equalTo(self.houseSource.mas_right);
        }];
        
        
        self.repairCatogery = [[UILabel alloc] init];
        self.repairCatogeryLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.repairCatogeryLabel];
        [self.contentView addSubview:self.repairCatogery];
        self.repairCatogery.text = @"保修类别: ";
        [self setLabelAttributes:self.repairCatogery];
        [self.repairCatogery mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.houseSource.mas_left);
            make.top.mas_equalTo(self.houseSource.mas_bottom).offset(topMagrin);
        }];
        
        [self.repairCatogeryLabel setNumberOfLines:0];
        self.repairCatogeryLabel.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:My_RegularFontName size:16.0],NSFontAttributeName, nil];
        CGRect rect = [self.repairCatogeryLabel.text boundingRectWithSize:CGSizeMake(300.0/375*My_ScreenW, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
        
        [self setLabelAttributes:self.repairCatogeryLabel];
        [self.repairCatogeryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.repairCatogery.mas_left);
            make.top.mas_equalTo(self.repairCatogery.mas_bottom).offset(topMagrin);
            make.width.mas_equalTo(rect.size.width);
            make.height.mas_equalTo(rect.size.height);
            
        }];
        
        self.line2 = [[UILabel alloc] init];
        [self.contentView addSubview:self.line2];
        [self.line2 setBackgroundColor:[UIColor lightGrayColor]];
        [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.left.and.right.equalTo(self.contentView);
            make.top.mas_equalTo(self.repairCatogeryLabel.mas_bottom).offset(topMagrin);
            
        }];

        self.repairDesc = [[UILabel alloc] init];
        self.repairDesc.text = @"报修描述: ";
        self.repairDescLabel = [[UILabel alloc] init];
        [self setLabelAttributes:self.repairDesc];
        [self.contentView addSubview:self.repairDesc];
        [self.contentView addSubview:self.repairDescLabel];
        
        [self.repairDesc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.houseSource.mas_left);
            make.top.mas_equalTo(self.line2.mas_bottom).offset(topMagrin);
        }];
        
        [self setLabelAttributes:self.repairDescLabel];
        [self.repairDescLabel setNumberOfLines:0];
        self.repairDescLabel.lineBreakMode = NSLineBreakByWordWrapping;
        //    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:My_RegularFontName size:16.0],NSFontAttributeName, nil];
        CGRect rect2 = [self.repairDescLabel.text boundingRectWithSize:CGSizeMake(300.0/375*My_ScreenW, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
        [self.repairDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.houseSource.mas_left);
            make.top.mas_equalTo(self.repairDesc.mas_bottom).offset(0);
            make.width.mas_equalTo(rect2.size.width);
            make.height.mas_equalTo(rect2.size.height);
        }];
    
        
        self.line3 = [[UILabel alloc] init];
        self.callBtn = [[UIButton alloc] init];
        [self.contentView addSubview:self.line3];
        [self.contentView addSubview:self.callBtn];
        
        [self.line3 setBackgroundColor:[UIColor lightGrayColor]];
        [self.line3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.left.and.right.equalTo(self.contentView);
            make.top.mas_equalTo(self.repairDescLabel.mas_bottom).offset(topMagrin);
            
        }];
        
        [self.callBtn setImage:[UIImage scaleImage:[UIImage imageNamed:@"records_call"]  toScale:0.7] forState:UIControlStateNormal];
        [self.callBtn addTarget:self action:@selector(callNumber) forControlEvents:UIControlEventTouchUpInside];
        [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.detail.mas_centerX);
            make.top.mas_equalTo(self.line3.mas_bottom).offset(topMagrin);
            make.height.mas_equalTo(self.detail.mas_height).multipliedBy(0.7);
            make.width.mas_equalTo(self.callBtn.mas_height).multipliedBy(0.75);
        }];
        
        self.cellPhone = [[UILabel alloc] init];
        self.cellPhoneLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.cellPhone];
        [self.contentView addSubview:self.cellPhoneLabel];
        
        self.cellPhone.text = @"报修人电话: ";
        [self setLabelAttributes:self.cellPhone];
        [self.cellPhone mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.houseSource.mas_left);
            make.centerY.mas_equalTo(self.callBtn.mas_centerY);
        }];
        
        [self setLabelAttributes:self.cellPhoneLabel];
        [self.cellPhoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.cellPhone.mas_right);
            make.centerY.mas_equalTo(self.cellPhone.mas_centerY);
        }];
        
        
    }
    return self;

}

- (void)setLabelAttributes:(UILabel *)label{
    
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:My_RegularFontName size:16.0];
    label.textColor = [UIColor darkGrayColor];
//    [label sizeToFit];

}

- (void)loadDataFromModel:(RepairVO *)repaireVO{
    
    self.model = repaireVO;
    self.numberLabel.text = repaireVO.Id;
    self.houseSourceLabel.text = repaireVO.estate_name;
    self.repairCatogeryLabel.text = repaireVO.classes_str;
    self.repairDescLabel.text = repaireVO.detail;
    self.cellPhoneLabel.text = repaireVO.call_phone;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:My_RegularFontName size:16.0],NSFontAttributeName, nil];
    CGRect rect = [self.repairCatogeryLabel.text boundingRectWithSize:CGSizeMake(320/375.0*My_ScreenW, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    [self.repairCatogeryLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(rect.size.width);
        make.height.mas_equalTo(rect.size.height);
        
    }];

    [self layoutIfNeeded];

    CGRect rect2 = [self.repairDescLabel.text boundingRectWithSize:CGSizeMake(320/375.0*My_ScreenW, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    [self.repairDescLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(rect2.size.width);
        make.height.mas_equalTo(rect2.size.height);
    }];
    
    [self layoutIfNeeded];

}

- (void)callNumber{
    NSString *phoneNum = self.cellPhoneLabel.text;// 电话号码
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]];
    [[UIApplication sharedApplication] openURL:phoneURL];

}

- (void)showDetail{
    
    RepairDetailController *detail = [[RepairDetailController alloc] init];
    detail.model = self.model;
    [self.vc.navigationController pushViewController:detail animated:YES];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
