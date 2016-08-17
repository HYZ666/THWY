//
//  MBManager.m
//  snowonline
//
//  Created by 史秀泽 on 16/6/1.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "SVProgressHUD.h"
#import "UIImage+GIF.h"

@interface SVProgressHUD ()

@property (strong, nonatomic) MBProgressHUD* hud;
@property UIWindow* window;

@property UIImageView* loadingView;
@property UIImageView* loadingImv;
@property UILabel* loadingLabel;

@property UILabel* hintLabel;

@end

@implementation SVProgressHUD

+(instancetype)shareMBManager
{
    static SVProgressHUD* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SVProgressHUD alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.window = My_KeyWindow;
        self.hud = [[MBProgressHUD alloc]initWithView:self.window];
        [self.window addSubview:self.hud];
        [self hudInit];
    }
    return self;
}

-(void)hudInit
{
    [self.window bringSubviewToFront:self.hud];
    
    [self.loadingView removeFromSuperview];
    [self.loadingLabel removeFromSuperview];
    
    if (self.loadingLabel == nil) {
        self.loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.loadingLabel.backgroundColor = RGBColorFromX(333333);
        self.loadingLabel.layer.cornerRadius = 10;
        self.loadingLabel.clipsToBounds = YES;
        self.loadingLabel.numberOfLines = 0;
        self.loadingLabel.adjustsFontSizeToFitWidth = YES;
        self.loadingLabel.font = FontSize(CONTENT_FONT);
        
        self.loadingLabel.textColor = [UIColor whiteColor];
        self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    self.loadingLabel.height = My_ScreenH/3;
    self.loadingLabel.width = My_ScreenW/3*2;
    
    if (self.loadingView == nil) {
        self.loadingView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 220, 70)];
        self.loadingView.backgroundColor = [UIColor blackColor];
        
        self.loadingImv = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.loadingView.height - 10, self.loadingView.height - 10)];
        self.loadingImv.backgroundColor = My_RandomColor;
        [self.loadingView addSubview:self.loadingImv];
        
        self.hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.loadingImv.right + 10, self.loadingImv.top, self.loadingView.width - self.loadingImv.right - 10, self.loadingImv.height)];
        self.hintLabel.numberOfLines = 0;
        self.hintLabel.textColor = [UIColor whiteColor];
        [self.loadingView addSubview:self.hintLabel];
    }
    
    self.hud.removeFromSuperViewOnHide = NO;
    self.hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.hud.backgroundView.color = My_AlphaColor(0, 0, 0, 0.01);
    self.hud.bezelView.color = [UIColor clearColor];
    self.hud.bezelView.clipsToBounds = NO;
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.animationType = MBProgressHUDAnimationZoom;
    self.hud.label.text = @"";
    [self.hud setOffset:CGPointMake(0, 0)];
}

#pragma mark -Public
+(void)showErrorWithStatus:(NSString*)title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self shareMBManager] hudHideWithText:title];
    });
}

+(void)hudHideWithSuccess:(NSString*)title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self shareMBManager] hudHideWithSuccess:title];
    });
}

+(void)showWithStatus:(NSString*)title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self shareMBManager] showLoadingWithTitle:title];
    });
}

+(void)dismiss
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self shareMBManager] hud] hideAnimated:YES];
    });
}

#pragma mark -Private
-(void)hudHideWithText:(NSString*)title
{
    [self hudInit];
    [self.hud showAnimated:YES];
    
    self.loadingLabel.width = [title sizeWithFont:self.loadingLabel.font maxSize:self.loadingLabel.size].width + 40;
    self.loadingLabel.height = [title sizeWithFont:self.loadingLabel.font maxSize:self.loadingLabel.size].height + 20;
    self.loadingLabel.center = CGPointMake(20, 20);
    
    self.loadingLabel.text = title;
    
    [self.hud setOffset:CGPointMake(0, My_ScreenH - self.loadingLabel.height - 100)];
    
    [self.hud.bezelView addSubview:self.loadingLabel];
    [self.hud.bezelView bringSubviewToFront:self.loadingLabel];
    
    [self.hud hideAnimated:YES afterDelay:1.5];
}

-(void)hudHideWithSuccess:(NSString*)title
{
    [self hudHideWithText:title];
}

-(void)showLoadingWithTitle:(NSString*)title
{
    [self hudInit];
    [self.hud showAnimated:YES];
    
    self.loadingLabel.width = [title sizeWithFont:self.loadingLabel.font maxSize:self.loadingLabel.size].width + 40;
    self.loadingLabel.height = [title sizeWithFont:self.loadingLabel.font maxSize:self.loadingLabel.size].height + 20;
    self.loadingLabel.center = CGPointMake(20, 20);
    
    self.loadingLabel.text = title;
    
    [self.hud.bezelView addSubview:self.loadingLabel];
    [self.hud.bezelView bringSubviewToFront:self.loadingLabel];
}
@end
