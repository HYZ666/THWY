//
//  NoticVO.h
//  YTWY_Server
//
//  Created by Mr.S on 16/8/1.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileVO.h"

@interface NoticVO : NSObject

@property NSString                 * Id;
@property NSString                 * note_txt_type_id;
@property NSString                 * title;
@property NSString                 * content;
@property NSString                 * ctime;
@property NSString                 * note_type;
@property NSMutableArray<FileVO *> * files;

-(NoticVO* )initWithJSON:(NSDictionary *)JSON;

@end
