//
//  adVO.h
//  YTWY_Client
//
//  Created by 史秀泽 on 2016/7/27.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileVO.h"

@interface AdVO : NSObject

@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *ctime;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *estate_ids;
@property BOOL is_tuijian;
@property NSMutableArray<FileVO *> * files;

- (AdVO *) initWithJSON:(NSDictionary *)JSON;

@end

