//
//  CMTableViewCell.m
//  THWY_Server
//
//  Created by HuangYiZhe on 16/8/26.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "CMTableViewCell.h"
@interface CMTableViewCell()
@property UIImageView *icon;
@property UILabel *contentLabel;
@property UIImageView *backView;
@property int number;
@end
@implementation CMTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.number = 0;
        self.icon = [[UIImageView alloc]init];
        self.contentLabel = [[UILabel alloc]init];
        self.backView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.backView];
        [self.contentView addSubview:self.icon];
        [self.backView addSubview:self.contentLabel];
    }
    return self;
}

- (void)setIcon:(NSString *)icon Content:(NSString *)content
{
    
    self.icon.frame = CGRectMake(10, 0, 40, 40);
    
    self.icon.centerY = self.contentView.centerY;
    
    [self.icon sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"Avatar"]];

    NSLog(@"iamge%@",icon);
    self.contentLabel.text = content;
    self.contentLabel.font = FontSize(CONTENT_FONT);
    self.contentLabel.numberOfLines = 0;
    CGFloat width = self.width * 0.5;

    self.backView.frame = CGRectMake(self.icon.right + 5, 0, width + 25, 30);
    self.backView.centerY = self.icon.centerY;
    self.backView.image = [UIImage imageNamed:@"白对话框"];
    
    
    self.contentLabel.frame = CGRectMake(15, 5, width, 20);
    CGFloat contentHeight = [content sizeWithFont:FontSize(CONTENT_FONT) maxSize:CGSizeMake(width, 4000)].height;
    if (contentHeight > CONTENT_FONT) {
        self.contentLabel.height = contentHeight;
        self.backView.height += contentHeight - CONTENT_FONT;
        self.icon.centerY = self.backView.centerY;
    }
    NSString *rowS = [NSString stringWithFormat:@"%d",self.section];
    NSString *heightS = [NSString stringWithFormat:@"%f",self.backView.bottom];
    NSLog(@"cell.section:%@",rowS);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"giveHeight" object:@{rowS:heightS}];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
