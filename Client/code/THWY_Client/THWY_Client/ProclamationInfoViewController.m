//
//  ProclamationInfoViewController.m
//  THWY_Client
//
//  Created by HuangYiZhe on 16/8/14.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "ProclamationInfoViewController.h"
#import "ServicesManager.h"
@interface ProclamationInfoViewController ()<UIWebViewDelegate>
@property NoteVO *data;
@end

@implementation ProclamationInfoViewController

-(instancetype)init
{
    if (self = [super init]) {
        self.type = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    switch (self.type) {
        case 0:
            self.title = @"业主公告详情";
            break;
        case 1:
            self.title = @"商圈广告详情";
            break;
        default:
            break;
    }
    [self ViewInitSetting];
    [self getData];
    // Do any additional setup after loading the view.
}

- (void)ViewInitSetting
{
    
    UIImage *backGround = [UIImage imageNamed:@"背景2"];
    self.view.layer.contents = (id)backGround.CGImage;
}

- (void)getData
{
    if ([ServicesManager getAPI].status == NotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络访问错误"];
    }
    else
    {
        [SVProgressHUD showWithStatus:@"加载数据中，请稍等..."];
        switch (self.type) {
            case 0:
            {
                [[ServicesManager getAPI]getANote:self.proclamationId onComplete:^(NSString *errorMsg, NoteVO *complaint) {
                    if (errorMsg) {
                        [SVProgressHUD showErrorWithStatus:errorMsg];
                        
                    }
                    else
                    {
                        //                self.title = complaint.title;
                        [self createUI:complaint];
                    }
                    
                    
                }];
            }
                
                break;
            case 1:
            {
                [My_ServicesManager getAnAd:self.proclamationId onComplete:^(NSString *errorMsg, AdVO *ad) {
                    if (errorMsg) {
                        [SVProgressHUD showErrorWithStatus:errorMsg];
                        
                    }
                    else
                    {
                        //                self.title = complaint.title;
                        [self createUIWithAd:ad];
                    }
                }];
            }
                
                break;
                
            default:
                break;
        }
        
        
        
    }

}

- (void)createUI:(NoteVO *)noteVO
{
    self.data = noteVO;
    UIImageView *head = [[UIImageView alloc]init];
    UIImageView *right = [[UIImageView alloc]init];
    UILabel *titleLabel = [[UILabel alloc]init];
    UILabel *time = [[UILabel alloc]init];
    UILabel *content = [[UILabel alloc]init];
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(10, 10 , self.view.width - 20, 0)];

    head.frame = CGRectMake(0, 0, backView.width, 3);
    right.frame = CGRectMake(0, 0, 20, 20);
    right.center = CGPointMake(backView.width -9, 0);
    titleLabel.frame = CGRectMake(0, CGRectGetMaxY(head.frame) + 5, backView.width, 30);
    
    time.frame = CGRectMake(0, CGRectGetMaxY(titleLabel.frame), backView.width, 14);
    
    CGSize size = [noteVO.content sizeWithFont:FontSize(CONTENT_FONT) maxSize:CGSizeMake(backView.width - 20, 4000)];
    
    
    content.frame = CGRectMake(10, time.bottom + 10, backView.width - 20, size.height);
    if (noteVO.files.count != 0) {
        
        UILabel *fujian = [[UILabel alloc]initWithFrame:CGRectMake(10, content.bottom + 20, 60, 20)];
        fujian.text = @"附件：";
        fujian.textColor = CellUnderLineColor;
        [backView addSubview:fujian];
        
        CGFloat y = content.bottom + 20;
        CGFloat x = 60;
        for (int i = 0; i < noteVO.files.count; i ++ ) {
            
            CGFloat width = GetContentWidth(noteVO.files[i].file_name, Content_Time_Font);
            
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, y, width , Content_Time_Font)];
            [btn setTitle:noteVO.files[i].file_name forState:UIControlStateNormal];
            btn.titleLabel.font = FontSize(Content_Time_Font);
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            btn.tag = 400 + i;
            [btn addTarget:self action:@selector(clickFujian:) forControlEvents:UIControlEventTouchUpInside];
            y += Content_Time_Font + 5;
            
            [backView addSubview:btn];
            
            if (i == noteVO.files.count - 1) {
                if (fujian.bottom < btn.bottom) {
                    backView.height = btn.bottom + 10;
                    
                }
                else
                {
                    backView.height = fujian.bottom + 10;
                    
                }
            }
        }
        
    }
    else
    {
        backView.height = content.bottom + 10;
    }

    content.numberOfLines = 0;
    
    head.image = [UIImage imageNamed:@"彩条"];
    
    UIImageView *left = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    left.center = CGPointMake(19, 10);
    left.image = [UIImage imageNamed:@"左"];
    
    right.image = [UIImage imageNamed:@"右"];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    time.font = FontSize(Content_Time_Font);
    
    time.textAlignment = NSTextAlignmentCenter;
    
    time.textColor = [UIColor lightGrayColor];
    
    content.font = FontSize(CONTENT_FONT);
    [backView addSubview:titleLabel];
    [backView addSubview:time];
    [backView addSubview:head];
    [backView addSubview:content];
    [self.view addSubview:left];
    [backView addSubview:right];
    
    
    backView.backgroundColor = WhiteAlphaColor;
    
    [self.view addSubview:backView];
    
    titleLabel.text = noteVO.title;
    NSString *showtime = [NSString stringDateFromTimeInterval:[noteVO.ctime longLongValue] withFormat:@"YYYY-MM-dd HH:mm"];
    time.text = showtime;
    if ([noteVO.content rangeOfString:@"<"].location == 0 && [[noteVO.content substringFromIndex:noteVO.content.length - 1] isEqualToString:@">"]) {
        UIWebView* webView = [[UIWebView alloc]initWithFrame:CGRectMake(content.x, content.y, backView.width - 2*content.x, My_ScreenH)];
        webView.delegate = self;
        webView.scrollView.bounces = NO;
        webView.backgroundColor = [UIColor clearColor];
        [content removeFromSuperview];
        [backView addSubview:webView];
        
        NSString * htmlcontent = [NSString stringWithFormat:@"<div id=\"webview_content_wrapper\">%@</div>", noteVO.content];
        htmlcontent = [NSString stringWithFormat:@"<body width=%dpx style=\"word-wrap:break-word; font-family:Arial\">%@",(int)webView.width,htmlcontent];
        
        [webView loadHTMLString:htmlcontent baseURL:nil];
        
    }else
    {
        [SVProgressHUD dismiss];
        content.text = noteVO.content;
    }
    
}

- (void)createUIWithAd:(AdVO *)noteVO
{
        UIImageView *head = [[UIImageView alloc]init];
        UIImageView *right = [[UIImageView alloc]init];
        UILabel *titleLabel = [[UILabel alloc]init];
        UILabel *time = [[UILabel alloc]init];
        UILabel *content = [[UILabel alloc]init];
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(10, 10 , self.view.width - 20, 0)];
        
        head.frame = CGRectMake(0, 0, backView.width, 3);
        right.frame = CGRectMake(0, 0, 20, 20);
        right.center = CGPointMake(backView.width -9, 0);
        titleLabel.frame = CGRectMake(0, CGRectGetMaxY(head.frame) + 5, backView.width, 30);
        
        time.frame = CGRectMake(0, CGRectGetMaxY(titleLabel.frame), backView.width, 14);
        
        CGSize size = [noteVO.content sizeWithFont:FontSize(CONTENT_FONT) maxSize:CGSizeMake(backView.width - 20, 4000)];
        
        
        content.frame = CGRectMake(10, time.bottom + 10, backView.width - 20, size.height);
    
    
        content.numberOfLines = 0;
        backView.height = content.bottom + 10;
    
        head.image = [UIImage imageNamed:@"彩条"];
        
        UIImageView *left = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        left.center = CGPointMake(19, 10);
        left.image = [UIImage imageNamed:@"左"];
        
        right.image = [UIImage imageNamed:@"右"];
        
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        time.font = FontSize(Content_Time_Font);
        
        time.textAlignment = NSTextAlignmentCenter;
        
        time.textColor = [UIColor lightGrayColor];
        
        content.font = FontSize(CONTENT_FONT);
        [backView addSubview:titleLabel];
        [backView addSubview:time];
        [backView addSubview:head];
        [backView addSubview:content];
        [self.view addSubview:left];
        [backView addSubview:right];
        
        
        backView.backgroundColor = WhiteAlphaColor;
        
        [self.view addSubview:backView];
        
        titleLabel.text = noteVO.title;
        NSString *showtime = [NSString stringDateFromTimeInterval:[noteVO.ctime longLongValue] withFormat:@"YYYY-MM-dd HH:SS"];
        time.text = showtime;
        if ([noteVO.content rangeOfString:@"<"].location == 0 && [[noteVO.content substringFromIndex:noteVO.content.length - 1] isEqualToString:@">"]) {
            UIWebView* webView = [[UIWebView alloc]initWithFrame:CGRectMake(content.x, content.y, backView.width - 2*content.x, My_ScreenH)];
            webView.scrollView.bounces = NO;
            webView.delegate = self;
            webView.backgroundColor = My_clearColor;
            [content removeFromSuperview];
            [backView addSubview:webView];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"giveHeight" object:@[[NSNumber numberWithFloat:webView.bottom + 10]]];
            
            NSString * htmlcontent = [NSString stringWithFormat:@"<div id=\"webview_content_wrapper\">%@</div>", noteVO.content];
            htmlcontent = [NSString stringWithFormat:@"<body width=%dpx style=\"word-wrap:break-word; font-family:Arial\">%@",(int)webView.width,htmlcontent];
            [webView loadHTMLString:htmlcontent baseURL:nil];
            
        }else
        {
            [SVProgressHUD dismiss];
            content.text = noteVO.content;
        }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //获取页面高度（像素）
    NSString * clientheight_str = [webView stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"];
    float clientheight = [clientheight_str floatValue];
    //设置到WebView上
    webView.frame = CGRectMake(webView.x, webView.y, webView.width, clientheight);
    //获取WebView最佳尺寸（点）
    CGSize frame = [webView sizeThatFits:webView.frame.size];
    //获取内容实际高度（像素）
    NSString * height_str= [webView stringByEvaluatingJavaScriptFromString: @"document.getElementById('webview_content_wrapper').offsetHeight + parseInt(window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin-top'))  + parseInt(window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin-bottom'))"];
    float height = [height_str floatValue];
    //内容实际高度（像素）* 点和像素的比
    height = height * frame.height / clientheight;
    //再次设置WebView高度（点）
    
    if (height > My_ScreenH - 64 - 90/375.0*My_ScreenW) {
        height = My_ScreenH - 64 - 90/375.0*My_ScreenW;
    }
    webView.frame = CGRectMake(webView.x, webView.y, webView.width, height);
    
    webView.superview.height = webView.bottom + 10;
    
    [SVProgressHUD dismiss];
}

- (void)clickFujian:(UIButton *)btn
{
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.data.files[btn.tag - 400] showInVC:self];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
