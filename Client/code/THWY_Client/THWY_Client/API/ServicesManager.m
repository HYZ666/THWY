//
//  ServicesManager.m
//  THWY_Client
//
//  Created by 史秀泽 on 2016/7/26.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "ServicesManager.h"
#import "UMessage.h"

@interface ServicesManager ()
{
    NSString* _userName;
    NSString* _passWord;
    NSArray* _statesList;
}

@property (nonatomic, strong) Reachability* baiduReach;

@end

@implementation ServicesManager

+(ServicesManager *)getAPI
{
    static ServicesManager *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc] init];
    });
    return service;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.baiduReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
        
        [My_NoteCenter addObserver:self
                          selector:@selector(reachabilityChanged)
                              name:kReachabilityChangedNotification
                            object:nil];
        
        self.status = 3;
        [self.baiduReach startNotifier];
        
        if ([self isLogin]) {
            _userName = [[UDManager getUD] getUserName];
            _passWord = [[UDManager getUD] getPassWord];
        }
    }
    return self;
}

//检测到网络状态改变
-(void)reachabilityChanged
{
    if (self.baiduReach.currentReachabilityStatus != self.status) {
        self.status = self.baiduReach.currentReachabilityStatus;
        
        [My_NoteCenter postNotificationName:NetWorkChanged object:[NSNumber numberWithInteger:self.status]];
    }
}

#pragma mark 私有函数
- (AFHTTPSessionManager *)getManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    if (self.status == 0) {
//        [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
//    }else
//    {
//        [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
//    }
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    return manager;
}

-(UIImage *)getFitImageData:(UIImage *)image{
    
    float imageRatio = image.size.width/image.size.height;
    UIImage *newImage;
    if (image.size.width > 500 ||
        image.size.height > 500) {
        if (image.size.width > image.size.height) {
            newImage = [self imageWithImage:image scaledToSize:CGSizeMake(500, 500/imageRatio)];
        }else{
            newImage = [self imageWithImage:image scaledToSize:CGSizeMake(500*imageRatio, 500)];
        }
    }else{
        newImage = image;
    }
    
    return newImage;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)convertVideoQuailtyWithInputURL:(NSString*)inputStr
                               outputURL:(NSURL*)outputURL
                         completeHandler:(void (^)(AVAssetExportSession*))handler
{
    NSURL* inputURL = nil;
    if (inputStr.length != 0) {
        inputURL = [NSURL URLWithString:inputStr];
    }else
    {
        handler(nil);
        return;
    }
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
    
}

- (CGFloat) getFileSize:(NSString *)path
{
    NSLog(@"%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }else{
        NSLog(@"找不到文件");
    }
    return filesize;
}//此方法可以获取文件的大小，返回的是单位是KB。
- (CGFloat) getVideoLength:(NSURL *)URL
{
    
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}//此方法可以获取视频文件的时长。


-(void)handleRepair:(Repair_RootVO *)repair params:(NSDictionary* )params urlStr:(NSString* )urlString onComplete:(void (^)(NSString *errorMsg))onComplete
{
    NSData *imageData = nil;
    if (repair.image) {
        imageData = UIImageJPEGRepresentation(repair.image, 1);
    }
    
    CGFloat sizeOfImage = imageData.length/1000.0/1024.0;
    CGFloat ratio = 0.95;
    while (sizeOfImage >= 2.0) {
        [SVProgressHUD showSubTitle:@"压缩图片"];
        imageData = UIImageJPEGRepresentation(repair.image, ratio);
        sizeOfImage = imageData.length/1000.0/1024.0;
        ratio -= 0.05;
    }
    
    if (repair.videoPath.length > 0) {
        [SVProgressHUD showSubTitle:@"转换视频格式"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        
        NSURL *newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", str]] ;
        [self convertVideoQuailtyWithInputURL:repair.videoPath outputURL:newVideoUrl completeHandler:^(AVAssetExportSession * exportSession) {
            
            switch (exportSession.status) {
                case AVAssetExportSessionStatusCancelled:
                {
                    onComplete(@"Cancelled");
                    NSLog(@"AVAssetExportSessionStatusCancelled");
                }
                    break;
                case AVAssetExportSessionStatusUnknown:
                {
                    onComplete(@"Unknown");
                    NSLog(@"AVAssetExportSessionStatusUnknown");
                }
                    break;
                case AVAssetExportSessionStatusWaiting:
                {
                    onComplete(@"Waiting");
                    NSLog(@"AVAssetExportSessionStatusWaiting");
                }
                    break;
                case AVAssetExportSessionStatusExporting:
                {
                    onComplete(@"Exporting");
                    NSLog(@"AVAssetExportSessionStatusExporting");
                }
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:newVideoUrl]]);
                    NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[newVideoUrl path]]]);
                    NSData *videoData = [NSData dataWithContentsOfURL:newVideoUrl];
                    [self subMitRepair:params image:imageData video:videoData urlString:urlString onComplete:onComplete];
                }
                    break;
                case AVAssetExportSessionStatusFailed:
                {
                    onComplete(@"Failed");
                    NSLog(@"AVAssetExportSessionStatusFailed");
                }
                    break;
                default:
                    break;
            }
        }];
    }else
    {
        [self subMitRepair:params image:imageData video:nil urlString:urlString onComplete:onComplete];
    }
    
}

-(void)subMitRepair:(NSDictionary* )params image:(NSData* )imageData video:(NSData *)videoData urlString:(NSString *)urlString onComplete:(void (^)(NSString *errorMsg))onComplete
{
    [SVProgressHUD showSubTitle:@"上传中 0.00％"];
    AFHTTPSessionManager *manager = [self getManager];
    [manager POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [NSString stringWithFormat:@"%@%d",[formatter stringFromDate:[NSDate date]],arc4random() % 99999];
        
        if (imageData) {
            NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
            [formData appendPartWithFileData:imageData name:@"pic" fileName:fileName mimeType:@"image/png"];
        }
        if (videoData) {
            NSString *fileName = [NSString stringWithFormat:@"%@.mp4", str];
            [formData appendPartWithFileData:videoData name:@"vdo" fileName:fileName mimeType:@"video/mp4"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        [SVProgressHUD showSubTitle:[NSString stringWithFormat:@"上传中 %.2f％",uploadProgress.fractionCompleted*100]];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg);
            }];
        }else
        {
            onComplete(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误");
    }];
}

#pragma mark 公共函数
-(void)login:(NSString *)userName
    password:(NSString *)password
savePassWord:(BOOL)save
  onComplete:(void (^)(NSString *errorMsg,UserVO *user))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@login",API_HOST];
    NSDictionary *params = @{@"login_name":userName,
                             @"login_password":password};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            _userName = userName;
            _passWord = password;
            
            UserVO* user = [[UserVO alloc]initWithJSON:responseObject[@"datas"]];
            
            NSMutableArray* tagArr = [[NSMutableArray alloc]initWithObjects:@"owner",[NSString stringWithFormat:@"owner_id_%@",user.Id], nil];
            
            for (HouseVO* house in user.houses) {
                [tagArr addObject:[NSString stringWithFormat:@"estate_id_%@",house.estate_id]];
            }
            
            [UMessage removeAllTags:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
                [UMessage addTag:tagArr response:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
                    [UMessage getTags:^(NSSet * _Nonnull responseTags, NSInteger remain, NSError * _Nonnull error) {
                        
                    }];
                }];
            }];
            
            [[UDManager getUD] saveUser:user];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UDManager getUD] saveUserName:userName];
                [[UDManager getUD] saveUserPassWord:password];
                [[UDManager getUD] saveShowState:save];
                
                [[UDManager getUD] saveSoundState:YES];
                [[UDManager getUD] saveShakeState:YES];
            });
            
            onComplete(nil,user);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)logOut:(void (^)())onComplete
{
    [[UDManager getUD] removeUDUser];
    [UMessage removeAllTags:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
        
    }];
    onComplete();
}

-(void)getUserInfoOnComplete:(void (^)(NSString *errorMsg,UserVO *user))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_my_info",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            UserVO* user = [[UserVO alloc]initWithJSON:responseObject[@"datas"]];
            NSMutableArray* tagArr = [[NSMutableArray alloc]initWithObjects:@"owner",[NSString stringWithFormat:@"owner_id_%@",user.Id], nil];
            
            for (HouseVO* house in user.houses) {
                [tagArr addObject:[NSString stringWithFormat:@"estate_id_%@",house.estate_id]];
            }
            
            [UMessage removeAllTags:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
                [UMessage addTag:tagArr response:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
                    
                }];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UDManager getUD] saveUser:user];
            });
            onComplete(nil,user);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)editUserInfo:(NSString *)phoneNum
          carNumber:(NSString *)carNumber
        newUserName:(NSString *)newUserName
        newPassWord:(NSString *)newPassWord
         onComplete:(void (^)(NSString *errorMsg))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@edit_my_info",API_HOST];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    params[@"login_name"] = _userName;
    params[@"login_password"] = _passWord;
    
    if (carNumber.length > 0) {
        if (![carNumber isEqualToString:[[UDManager getUD] getUser].car_number]) {
            params[@"car_number"] = carNumber;
        }
    }
    
    if (newUserName.length > 0) {
        if (![newUserName isEqualToString:_userName]) {
            params[@"new_login_name"] = newUserName;
        }
    }

    if (newPassWord.length > 0) {
        if (![newPassWord isEqualToString:_passWord]) {
            params[@"new_login_password"] = newPassWord;
        }
    }
    
    if (params.count == 0 && [phoneNum isEqualToString:[[UDManager getUD] getUser].cellphone]) {
        onComplete(@"nil");
        return;
    }else
    {
        if (phoneNum.length == 0) {
            onComplete(@"手机号为必填");
            return;
        }
        params[@"cellphone"] = phoneNum;
    }
    
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg);
            }];
        }else
        {
            if (newUserName.length > 0) {
                _userName = newUserName;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UDManager getUD] saveUserName:newUserName];
                });
            }
            
            if (newPassWord.length > 0) {
                _passWord = newPassWord;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UDManager getUD] saveUserPassWord:newPassWord];
                });
            }
            onComplete(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误");
    }];
}

-(void)upLoadAvatar:(UIImage *)image OnComplete:(void (^)(NSString *errorMsg, NSString *avatar))onComplete
{
    UIImage *newImage = [self getFitImageData:image];
    NSData *data = UIImagePNGRepresentation(newImage);
    
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@avatar",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord};
    [manager POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
        
        [formData appendPartWithFileData:data name:@"pic" fileName:fileName mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            
            onComplete(nil,responseObject[@"datas"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getUserPoints:(void (^)(NSString *errorMsg,NSString *point))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@points",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            onComplete(nil,responseObject[@"datas"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getUserPointsHistory:(int)pageNum onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    pageNum++;
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@points_history",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"page":[NSString stringWithFormat:@"%d",pageNum]};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"][@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* historyDic in responseObject[@"datas"][@"datas"]) {
                    PointHistoryVO *history = [[PointHistoryVO alloc]initWithJSON:historyDic];
                    [listArr addObject:history];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getFeedBackTypes:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_guest_book_type",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* typeDic in responseObject[@"datas"]) {
                    FeedBackTypeVO *type = [[FeedBackTypeVO alloc]initWithJSON:typeDic];
                    [listArr addObject:type];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getFeedBackList:(NSString* )typeId onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@guest_book",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"category":typeId};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"][@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* feedBackDic in responseObject[@"datas"][@"datas"]) {
                    FeedBackVO *feedBack = [[FeedBackVO alloc]initWithJSON:feedBackDic];
                    [listArr addObject:feedBack];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)addFeedBack:(int)type content:(NSString *)content onComplete:(void (^)(NSString *errorMsg))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@add_guest_book",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"category":[NSString stringWithFormat:@"%d",type],
                             @"content":content};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg);
            }];
        }else
        {
            onComplete(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误");
    }];
}

-(void)getComplaintStates:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_complaints_status",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* complaintStateDic in responseObject[@"datas"]) {
                    ComplaintStateVO *state = [[ComplaintStateVO alloc]initWithJSON:complaintStateDic];
                    [listArr addObject:state];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getComplaintTypes:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@complaints_type",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* complaintTypeDic in responseObject[@"datas"]) {
                    ComplaintTypeVO *type = [[ComplaintTypeVO alloc]initWithJSON:complaintTypeDic];
                    [listArr addObject:type];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getComplaints:(int)page onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    page++ ;
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@complaints",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"page":[NSString stringWithFormat:@"%d",page]};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            [self getComplaintStates:^(NSString *errorMsg, NSArray *list) {
                if (errorMsg == nil) {
                    NSMutableArray* listArr = [[NSMutableArray alloc]init];
                    if ([responseObject[@"datas"][@"datas"] isKindOfClass:[NSArray class]]) {
                        for (NSDictionary* complaintDic in responseObject[@"datas"][@"datas"]) {
                            ComplaintVO *complaint = [[ComplaintVO alloc]initWithJSON:complaintDic];
                            for (ComplaintStateVO* state in list) {
                                if ([state.st integerValue] == [complaint.st integerValue]) {
                                    complaint.state = state;
                                }
                            }
                            [listArr addObject:complaint];
                        }
                    }
                    
                    onComplete(nil,listArr);
                }else
                {
                    onComplete(errorMsg,nil);
                }
                
            }];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getAComplaint:(NSString *)complaintId onComplete:(void (^)(NSString *errorMsg,ComplaintVO *complaint))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@complaint",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"id":complaintId};
    
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            ComplaintVO *complaint = [[ComplaintVO alloc]initWithJSON:responseObject[@"datas"]];
            if (_statesList) {
                for (ComplaintStateVO* state in _statesList) {
                    if ([state.st intValue] == [complaint.st intValue]) {
                        complaint.state = state;
                        break ;
                    }
                }
                onComplete(nil,complaint);
            }else
            {
                [self getComplaintStates:^(NSString *errorMsg, NSArray *list) {
                    if (errorMsg) {
                        onComplete(nil,complaint);
                    }else
                    {
                        _statesList = list;
                        for (ComplaintStateVO* state in _statesList) {
                            if ([state.st intValue] == [complaint.st intValue]) {
                                complaint.state = state;
                                break ;
                            }
                        }
                        onComplete(nil,complaint);
                    }
                    
                }];
            }
            
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)addComplaint:(ComplaintVO *)complaint onComplete:(void (^)(NSString *errorMsg))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@add_complain",API_HOST];
    NSMutableDictionary *params = [complaint toDic];
    params[@"login_name"] = _userName;
    params[@"login_password"] = _passWord;
    
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg);
            }];
        }else
        {
            onComplete(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误");
    }];
}

-(void)getNotes:(int)page onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    page++;
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_notes",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"page":[NSString stringWithFormat:@"%d",page]};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"][@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* noteDic in responseObject[@"datas"][@"datas"]) {
                    NoteVO *note = [[NoteVO alloc]initWithJSON:noteDic];
                    [listArr addObject:note];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getANote:(NSString *)noteId onComplete:(void (^)(NSString *errorMsg,NoteVO *complaint))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_note",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"id":noteId};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NoteVO *note = [[NoteVO alloc]initWithJSON:responseObject[@"datas"]];
            onComplete(nil,note);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getMerchantTypes:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_merchant_type",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* merchantTypeDic in responseObject[@"datas"]) {
                    MerchantTypeVO *type = [[MerchantTypeVO alloc]initWithJSON:merchantTypeDic];
                    [listArr addObject:type];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getRecommendMerchants:(int)page onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    page++;
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_tuijian_merchant",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"page":[NSString stringWithFormat:@"%d",page]};
    
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"][@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* merchantDic in responseObject[@"datas"][@"datas"]) {
                    MerchantVO *merchant = [[MerchantVO alloc]initWithJSON:merchantDic];
                    [listArr addObject:merchant];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getMerchants:(int)page typeId:(NSString *)typeId name:(NSString* )name onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    page++;
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@merchants",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"page":[NSString stringWithFormat:@"%d",page]};
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithDictionary:params];
    if (name.length > 0) {
        dic[@"merchant_name_like"] = name;
    }
    if (typeId.length > 0) {
        dic[@"merchant_type_id"] = typeId;
    }
    
    [manager GET:urlString parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"][@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* merchantDic in responseObject[@"datas"][@"datas"]) {
                    MerchantVO *merchant = [[MerchantVO alloc]initWithJSON:merchantDic];
                    [listArr addObject:merchant];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getAMerchant:(NSString *)merchantId onComplete:(void (^)(NSString *errorMsg,MerchantVO *merchant))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@merchant",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"id":merchantId};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            MerchantVO *merchant = [[MerchantVO alloc]initWithJSON:responseObject[@"datas"]];
            onComplete(nil,merchant);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getRecommendGoods:(int)page onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    page++;
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@recommend",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"page":[NSString stringWithFormat:@"%d",page]};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"][@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* goodDic in responseObject[@"datas"][@"datas"]) {
                    GoodVO *good = [[GoodVO alloc]initWithJSON:goodDic];
                    [listArr addObject:good];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getAGood:(NSString *)goodId onComplete:(void (^)(NSString *errorMsg,GoodVO *merchant))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@recommend_view",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"id":goodId};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            GoodVO *merchant = [[GoodVO alloc]initWithJSON:responseObject[@"datas"]];
            onComplete(nil,merchant);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getAds:(int)page onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    page++;
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@ads",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"page":[NSString stringWithFormat:@"%d",page]};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"][@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* adDic in responseObject[@"datas"][@"datas"]) {
                    AdVO *ad = [[AdVO alloc]initWithJSON:adDic];
                    [listArr addObject:ad];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getAnAd:(NSString *)adId onComplete:(void (^)(NSString *errorMsg,AdVO *ad))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@ad",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"id":adId};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            AdVO *ad = [[AdVO alloc]initWithJSON:responseObject[@"datas"]];
            onComplete(nil,ad);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getRecommendAds:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_tuijian_ads",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* adDic in responseObject[@"datas"]) {
                    AdVO *ad = [[AdVO alloc]initWithJSON:adDic];
                    [listArr addObject:ad];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getFees:(int)page year:(int)year feeState:(FeeState)state onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    page++;
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@fee_histories",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"page":[NSString stringWithFormat:@"%d",page]};
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithDictionary:params];
    if (year > 0) {
        dic[@"year"] = [NSString stringWithFormat:@"%d",year];
    }
    if (state != All) {
        dic[@"st"] = [NSString stringWithFormat:@"%d",state];
    }
    
    [manager GET:urlString parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"][@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* feeDic in responseObject[@"datas"][@"datas"]) {
                    FeeVO *fee = [[FeeVO alloc]initWithJSON:feeDic];
                    [listArr addObject:fee];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getAFee:(NSString *)feeId onComplete:(void (^)(NSString *errorMsg,FeeVO *ad))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@fee_history",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"id":feeId};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            FeeVO *fee = [[FeeVO alloc]initWithJSON:responseObject[@"datas"]];
            onComplete(nil,fee);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getEstates:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_estates",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* estateDic in responseObject[@"datas"]) {
                    EstateVO *estate = [[EstateVO alloc]initWithJSON:estateDic];
                    [listArr addObject:estate];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getBlock:(NSString *)estateId onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_estate_block",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"estate_id":estateId};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* estateDic in responseObject[@"datas"]) {
                    [listArr addObject:estateDic[@"block"]];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getUnit:(NSString *)estateId block:(NSString *)block onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_estate_block_unit",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"estate_id":estateId,
                             @"block":block};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* estateDic in responseObject[@"datas"]) {
                    [listArr addObject:estateDic[@"unit"]];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getLayer:(NSString *)estateId block:(NSString *)block unit:(NSString *)unit onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_estate_block_unit_layer",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"estate_id":estateId,
                             @"block":block,
                             @"unit":unit};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* estateDic in responseObject[@"datas"]) {
                    [listArr addObject:estateDic[@"layer"]];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getRepairStatus:(RepairType)type onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = @"";
    
    if (type == Owner) {
        urlString = [NSString stringWithFormat:@"%@get_repair_status",API_HOST];
    }else if (type == Public){
        urlString = [NSString stringWithFormat:@"%@get_public_repair_status",API_HOST];
    }else{
        onComplete(@"请填写type",nil);
        NSLog(@"请填写type");
        return;
    }
    
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* estateDic in responseObject[@"datas"]) {
                    RepairStatuVO *estate = [[RepairStatuVO alloc]initWithJSON:estateDic];
                    [listArr addObject:estate];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getRepairs:(RepairType)type page:(int)page repairStatu:(NSString *)statuId onComplete:(void (^)(NSString *errorMsg,NSArray *list))onComplete
{
    page++;
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = @"";
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"page":[NSString stringWithFormat:@"%d",page]};
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithDictionary:params];
    NSString* key = @"";
    
    if (type == Owner) {
        key = @"repair_status";
        urlString = [NSString stringWithFormat:@"%@repairs",API_HOST];
    }else if (type == Public){
        key = @"st";
        urlString = [NSString stringWithFormat:@"%@public_repairs",API_HOST];
    }else{
        onComplete(@"请填写type",nil);
        NSLog(@"请填写type");
        return;
    }
    
    if (statuId.length > 0) {
        dic[key] = statuId;
    }
    [manager GET:urlString parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else{
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"][@"datas"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* estateDic in responseObject[@"datas"][@"datas"]) {
                    RepairVO *estate = [[RepairVO alloc]initWithJSON:estateDic];
                    [listArr addObject:estate];
                }
            }
            
            onComplete(nil,listArr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getARepair:(RepairType)type repairId:(NSString *)repairId onComplete:(void (^)(NSString *errorMsg,RepairVO *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    
    NSString *urlString = @"";
    if (type == Owner) {
        urlString = [NSString stringWithFormat:@"%@repair",API_HOST];
    }else if (type == Public){
        urlString = [NSString stringWithFormat:@"%@public_repair",API_HOST];
    }else{
        onComplete(@"请填写type",nil);
        NSLog(@"请填写type");
        return;
    }
    
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord,
                             @"id":repairId};
    
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            RepairVO *estate = [[RepairVO alloc]initWithJSON:responseObject[@"datas"]];
            onComplete(nil,estate);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(void)getRepairClasses:(RepairType)type onComplete:(void (^)(NSString *errorMsg,NSDictionary *list))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = @"";
    if (type == Owner) {
        urlString = [NSString stringWithFormat:@"%@get_repair_cls",API_HOST];
    }else if (type == Public){
        urlString = [NSString stringWithFormat:@"%@get_public_repair_cls",API_HOST];
    }else{
        onComplete(@"请填写type",nil);
        NSLog(@"请填写type");
        return;
    }
    
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord};
    
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil);
            }];
        }else
        {
            if (type == Owner) {
                RepairClassVO *class1 = [[RepairClassVO alloc]initWithJSON:responseObject[@"datas"][@"for_pay"]];
                RepairClassVO *class2 = [[RepairClassVO alloc]initWithJSON:responseObject[@"datas"][@"for_free"]];
                
                NSLog(@"");
                onComplete(nil,@{@"for_pay":[self lastArr:class1],
                                 @"for_free":[self lastArr:class2]});
            }else if (type == Public){
                RepairClassVO *class = [[RepairClassVO alloc]initWithJSON:responseObject[@"datas"]];
                onComplete(nil,@{@"public":class});
            }
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil);
    }];
}

-(NSMutableArray *)lastArr:(RepairClassVO *)class1
{
    NSMutableArray* class1Arr = [[NSMutableArray alloc]init];
    [self classArr:class1Arr andClass:class1];
    
    NSMutableArray* supClassPids = [[NSMutableArray alloc]init];
    for (RepairClassVO* subClass in class1Arr) {
        [supClassPids addObject:subClass.pid];
    }
    
    NSArray* supPid = [NSArray arrayWithArray:supClassPids];
    [supClassPids removeAllObjects];
    for (NSString* pid in supPid) {
        BOOL isIn = NO;
        for (RepairClassVO* p in supClassPids) {
            if ([p.Id isEqualToString:pid]) {
                isIn = YES;
                break;
            }
        }
        if (!isIn) {
            [supClassPids addObject:[self foundSuperClass:pid inClass:class1]];
        }
    }
    
    for (RepairClassVO* subClass in class1Arr) {
        for (RepairClassVO* supClass in supClassPids) {
            if ([subClass.pid isEqualToString:supClass.Id]) {
                [supClass.child addObject:subClass];
                break;
            }
        }
    }
    
    return supClassPids;
}

-(RepairClassVO *)foundSuperClass:(NSString* )Id inClass:(RepairClassVO *)class
{
    if ([class.Id isEqualToString:Id]) {
        return class;
    }else if(class.child.count == 0)
    {
        return nil;
    }else
    {
        for (RepairClassVO * subClass in class.child) {
            if ([self foundSuperClass:Id inClass:subClass]) {
                RepairClassVO* supClass = [self foundSuperClass:Id inClass:subClass];
                [supClass.child removeAllObjects];
                return supClass;
            }
        }
    }
    return nil;
}

-(void)classArr:(NSMutableArray *)arr andClass:(RepairClassVO *)class
{
    for (RepairClassVO* subClass in class.child) {
        if (subClass.child.count > 0) {
            [self classArr:arr andClass:subClass];
        }else
        {
            [arr addObject:subClass];
        }
    }
}

-(void)addRepair:(AddRepairVO *)repair onComplete:(void (^)(NSString *errorMsg))onComplete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@add_repair",API_HOST];
        NSMutableDictionary* params = [[NSMutableDictionary alloc]initWithDictionary:[repair toDic]];
        params[@"login_name"] = _userName;
        params[@"login_password"] = _passWord;
        
        [self handleRepair:repair params:params urlStr:urlString onComplete:onComplete];
    });
    
}

-(void)addPublicRepair:(AddPublicRepairVO *)repair onComplete:(void (^)(NSString *errorMsg))onComplete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@add_public_repair",API_HOST];
        NSMutableDictionary* params = [[NSMutableDictionary alloc]initWithDictionary:[repair toDic]];
        params[@"login_name"] = _userName;
        params[@"login_password"] = _passWord;
        
        [self handleRepair:repair params:params urlStr:urlString onComplete:onComplete];
    });
    
}

-(void)getMyPoints:(void (^)(NSString *errorMsg,NSArray* list,NSString *total))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@my_points",API_HOST];
    NSDictionary *params = @{@"login_name":_userName,
                             @"login_password":_passWord};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg,nil,nil);
            }];
        }else
        {
            NSMutableArray* listArr = [[NSMutableArray alloc]init];
            if ([responseObject[@"datas"][@"types"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary* pointDic in responseObject[@"datas"][@"types"]) {
                    PointVO* point = [[PointVO alloc]initWithJSON:pointDic];
                    [listArr addObject:point];
                }
            }
            
            onComplete(nil,listArr,responseObject[@"datas"][@"total"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误",nil,nil);
    }];
}

-(void)sendCode:(NSString *)name phoneNum:(NSString *)phoneNum onComplete:(void (^)(NSString *errorMsg))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_password_forgotten_sms_code",API_HOST];
    NSDictionary *params = @{@"login_name":name,
                             @"cellphone":phoneNum};
    
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject[@"code"] onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg);
            }];
        }else
        {
            
            onComplete(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误");
    }];
}

-(void)setNewPassword:(NSString *)name phoneNum:(NSString *)phoneNum code:(NSString *)code newPassword:(NSString *)newPassword onComplete:(void (^)(NSString *errorMsg))onComplete
{
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@set_new_password",API_HOST];
    NSDictionary *params = @{@"login_name":name,
                             @"cellphone":phoneNum,
                             @"sms_code":code,
                             @"new_password":newPassword};
    
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 0) {
            [self getErrorMessage:responseObject[@"code"] onComplete:^(NSString *errorMsg) {
                onComplete(errorMsg);
            }];
        }else
        {
            
            onComplete(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onComplete(@"网络连接错误");
    }];
}

#pragma mark 环境参数判定函数
-(BOOL)isLogin{
    UserVO *user = [[UDManager getUD] getUser];
    return user != nil;
}

-(void)getErrorMessage:(NSDictionary *)responseObject
            onComplete:(void (^)(NSString *errorMsg))onComplete
{
    NSNumber* code = responseObject[@"code"];
    if ([code intValue] == -1) {
        if ([responseObject[@"datas"] isKindOfClass:[NSString class]] && [responseObject[@"datas"] length]>0) {
            NSLog(@"%@",responseObject[@"datas"]);
            onComplete(responseObject[@"datas"]);
            return;
        }
    }
    
    AFHTTPSessionManager *manager = [self getManager];
    NSString *urlString = [NSString stringWithFormat:@"%@get_op_msg_by_code",API_HOST];
    NSDictionary *params = @{@"k":code};
    [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject[@"datas"]);
        onComplete(responseObject[@"datas"]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {\
        NSLog(@"网络连接错误");
        onComplete(@"网络连接错误");
    }];
}

#pragma mark 测试用函数
-(void)test
{
    if ([self isLogin]) {
//        [self getMyPoints:^(NSString *errorMsg, NSArray *list, NSString *total) {
//            
//        }];
    }else
    {
//        [self login:@"zhanghao" password:@"111111" onComplete:^(NSString *errorMsg, UserVO *user) {
//            if (errorMsg == nil) {
//                [self test];
//            }
//        }];
    }
    
    
}
@end
