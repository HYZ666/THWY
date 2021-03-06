//
//  TaskVO.m
//  YTWY_Server
//
//  Created by Mr.S on 16/8/7.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "TaskVO.h"

@implementation TaskVO

-(TaskVO* )initWithJSON:(NSDictionary *)JSON
{
    if (self = [super init]) {
        self.Id = JSON[@"id"];
        self.estate_id = JSON[@"estate_id"];
        self.st = JSON[@"st"];
        if (JSON[@"kb"]) {
            self.kb = JSON[@"kb"];
        }else
        {
            self.kb = nil;
        }
        if (JSON[@"order_ts"]) {
            self.order_ts = JSON[@"order_ts"];
        }else
        {
            self.order_ts = nil;
        }
        self.house_id = JSON[@"house_id"];
        self.st_0_time = JSON[@"st_0_time"];
        self.st_2_time = JSON[@"st_2_time"];
        self.st_3_time = JSON[@"st_3_time"];
        self.call_person = JSON[@"call_person"];
        self.call_phone = JSON[@"call_phone"];
        self.owner_public = JSON[@"owner_public"];
        self.estate_name = JSON[@"estate_name"];
        self.repair_classes = JSON[@"repair_classes"];
        self.block = JSON[@"block"];
        self.unit = JSON[@"unit"];
        self.layer = JSON[@"layer"];
        self.mph = JSON[@"mph"];
        self.classes_str = JSON[@"classes_str"];
    }
    
    return self;
}

@end
