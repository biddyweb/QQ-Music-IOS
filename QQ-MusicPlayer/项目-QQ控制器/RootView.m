//
//  RootView.m
//  项目-QQ控制器
//
//  Created by archer on 15-5-22.
//  Copyright (c) 2015年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import "RootView.h"
#import "MarcroHeader.h"

@implementation RootView

// 创建按钮
- (UIButton *)createButton:(CGRect)frame
 normalBackgroundImageName:(NSString *)normalBackgroundImageName
disableBackgroundImageName:(NSString *)disableBackgroundImageName
            delegateSelect:(SEL)selector
                       tag:(int)tag{
    
    UIButton *newButton = [[UIButton alloc] initWithFrame:frame];
    if (normalBackgroundImageName) {
        [newButton setBackgroundImage:[UIImage imageNamed:normalBackgroundImageName] forState:UIControlStateNormal];
    }
    if (disableBackgroundImageName) {
        [newButton setBackgroundImage:[UIImage imageNamed:disableBackgroundImageName] forState:UIControlStateDisabled];
    }
    [newButton addTarget:_delegate action:selector forControlEvents:UIControlEventTouchUpInside];
    [newButton setTag:tag];
    return newButton;
}

// 设置页面
- (UIView *)getView {
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    CGRect frame;
    
    // --------------------创建view------------------------
    // 1. 背景图片
    UIImage *backgroundImage = [UIImage imageNamed:@"joy.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [backgroundImageView setImage:backgroundImage];
    [backgroundImageView setTag:1];
    [_mainView addSubview:backgroundImageView];
    
    // 2. 上部分基视图
    UIView *topBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    [topBaseView setBackgroundColor:[UIColor blackColor]];
    [topBaseView setAlpha:0.8];
    [topBaseView setTag:2];
    [_mainView addSubview:topBaseView];
    
    // 2.1 返回按钮
    frame = CGRectMake(10, 40, 44, 44);
    UIButton *backButton = [self createButton:frame
                       normalBackgroundImageName:@"top_back_white@2x"
                      disableBackgroundImageName:nil
                                  delegateSelect:@selector(backButtonAction)
                                             tag:21];
    [topBaseView addSubview:backButton];
    
    // 2.2 歌名
    UILabel *songName = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2 - 100, 20, 200, 20)];
    [songName setTextAlignment:NSTextAlignmentCenter];
    [songName setTextColor:[UIColor whiteColor]];
    [songName setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:25.f]];
    [songName setTag:22];
    [songName setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [topBaseView addSubview:songName];
    
    // 2.3 歌手信息
    UILabel *singerName = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2 - 50, 45, 100, 20)];
    [singerName setTextAlignment:NSTextAlignmentCenter];
    [singerName setTextColor:[UIColor whiteColor]];
    [singerName setFont:[UIFont fontWithName:@"Arial Unicode MS" size:18.f]];
    [singerName setTag:23];
    [topBaseView addSubview:singerName];
    
    // 2.4 收藏按钮
    frame = CGRectMake(kScreenWidth-80, 30, 80, 80);
    UIButton *collectButton = [self createButton:frame
                        normalBackgroundImageName:@"playing_btn_love_h@2x"
                       disableBackgroundImageName:nil
                                   delegateSelect:@selector(collectButtonAction)
                                              tag:24];
    [topBaseView addSubview:collectButton];
    
    // 3. 中间部分（透明按钮）
    UIButton *middleviewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, kScreenWidth, kScreenHeight-270)];
    [middleviewButton addTarget:_delegate action:@selector(middleViewButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_mainView addSubview:middleviewButton];
    
    // 4. 下部分基视图
    UIView *buttomBaseView = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-170, kScreenWidth, 170)];
    [buttomBaseView setBackgroundColor:[UIColor blackColor]];
    [buttomBaseView setAlpha:0.8];
    [buttomBaseView setTag:4];
    [_mainView addSubview:buttomBaseView];
    
    // 4.1 进度条
    UISlider *songSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    [songSlider setMinimumTrackImage:[UIImage imageNamed:@"playing_slider_play_left@2x"] forState:UIControlStateNormal];
    [songSlider setMaximumTrackImage:[UIImage imageNamed:@"playing_slider_play_right@2x"] forState:UIControlStateNormal];
    [songSlider setThumbImage:[UIImage imageNamed:@"playing_slider_thumb@2x"] forState:UIControlStateNormal];
    [songSlider setTag:41];
    [songSlider addTarget:_delegate action:@selector(sliderValueChageAction) forControlEvents:UIControlEventValueChanged];
    [buttomBaseView addSubview:songSlider];
    
    // 4.2 进度条时间
    UILabel *sliderTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 16, 50, 20)];
    [sliderTimeLabel setText:@"00:00"];
    [sliderTimeLabel setTextColor:[UIColor whiteColor]];
    [sliderTimeLabel setTag:42];
    [buttomBaseView addSubview:sliderTimeLabel];
    
    // 4.3 歌曲总时间
    UILabel *songTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-53, 16, 50, 20)];
    [songTimeLabel setText:@"00:00"];
    [songTimeLabel setTextColor:[UIColor whiteColor]];
    [songTimeLabel setTag:43];
    [buttomBaseView addSubview:songTimeLabel];
    
    // 4.4 上一首
    frame = CGRectMake((kScreenWidth - 200) / 4, 50, 50, 50);
    UIButton *lastSongButton = [self createButton:frame
                        normalBackgroundImageName:@"playing_btn_pre_n@2x"
                       disableBackgroundImageName:@"playing_btn_pre_h@2x"
                                   delegateSelect:@selector(lastSongButtonAction)
                                              tag:44];
    [buttomBaseView addSubview:lastSongButton];
    
    // 4.5 暂停/开始
    frame = CGRectMake(2 * (kScreenWidth - 200) / 4 + 50, 35, 100, 100);
    UIButton *pauseButton = [self createButton:frame
                     normalBackgroundImageName:@"playing_btn_pause_n@2x"
                    disableBackgroundImageName:@"playing_btn_pause_h@2x"
                                delegateSelect:@selector(pauseButtonAction)
                                           tag:45];
    [buttomBaseView addSubview:pauseButton];
    
    // 4.6 下一首
    frame = CGRectMake(3 * (kScreenWidth - 200) / 4 + 150, 50, 50, 50);
    UIButton *nextSongButton = [self createButton:frame
                        normalBackgroundImageName:@"playing_btn_next_n@2x"
                       disableBackgroundImageName:@"playing_btn_next_h@2x"
                                   delegateSelect:@selector(nextSongButtonAction)
                                              tag:46];
    [buttomBaseView addSubview:nextSongButton];
    
    // 4.7 音量button
    frame = CGRectMake(kScreenWidth-40, 120, 30, 30);
    UIButton *volumeButton = [self createButton:frame
                      normalBackgroundImageName:@"volume"
                     disableBackgroundImageName:nil
                                 delegateSelect:@selector(volumeButtonAction)
                                            tag:47];
    [buttomBaseView addSubview:volumeButton];
    
    // 4.8 播放模式
    frame = CGRectMake(20, 120, 24, 24);
    UIButton *playModleButton = [self createButton:frame
                         normalBackgroundImageName:@"Loop"
                        disableBackgroundImageName:nil
                                    delegateSelect:@selector(playModleAction)
                                               tag:48];
    [buttomBaseView addSubview:playModleButton];
    
    
    // 5. 音量slider
    frame = CGRectMake(kScreenWidth - (kScreenHeight - 300) + 100, (kScreenHeight-270)/2 + 80, kScreenHeight - 300, 30);
    UISlider *volumeSlider = [[UISlider alloc] initWithFrame:frame];
    volumeSlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    [volumeSlider addTarget:_delegate action:@selector(volumeSliderAction) forControlEvents:UIControlEventValueChanged | UIControlEventTouchUpInside];
    [volumeSlider setHidden:YES];
    [volumeSlider setTag:5];
    [_mainView addSubview:volumeSlider];
    // --------------------创建view------------------------
    
    return  _mainView;
}
@end
