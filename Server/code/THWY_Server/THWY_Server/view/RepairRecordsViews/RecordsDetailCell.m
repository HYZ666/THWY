//
//  RecordsDetailCell.m
//  THWY_Client
//
//  Created by wei on 16/8/4.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "RecordsDetailCell.h"

@interface RecordsDetailCell ()

@property (strong, nonatomic) NSArray *labelNames;

@property (strong, nonatomic) UILabel *leftLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UILabel *line;

@end

@implementation RecordsDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        self.leftLabel = [[UILabel alloc] init];
        self.detailLabel = [[UILabel alloc] init];
        [self setLabelAttributes:self.leftLabel];
        [self setLabelAttributes:self.detailLabel];
        self.line = [[UILabel alloc] init];
        self.line.backgroundColor = [UIColor lightGrayColor];
        
        [self.contentView addSubview:self.leftLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.line];
        
        CGFloat topMargin = 8.0/375*My_ScreenW;
        [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(topMargin);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.height.mas_equalTo(20);
        }];
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.leftLabel.mas_right).offset(topMargin);
            make.centerY.mas_equalTo(self.leftLabel.mas_centerY);
            make.height.mas_equalTo(20);
        }];
        
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(topMargin);
            make.height.mas_equalTo(1);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-topMargin);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
        
    }
    return self;
}

- (void)loadDataWithModel:(RepairVO *)model indexpath:(NSIndexPath *)indexpath{
    self.leftLabel.text = self.labelNames[indexpath.section][indexpath.row];
    switch (indexpath.section) {
        case 0:{
            switch (indexpath.row) {
                case 0:{
                    self.detailLabel.text = model.real_name;
                    break;
                }
                case 1:{
                    self.detailLabel.text = model.Id;
                    break;
                }
                case 2:{
                    self.detailLabel.text = [NSString stringWithFormat:@"%@%@栋%@单元%@室",model.estate,model.block,model.unit,model.mph];
                    break;
                }
                case 3:{
                    self.detailLabel.text = model.call_phone;
                    [self.line setHidden:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:{
            switch (indexpath.row) {
                case 0:{
                    self.detailLabel.text = [NSString stringDateFromTimeInterval:[model.st_0_time intValue] withFormat:nil];
                    break;
                }
                case 1:{
                    self.detailLabel.text = model.classes_str;
                    self.detailLabel.numberOfLines = 0;
                    [self.detailLabel sizeToFit];
                    break;
                }
                case 2:{
                    self.detailLabel.text = model.detail;
                    [self.line setHidden:YES];
                    break;
                }
                default:
                    break;
            }

            break;
        }
        case 2:{
            switch (indexpath.row) {
                case 0:{
                    self.detailLabel.text = @"张师傅";
                    break;
                }
                case 1:{
                    self.detailLabel.text = model._st;
                    [self.line setHidden:YES];
                    break;
                }
                default:
                    break;
            }

            break;
        }
        case 3:{
            switch (indexpath.row) {
                case 0:{
                    self.detailLabel.text = [NSString stringDateFromTimeInterval:[model.st_1_time intValue] withFormat:nil];
                    break;
                }
                case 1:{
                    self.detailLabel.text = [NSString stringDateFromTimeInterval:[model.st_2_time intValue] withFormat:nil];
                    break;
                }
                case 2:{
                    self.detailLabel.text = [NSString stringDateFromTimeInterval:[model.st_3_time intValue] withFormat:nil];
                    [self.line setHidden:YES];
                    break;
                }
  
                default:
                    break;
            }

            break;
        }

        default:
            break;
    }
    
}

- (void)setLabelAttributes:(UILabel *)label{
    
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:My_RegularFontName size:16.0];
    label.textColor = [UIColor darkGrayColor];
    //    [label sizeToFit];
    
}

- (NSArray *)labelNames{
    
    if (!_labelNames) {
        _labelNames = @[@[@"报修人姓名:", @"派工单号:", @"房源信息:", @"报修人电话:"],
                        @[@"报修时间:", @"报修类别:", @"报修描述:"],
                        @[@"维修人:", @"维修人员电话:"],
                        @[@"派工时间:", @"完工时间:", @"回访时间:"]];
    }
    return _labelNames;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
