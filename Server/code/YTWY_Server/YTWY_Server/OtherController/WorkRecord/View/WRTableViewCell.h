//
//  WRTableViewCell.h
//  YTWY_Server
//
//  Created by HuangYiZhe on 16/8/23.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WRTableViewCell : UITableViewCell
@property int section;
@property NSDictionary *dictionry;
- (void)setTitle:(DocVO *)docVo;
@end
