//
//  RootViewController.h
//  项目-QQ控制器
//
//  Created by archer on 15-5-22.
//  Copyright (c) 2015年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RootViewController : UIViewController <AVAudioPlayerDelegate , UIAlertViewDelegate> {
    
    UIImageView *_backgroundImageView;  // tag:1 背景图片
    UIView *_topBaseView;               // tag:2 上部分基视图
    UIButton *_backButton;              // tag:21 返回按钮
    UILabel *_songName;                 // tag:22 歌名
    UILabel *_singerName;               // tag:23 歌手信息
    UIButton *_collectButton;           // tag:24 收藏按钮
    UIView *_buttomBaseView;            // tag:4  下部分基视图
    UISlider *_songSlider;              // tag:41 进度条
    UILabel *_sliderTimeLabel;          // tag:42 进度条时间
    UILabel *_songTimeLabel;            // tag:43 歌曲总时间
    UIButton *_lastSongButton;          // tag:44 上一首
    UIButton *_pauseButton;             // tag:45 暂停/开始
    UIButton *_nextSongButton;          // tag:46 下一首
    UIButton *_playModleButton;         // tag:48 播放模式
    UISlider *_volumeSlider;            // tag:5 音量滑块
    
    NSString *_plistPath;                // Plist文件路径
    NSMutableArray  *_dataArray;         // Plist 数组
    NSInteger _currentDataIndex;        // 当前播放的音乐在pilist数组中的索引
    BOOL       _pauseFlg;                // 开始/暂停按钮状态
    BOOL       _collectFlg;              // 收藏状态
    NSDictionary *_playingSongData;      // 正在播放的歌曲信息
    
    NSArray     *_playModleImageArray;   // 播放模式图片
    int         _playModleImageIndex;    // 遍历播放模式索引
    BOOL        _playModle;              // 播放模式：no(循环播放) yes(随即播放)
    
    AVAudioPlayer *_avAudioPlayer;       // 播放器
}

@end
