//
//  FindFriendTableViewCell.h
//  THWY_Server
//
//  Created by HuangYiZhe on 16/8/27.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindFriendTableViewCell : UITableViewCell
@property NSString *admin_id;
- (void)setIcon:(NSString *)icon NameAndphone:(NSString *)nameAndPhone EstateAndJob:(NSString *)estateAndJob;
@end
