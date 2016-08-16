//
//  RepairTaskVO.m
//  THWY_Server
//
//  Created by Mr.S on 16/8/5.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "RepairTaskVO.h"

@implementation RepairTaskVO

-(RepairTaskVO* )initWithJSON:(NSDictionary *)JSON
{
    if (self = [super init]) {
        self.Id = JSON[@"id"];
        self.acl_group_id = JSON[@"acl_group_id"];
        self.repair_id = JSON[@"repair_id"];
        self.acl_admin_id = JSON[@"acl_admin_id"];
        self.during = JSON[@"during"];
        self.group_name = JSON[@"group_name"];
        
        NSMutableArray* arr = [[NSMutableArray alloc]init];
        for (NSDictionary* adminDic in JSON[@"admins"]) {
            UserVO* user = [[UserVO alloc]initWithJSON:adminDic];
            [arr addObject:user];
        }
        self.admins = arr;
    }
    
    return self;
}

@end