//
//  RootView.h
//  项目-QQ控制器
//
//  Created by archer on 15-5-22.
//  Copyright (c) 2015年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RootViewDelegate <NSObject>


- (void)middleViewButtonAction; // 中间部分透明按钮
- (void)backButtonAction;       // 返回
- (void)collectButtonAction;    // 收藏
- (void)lastSongButtonAction;   // 上一首
- (void)pauseButtonAction;      // 暂停/开始
- (void)nextSongButtonAction;   // 下一首
- (void)sliderValueChageAction; //slider拖动监听
- (void)volumeButtonAction;     // 音量按钮
- (void)volumeSliderAction;     // 音量滑块
- (void)hiddenVolumeSlider;     // 音量滑块隐藏
- (void)playModleAction;        // 播放模式
@end

@interface RootView : UIView

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, weak) id<RootViewDelegate> delegate;

// 设置页面
- (UIView *)getView;
@end
