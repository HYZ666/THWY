//
//  WRAlertView.h
//  YTWY_Server
//
//  Created by HuangYiZhe on 16/8/25.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface WRAlertView : UIView
@property BOOL reviseStatu;
@property NSString *typeId;
@property BOOL is_public;
- (void)setDoc:(DocVO *)doc;
@end
