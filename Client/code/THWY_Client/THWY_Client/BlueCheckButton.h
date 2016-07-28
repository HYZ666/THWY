//
//  BlueCheckButton.h
//  THWY_Client
//
//  Created by HuangYiZhe on 16/7/28.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlueCheckButton : UIButton
- (instancetype)initDefaultImageName:(NSString *)defaultImageName choosedImageName:(NSString *)choosedImageName title:(NSString *)title;
- (void)click;
@end
