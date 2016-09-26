//
//  MySegmentedControl.m
//  YTWY_Client
//
//  Created by wei on 16/8/12.
//  Copyright © 2016年 SXZ. All rights reserved.
//

#import "MySegmentedControl.h"

@implementation MySegmentedControl

- (instancetype)initWithItems:(NSArray *)items{
    
    if (self = [super initWithItems:items]) {
        [self addTarget:self action:@selector(selected:) forControlEvents:UIControlEventValueChanged];
//        self.layer.cornerRadius = 6;
        [self setClipsToBounds:YES];
        self.tintColor = My_NAV_BG_Color;
        self.backgroundColor = [UIColor clearColor];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:My_NAV_BG_Color,NSForegroundColorAttributeName,FontSize(18.0),NSFontAttributeName ,nil];
        [self setTitleTextAttributes:dic forState:UIControlStateNormal];
    }
    return self;
    
}

- (void)selected:(UISegmentedControl *)sender{
    NSInteger index = sender.selectedSegmentIndex;
    [self.delegate segmentSelectIndex:index];
}

@end
