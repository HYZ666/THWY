//
//  PersonInfoLabel.h
//  YTWY_Client
//
//  Created by HuangYiZhe on 16/7/29.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonInfoLabel : UIView

@property UITextField *textField;

- (void)setImageName:(NSString *)imageName Label:(NSString *)title TextField:(NSString *)placeholder;
- (void)setImageName:(NSString *)imageName Label:(NSString *)title infoTitle:(NSString *)infotitle;
//- (void)updateFrame;
- (void)setImageName:(NSString *)imageName Label:(NSString *)title Array:(NSArray *)array;
- (void)setNoEnable;
@end
