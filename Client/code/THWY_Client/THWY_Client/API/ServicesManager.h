//
//  ServicesManager.h
//  THWY_Client
//
//  Created by 史秀泽 on 2016/7/26.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "UDManager.h"
#import "UserVO.h"

@interface ServicesManager : NSObject

+(ServicesManager *)getAPI;

#pragma mark 环境参数判定函数
-(BOOL)isLogin;

#pragma mark 测试用函数
-(void)test;
@end
