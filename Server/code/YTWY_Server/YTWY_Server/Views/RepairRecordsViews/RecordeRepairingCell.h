//
//  RecordeRepeiringCell.h
//  YTWY_Client
//
//  Created by wei on 16/8/3.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordeRepairingCell : UITableViewCell

@property UIViewController *vc;

@property (assign, nonatomic) NSInteger flag;

- (void)loadDataFromModel:(RepairVO *)repaireVO;

@end
