//
//  TranscribeVoiceView.m
//  SDChatDemo
//
//  Created by songjc on 16/12/9.
//  Copyright © 2016年 Don9. All rights reserved.
//

#import "TranscribeVoiceView.h"

@implementation TranscribeVoiceView

-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        
        self.imgview =[[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/4, (self.frame.size.height-self.frame.size.width/2)/2, self.frame.size.width/2, self.frame.size.width/2)];
        self.imgview.image = [UIImage imageNamed:@"录制语音"];
        [self addSubview:self.imgview];
        
        self.textLable = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2+self.frame.size.width/4, self.frame.size.width, (self.frame.size.height-self.frame.size.width/2)/2)];
        self.textLable .text = @"正在录制语音";
        self.textLable .font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        self.textLable .textColor = [UIColor whiteColor];
        self.textLable .textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textLable ];
                
    }
    return self;
}

@end
