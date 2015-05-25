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
        [newButton setImage:[UIImage imageNamed:normalBackgroundImageName] forState:UIControlStateNormal];
    }
    if (disableBackgroundImageName) {
        [newButton setImage:[UIImage imageNamed:disableBackgroundImageName] forState:UIControlStateDisabled];
    }
    [newButton addTarget:_delegate action:selector forControlEvents:UIControlEventTouchUpInside];
    [newButton setTag:tag];
    return newButton;
}

// 获取音量面板
- (UISlider *)getVolumeView {
    
    // 5. 音量slider
    _frame = CGRectMake(kScreenWidth-(kScreenHeight-kTopViewHeight-kStatusBarHeight-kButtomViewHeight-20)/2-20,(kScreenHeight - kStatusBarHeight -  kTopViewHeight - kButtomViewHeight)/2 + kStatusBarHeight + kTopViewHeight - 20,kScreenHeight-kTopViewHeight-kStatusBarHeight-kButtomViewHeight-20,40);
    _volumeView = [[UISlider alloc] initWithFrame:_frame];
    _volumeView.transform = CGAffineTransformMakeRotation(M_PI_2);
    [_volumeView addTarget:_delegate action:@selector(volumeSliderAction) forControlEvents:UIControlEventValueChanged | UIControlEventTouchUpInside];
    [_volumeView setHidden:YES];
    [_volumeView setTag:5];
    return _volumeView;
}

// 背景面板
- (UIView *)getBackGroundView {
    
    _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kScreenHeight)];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [backgroundImageView setClipsToBounds:YES];
    [backgroundImageView setTag:1];
    [_backGroundView addSubview:backgroundImageView];
    
    // 2. 中间部分（透明按钮）
    UIButton *middleviewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kTopViewHeight, kScreenWidth, kScreenHeight-kStatusBarHeight-kTopViewHeight-kButtomItemsGapWithScreen)];
    [middleviewButton addTarget:_delegate action:@selector(middleViewButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_backGroundView addSubview:middleviewButton];
    
    return _backGroundView;
}

// 头部面板
- (UIView *)getTopContentView {
    
    // 2. 上部分基视图
    _topContentView = [[UIView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kTopViewHeight)];
    [_topContentView setBackgroundColor:kBgColor];
    [_topContentView setTag:2];
    
    // 2.1 返回按钮
    _frame = CGRectMake(kTopItemsGapWithScreen, kTopViewHeight - kCollectBtnWidth/2 - kBackBtnWidth/2 - 5, kBackBtnWidth, kBackBtnWidth);
    UIButton *backButton = [self createButton:_frame
                    normalBackgroundImageName:@"top_back_white@2x"
                   disableBackgroundImageName:nil
                               delegateSelect:@selector(backButtonAction)
                                          tag:21];
    [_topContentView addSubview:backButton];
    
    // 2.2 歌名
    UILabel *songName = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2 - kSongNameWitdth/2, 20, kSongNameWitdth, 20)];
    [songName setTextAlignment:NSTextAlignmentCenter];
    [songName setTextColor:[UIColor whiteColor]];
    [songName setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:25.f]];
    [songName setTag:22];
    [songName setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [_topContentView addSubview:songName];
    
    // 2.3 歌手信息
    UILabel *singerName = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2 - kSingerNameWidth/2, 45, kSingerNameWidth, 20)];
    [singerName setTextAlignment:NSTextAlignmentCenter];
    [singerName setTextColor:[UIColor whiteColor]];
    [singerName setFont:[UIFont fontWithName:@"Arial Unicode MS" size:18.f]];
    [singerName setTag:23];
    [_topContentView addSubview:singerName];
    
    // 2.4 收藏按钮
    _frame = CGRectMake(kScreenWidth - kCollectBtnWidth - kTopItemsGapWithScreen, kTopViewHeight - kCollectBtnWidth - 5, kCollectBtnWidth, kCollectBtnWidth);
    UIButton *collectButton = [self createButton:_frame
                       normalBackgroundImageName:@"playing_btn_love_h@2x"
                      disableBackgroundImageName:nil
                                  delegateSelect:@selector(collectButtonAction)
                                             tag:24];
    [_topContentView addSubview:collectButton];
    return _topContentView;
}

// 尾部面板
- (UIView *)getButtomContentView {
    
    // 4. 下部分基视图
    _buttomContentView = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-kButtomViewHeight, kScreenWidth, kButtomViewHeight)];
    [_buttomContentView setBackgroundColor:kBgColor];
    [_buttomContentView setTag:4];
    
    // 4.1 进度条
    UISlider *songSlider = [[UISlider alloc] initWithFrame:CGRectMake(-10, 0, kScreenWidth+17, kSongSliderHeight)];
    [songSlider setMinimumTrackImage:[UIImage imageNamed:@"playing_slider_play_left@2x"] forState:UIControlStateNormal];
    [songSlider setMaximumTrackImage:[UIImage imageNamed:@"playing_slider_play_right@2x"] forState:UIControlStateNormal];
    [songSlider setThumbImage:[UIImage imageNamed:@"playing_slider_thumb@2x"] forState:UIControlStateNormal];
    [songSlider setTag:41];
    [songSlider addTarget:_delegate action:@selector(sliderValueChageAction) forControlEvents:UIControlEventValueChanged];
    [_buttomContentView addSubview:songSlider];
    
    // 4.2 进度条时间
    UILabel *sliderTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kButtomItemsGapWithScreen, kSongSliderHeight, kSongTimeWidth, 15)];
    [sliderTimeLabel setText:@"00:00"];
    [sliderTimeLabel setTextColor:[UIColor whiteColor]];
    [sliderTimeLabel setTag:42];
    [_buttomContentView addSubview:sliderTimeLabel];
    
    // 4.3 歌曲总时间
    UILabel *songTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth- kButtomItemsGapWithScreen-kSongTimeWidth, kSongSliderHeight, kSongTimeWidth, 15)];
    [songTimeLabel setText:@"00:00"];
    [songTimeLabel setTextColor:[UIColor whiteColor]];
    [songTimeLabel setTag:43];
    [_buttomContentView addSubview:songTimeLabel];
    
    // 4.4 上一首
    _frame = CGRectMake(kScreenWidth/2-kPauseBtnWidth/2-kNextLastBtnWidth-kSongBtnGap, kSongSliderHeight+5+kPauseBtnWidth/2-kNextLastBtnWidth/2, kNextLastBtnWidth, kNextLastBtnWidth);
    UIButton *lastSongButton = [self createButton:_frame
                        normalBackgroundImageName:@"playing_btn_pre_n@2x"
                       disableBackgroundImageName:@"playing_btn_pre_h@2x"
                                   delegateSelect:@selector(playBtnAction:)
                                              tag:44];
    [_buttomContentView addSubview:lastSongButton];
    
    // 4.5 暂停/开始
    _frame = CGRectMake(kScreenWidth/2 - kPauseBtnWidth/2,kSongSliderHeight+5,kPauseBtnWidth,kPauseBtnWidth);
    UIButton *pauseButton = [self createButton:_frame
                     normalBackgroundImageName:@"playing_btn_pause_n@2x"
                    disableBackgroundImageName:@"playing_btn_pause_h@2x"
                                delegateSelect:@selector(playBtnAction:)
                                           tag:45];
    [_buttomContentView addSubview:pauseButton];
    
    // 4.6 下一首
    _frame = CGRectMake(kScreenWidth/2+kPauseBtnWidth/2+kSongBtnGap, kSongSliderHeight+5+kPauseBtnWidth/2-kNextLastBtnWidth/2, kNextLastBtnWidth, kNextLastBtnWidth);
    UIButton *nextSongButton = [self createButton:_frame
                        normalBackgroundImageName:@"playing_btn_next_n@2x"
                       disableBackgroundImageName:@"playing_btn_next_h@2x"
                                   delegateSelect:@selector(playBtnAction:)
                                              tag:46];
    [_buttomContentView addSubview:nextSongButton];
    
    // 4.7 音量button
    _frame = CGRectMake(kScreenWidth-kButtomItemsGapWithScreen-kVolumeBtnWidth, kButtomViewHeight - kVolumeBtnWidth - kButtomItemsGapWithScreen, kVolumeBtnWidth, kVolumeBtnWidth);
    UIButton *volumeButton = [self createButton:_frame
                      normalBackgroundImageName:@"volume"
                     disableBackgroundImageName:nil
                                 delegateSelect:@selector(volumeButtonAction)
                                            tag:47];
    [_buttomContentView addSubview:volumeButton];
    
    // 4.8 播放模式
    _frame = CGRectMake(kButtomItemsGapWithScreen, kButtomViewHeight - kPlayModleBtnWidth - kButtomItemsGapWithScreen, kPlayModleBtnWidth, kPlayModleBtnWidth);
    UIButton *playModleButton = [self createButton:_frame
                         normalBackgroundImageName:@"Loop"
                        disableBackgroundImageName:nil
                                    delegateSelect:@selector(playModleAction)
                                               tag:48];
    [_buttomContentView addSubview:playModleButton];
    return _buttomContentView;
}
@end
