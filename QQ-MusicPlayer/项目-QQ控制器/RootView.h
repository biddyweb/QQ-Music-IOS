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
- (void)playBtnAction:(UIButton *)sender;          // 播放按钮
- (void)sliderValueChageAction; //slider拖动监听
- (void)volumeButtonAction;     // 音量按钮
- (void)volumeSliderAction;     // 音量滑块
- (void)hiddenVolumeSlider;     // 音量滑块隐藏
- (void)playModleAction;        // 播放模式
- (void)songListAction;         // 播放列表
@end

@interface RootView : UIView

@property (nonatomic, weak) id<RootViewDelegate> delegate;  // 代理
@property (nonatomic, strong) UIView *backGroundView; // 背景面板
@property (nonatomic, strong) UIView *topContentView; // 头部面板
@property (nonatomic, strong) UIView *buttomContentView; // 尾部面板
@property (nonatomic, strong) UISlider *volumeView; // 音量面板
@property (nonatomic, strong) UITableView *musicListView; // 播放列表
@property (nonatomic) CGRect frame;

- (UIView *)getBackGroundView; // 获取背景面板
- (UIView *)getTopContentView; // 获取头部面板
- (UIView *)getButtomContentView; // 获取尾部面板
- (UISlider *)getVolumeView; // 获取音量面板
- (UITableView *)getMusicListView; // 播放列表
@end
