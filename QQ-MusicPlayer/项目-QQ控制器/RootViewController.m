//
//  RootViewController.m
//  项目-QQ控制器
//
//  Created by archer on 15-5-22.
//  Copyright (c) 2015年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import "RootViewController.h"
#import "MarcroHeader.h"
#import "RootView.h"

@interface RootViewController () {
    
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

@implementation RootViewController

#pragma mark - 加载主视图
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 加载根视图
    RootView *rootView = [[RootView alloc] init];
    rootView.delegate = self;
    self.view = [rootView getView];
    
    // 2. 获取根视图上的控件
    _backgroundImageView = (UIImageView *)[self.view viewWithTag:1];  // tag:1 背景图片
    _topBaseView         = [self.view viewWithTag:2];                 // tag:2 上部分基视图
    _backButton          = (UIButton *)[self.view viewWithTag:21]; // tag:21 返回按钮
    _songName            = (UILabel *)[self.view viewWithTag:22];  // tag:22 歌名
    _singerName          = (UILabel *)[self.view viewWithTag:23];  // tag:23 歌手信息
    _collectButton       = (UIButton *)[self.view viewWithTag:24]; // tag:24 收藏按钮
    _buttomBaseView      = [self.view viewWithTag:4];              // tag:4  下部分基视图
    _songSlider          = (UISlider *)[self.view viewWithTag:41]; // tag:41 进度条
    _sliderTimeLabel     = (UILabel *)[self.view viewWithTag:42];  // tag:42 进度条时间
    _songTimeLabel       = (UILabel *)[self.view viewWithTag:43];  // tag:43 歌曲总时间
    _lastSongButton      = (UIButton *)[self.view viewWithTag:44]; // tag:44 上一首
    _pauseButton         = (UIButton *)[self.view viewWithTag:45]; // tag:45 暂停/开始
    _nextSongButton      = (UIButton *)[self.view viewWithTag:46]; // tag:46 下一首
    _playModleButton     = (UIButton *)[self.view viewWithTag:48]; // tag:48 播放模式
    _volumeSlider        = (UISlider *)[self.view viewWithTag:5];  // tag:5 音量滑块
    
    // 3. 读取plist文件（Music.plist）
    _plistPath = [[NSBundle mainBundle] pathForResource:@"Music" ofType:@"plist"];
    //    _dataArray = [[NSMutableArray arrayWithContentsOfFile:plistPath] mutableCopy];
    _dataArray = [[NSMutableArray alloc] initWithContentsOfFile:_plistPath];
    
    // 4. 设置初始页面
    _playingSongData = _dataArray[0];
    NSString *singerName = [_playingSongData objectForKey:@"singerName"];  // 歌手名字
    NSString *songName = [_playingSongData objectForKey:@"songName"];      // 歌名
    _currentDataIndex = 0;
    
    // 4.1 获取歌手图片，作为背景图片
    UIImage *backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",singerName]];
    [_backgroundImageView setImage:backgroundImage];
    
    // 4.2 设置歌手名字 和 歌名
    [_singerName setText:singerName];
    [_songName setText:songName];
    
    
    // 5. 设置上一首按钮（第一首歌无效）
    [_lastSongButton setEnabled:NO];
    
    // 6. 设置下一首按钮
    if (_currentDataIndex == _dataArray.count - 1) {
        
        [_nextSongButton setEnabled:NO]; // 如果只有一首歌曲，下一首按钮不可用
    }
    
    // 7. 设置开始/暂停按钮
    //    _pauseFlg = NO;
    //    [_pauseButton setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_n@2x"] forState:UIControlStateNormal];
    //    [_pauseButton setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_h@2x"] forState:UIControlStateHighlighted];
    
    // 8. 收藏按钮
    _collectFlg = [[_playingSongData objectForKey:@"collect"] boolValue];
    [self setCollectButton:_collectFlg];
    
    // 9 加载并播放对应的音乐文件
    [self playMusic:songName];
    
    // 10 添加一个定时器，使slider和音频时长同步
    [NSTimer scheduledTimerWithTimeInterval:1.f
                                     target:self
                                   selector:@selector(synchronizeSliderAndMusic)
                                   userInfo:nil
                                    repeats:YES];
    
    // 11. 加载播放模式图片
    _playModleImageArray = @[[UIImage imageNamed:@"Loop"],
                             [UIImage imageNamed:@"selfLoop"],
                             [UIImage imageNamed:@"random"]];
    _playModleImageIndex = 1;
}

#pragma mark - 协议方法
#pragma mark 中间部分透明按钮监听事件
- (void)middleViewButtonAction {
    
    // 隐藏(或显示) 上部分基视图 和 下部分基视图
    CGFloat topBaseViewOriginY = _topBaseView.frame.origin.y;
    [UIView animateWithDuration:1.0f animations:^{
        _topBaseView.transform = CGAffineTransformTranslate(_topBaseView.transform, 0, topBaseViewOriginY? 100 : -100);
        _buttomBaseView.transform = CGAffineTransformTranslate(_buttomBaseView.transform, 0, topBaseViewOriginY? -170 : 170);
    }];
    
    // 隐藏音量slider
    if (!_volumeSlider.hidden) {
        [_volumeSlider setHidden:YES];
    }
}

#pragma mark 返回按钮监听事件
- (void)backButtonAction {
    NSLog(@"返回");
}

#pragma mark 收藏按钮监听事件
#warning mark Plist文件中的收藏标志未修改
- (void)collectButtonAction {
    
    // 取消收藏时，弹出窗口让用户确认
    if (_collectFlg) {
        
        // UIAlertView 初始化
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除"
                                                            message:@"确定将选中的歌曲从我喜欢的歌单删除?"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"删除", nil];
        [alertView show];
    } else {
        
        // 收藏
        _collectFlg = !_collectFlg;
        
        [_playingSongData setValue:@(_collectFlg) forKey:@"collect"];
        [_dataArray replaceObjectAtIndex:_currentDataIndex withObject:_playingSongData];
        
        [self setCollectButton:_collectFlg];
    }
}

#pragma mark 上一首
- (void)lastSongButtonAction {
    
    _currentDataIndex--;
    // 设置下一首按钮
    [_nextSongButton setEnabled:YES];
    
    // 取出下一首歌的信息
    _playingSongData = _dataArray[_currentDataIndex];
    NSString *singerName = [_playingSongData objectForKey:@"singerName"];
    NSString *songName = [_playingSongData objectForKey:@"songName"];
    _collectFlg = [[_playingSongData objectForKey:@"collect"] boolValue];
    
    // 设置收藏图片
    [self setCollectButton:_collectFlg];
    
    // 设置歌名和歌手名字
    [_singerName setText:singerName];
    [_songName setText:songName];
    
    // 更换背景图片
    [_backgroundImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",singerName]]];
    
    // 加载并播放相应的音乐
    if (!_pauseFlg) {
        [self playMusic:songName];
    }
    
    // 判断还有没有下一首歌
    if (_currentDataIndex == 0) {
        [_lastSongButton setEnabled:NO];
    }
}

#pragma mark 暂停/开始
- (void)pauseButtonAction {
    
    _pauseFlg = !_pauseFlg;
    if (_pauseFlg) {
        
        // 暂停
        [_pauseButton setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_n@2x"] forState:UIControlStateNormal];
        [_pauseButton setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_h@2x"] forState:UIControlStateHighlighted];
        [_avAudioPlayer pause];
    } else {
        
        // 播放
        [_pauseButton setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_n@2x"] forState:UIControlStateNormal];
        [_pauseButton setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_h@2x"] forState:UIControlStateHighlighted];
        [_avAudioPlayer play];
    }
}

#pragma mark 下一首
- (void)nextSongButtonAction {
    
    _currentDataIndex++;
    
    // 设置上一首按钮
    if (_currentDataIndex != 0) {
        [_lastSongButton setEnabled:YES];
    }
    
    // 取出下一首歌的信息
    _playingSongData = _dataArray[_currentDataIndex];
    NSString *singerName = [_playingSongData objectForKey:@"singerName"];
    NSString *songName = [_playingSongData objectForKey:@"songName"];
    _collectFlg = [[_playingSongData objectForKey:@"collect"] boolValue];
    
    // 设置收藏图片
    [self setCollectButton:_collectFlg];
    
    // 设置歌名和歌手名字
    [_singerName setText:singerName];
    [_songName setText:songName];
    
    // 更换背景图片
    [_backgroundImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",singerName]]];
    
    // 加载并播放相应的音乐
    if (!_pauseFlg) {
        [self playMusic:songName];
    }
    
    // 判断还有没有下一首歌
    if (_currentDataIndex == _dataArray.count - 1) {
        [_nextSongButton setEnabled:NO];
    }
}

#pragma mark 设置收藏按钮
- (void)setCollectButton:(BOOL)inMyFavor {
    if (inMyFavor) {
        
        // 已经收藏
        [_collectButton setBackgroundImage:[UIImage imageNamed:@"playing_btn_in_myfavor@2x"] forState:UIControlStateNormal];
        [_collectButton setBackgroundImage:[UIImage imageNamed:@"playing_btn_in_myfavor_h@2x"] forState:UIControlStateHighlighted];
    } else {
        
        // 未收藏
        [_collectButton setBackgroundImage:[UIImage imageNamed:@"playing_btn_love@2x"] forState:UIControlStateNormal];
        [_collectButton setBackgroundImage:[UIImage imageNamed:@"playing_btn_love_h@2x"] forState:UIControlStateHighlighted];
    }
}

#pragma mark slider拖动监听事件
- (void)sliderValueChageAction {
    
    // 获取slider当前值
    float sliderTimeNow = _songSlider.value;
    _avAudioPlayer.currentTime = sliderTimeNow;
}

#pragma mark 音量
- (void)volumeButtonAction {
    
    BOOL flg = _volumeSlider.hidden;
    // 设置音量滑块的显示和隐藏
    [_volumeSlider setHidden:!_volumeSlider.hidden];
}

#pragma mark 音量滑块
- (void)volumeSliderAction {
    
    float volumeNow = 1.0f - _volumeSlider.value;
    _avAudioPlayer.volume = volumeNow;
    
    // 1.5s 后隐藏音量滑块
    [self performSelector:@selector(hiddenVolumeSlider) withObject:nil afterDelay:1.5f];
}

#pragma mark  播放模式
- (void)playModleAction {
    
    int imageIndex = _playModleImageIndex++ % 3;
    [_playModleButton setBackgroundImage:_playModleImageArray[imageIndex] forState:UIControlStateNormal];
    switch (imageIndex) {
        case 0:  // 循环播放
            _avAudioPlayer.numberOfLoops = 0;
            _playModle = NO;
            break;
        case 1:  // 单曲循环
            _avAudioPlayer.numberOfLoops = -1;
            break;
        case 2:  // 随即播放
            _avAudioPlayer.numberOfLoops = 0;
            _playModle = YES;
            break;
        default:
            break;
    }
}



#pragma mark - 私有方法
#pragma mark 播放音频
- (void) playMusic:(NSString *)nameOfSongFile {
    
    // 指定音频文件
    NSString *musicFilePath = [[NSBundle mainBundle] pathForResource:nameOfSongFile ofType:@"mp3"];
    
    // 将音频路径转换为URL
    NSURL *musicFileUrl = [NSURL fileURLWithPath:musicFilePath];
    
    // 加载音频文件
    _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFileUrl error:nil];
    [_avAudioPlayer prepareToPlay];
    
    // 设置代理
    [_avAudioPlayer setDelegate:self];
    
    // 未暂停时播放
    if (!_pauseFlg) {
        [_avAudioPlayer play];
    }
    
    // 设置音乐总时长
    NSInteger timeOfMusic = _avAudioPlayer.duration;
    NSString *musicTime = [NSString stringWithFormat:@"%02ld:%02ld",timeOfMusic/60,timeOfMusic%60];
    [_songTimeLabel setText:musicTime];
    
    // 设置slider
    [_songSlider setMaximumValue:_avAudioPlayer.duration];
}

#pragma mark 同步slider和音频
- (void)synchronizeSliderAndMusic {
    
    // 获取当前音频时间
    float musicTimeNow = _avAudioPlayer.currentTime;
    float sliderPointNow = _songSlider.maximumValue * musicTimeNow / _avAudioPlayer.duration;
    [_songSlider setValue:sliderPointNow animated:YES];
    
    // 设置slider现在的时间
    NSInteger sliderTime = musicTimeNow;
    NSString *musicTime = [NSString stringWithFormat:@"%02ld:%02ld",sliderTime/60,sliderTime % 60];
    [_sliderTimeLabel setText:musicTime];
    
}

#pragma mark 音频播放完成时
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (_playModle) {
        
        // 随即播放
        if (_currentDataIndex == _dataArray.count -1) {
            _currentDataIndex --;
            [self nextSongButtonAction];
            [self pauseButtonAction];
        } else {
            [self nextSongButtonAction];
        }
    } else {
        
        // 循环播放
        if (_currentDataIndex == _dataArray.count - 1) {
            _currentDataIndex = -1;
            [_lastSongButton setEnabled:NO];
            [_nextSongButton setEnabled:YES];
        }
        [self nextSongButtonAction];
    }
}

#pragma mark 收藏按钮UIAlertView监听事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (buttonIndex) {
        case 1:
            _collectFlg = !_collectFlg;
            
            [_playingSongData setValue:@(_collectFlg) forKey:@"collect"];
            [_dataArray replaceObjectAtIndex:_currentDataIndex withObject:_playingSongData];
            
            [self setCollectButton:_collectFlg];
            break;
        default:
            break;
    }
}

#pragma mark 隐藏音量slider
- (void)hiddenVolumeSlider {
    
    [_volumeSlider setHidden:YES];
}

#pragma mark 设置状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
