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

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _loadSubViews]; // 加载界面元素
    
    [self _loadData];     // 获取数据
    
    [self _init];    // 初始化（界面初始化 & 播放）
    
    // 添加一个定时器，使slider和音频同步
    [NSTimer scheduledTimerWithTimeInterval:1.f
                                     target:self
                                   selector:@selector(_synchronizeSliderAndMusic)
                                   userInfo:nil
                                    repeats:YES];    
}

#pragma mark - protocol Method

/* 中间部分透明按钮监听事件 */
- (void)middleViewButtonAction {
    
    // 隐藏(或显示) 上部分基视图 和 下部分基视图
    CGFloat topBaseViewOriginY = _topBaseView.frame.origin.y;
    float topViewMoveLenOfY = topBaseViewOriginY == kStatusBarHeight? -(kStatusBarHeight + kTopViewHeight) : kStatusBarHeight + kTopViewHeight;
    float buttomMoveLenOfY = topBaseViewOriginY == kStatusBarHeight? kButtomViewHeight : -kButtomViewHeight;
    [UIView animateWithDuration:1.0f animations:^{
        _topBaseView.transform = CGAffineTransformTranslate(_topBaseView.transform, 0, topViewMoveLenOfY);
        _buttomBaseView.transform = CGAffineTransformTranslate(_buttomBaseView.transform, 0, buttomMoveLenOfY);
    }];
    
    // 隐藏音量slider
    if (!_volumeSlider.hidden) {
        [_volumeSlider setHidden:YES];
    }
}

/* 返回按钮监听事件 */
- (void)backButtonAction {
    NSLog(@"返回");
}

/*  收藏按钮监听事件 */
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
        [self setCollectButton:_collectFlg];
    }
}

/* 播放按钮事件（上一首，暂停/播放，下一首）*/
- (void)playBtnAction:(UIButton *)sender {
 
    switch (sender.tag) {
            
        case 44: // 上一首
            
            [self playSongByIndex:--_currentDataIndex];
            break;
        case 45: // 暂停/播放
            
            [self pauseOrPlay];
            break;
        case 46: // 下一首
            
            [self playSongByIndex:++_currentDataIndex];
            break;
        default:
            break;
    }
}

/*  设置收藏按钮 */
- (void)setCollectButton:(BOOL)inMyFavor {
    if (inMyFavor) {
        
        // 已经收藏
        [_collectButton setImage:[UIImage imageNamed:@"playing_btn_in_myfavor@2x"] forState:UIControlStateNormal];
        [_collectButton setImage:[UIImage imageNamed:@"playing_btn_in_myfavor_h@2x"] forState:UIControlStateHighlighted];
    } else {
        
        // 未收藏
        [_collectButton setImage:[UIImage imageNamed:@"playing_btn_love@2x"] forState:UIControlStateNormal];
        [_collectButton setImage:[UIImage imageNamed:@"playing_btn_love_h@2x"] forState:UIControlStateHighlighted];
    }
}

/* slider拖动监听事件 */
- (void)sliderValueChageAction {
    
    // 获取slider当前值
    float sliderTimeNow = _songSlider.value;
    _avAudioPlayer.currentTime = sliderTimeNow;
}

/*  音量 */
- (void)volumeButtonAction {
    
    // 设置音量滑块的显示和隐藏
    [_volumeSlider setHidden:!_volumeSlider.hidden];
}

/*  音量滑块 */
- (void)volumeSliderAction {
    
    float volumeNow = 1.0f - _volumeSlider.value;
    _avAudioPlayer.volume = volumeNow;
    
    // 1.5s 后隐藏音量滑块
    [self performSelector:@selector(_hiddenVolumeSlider) withObject:nil afterDelay:1.5f];
}

/*  播放模式 */
- (void)playModleAction {
    
    int imageIndex = _playModleImageIndex++ % 3;
    [_playModleButton setImage:_playModleImageArray[imageIndex] forState:UIControlStateNormal];
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

/* 播放列表*/
- (void)songListAction {
    
    // 将播放列表右移隐藏
    CGPoint center = _musicList.center;
    
    // 判断是隐藏还是显示
    if (center.x > kScreenWidth) {
        center.x -= kScreenWidth - kGapOfMusicListAndLeftScreen;
    } else {
        center.x += kScreenWidth - kGapOfMusicListAndLeftScreen;
    }
    
    // 动画平移显示或隐藏
    [UIView animateWithDuration:1.0f animations:^{
        _musicList.center = center;
    }];
}

/* 设置播放列表行数*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataArray.count;
}

/* 设置播放列表cell*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *indentify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentify];
    }
    
    // 获取歌曲信息
    NSDictionary *songInfo = _dataArray[indexPath.row];
    NSString *singer = songInfo[@"singerName"];
    NSString *song = songInfo[@"songName"];
    
    // 设置图片
    NSString *singerPicName = [NSString stringWithFormat:@"%@.jpg",singer];
    cell.imageView.image = [UIImage imageNamed:singerPicName];
    
    // 设置label
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",singer,song];
    cell.backgroundColor = kMusicListColor;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    // 设置背景色
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.3];
    }
    
    // 设置cell样式
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

// 播放列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 播放音乐
    _currentDataIndex = indexPath.row;
    [self playSongByIndex:_currentDataIndex];
    
    // 过2s收起播放列表
    [self performSelector:@selector(songListAction) withObject:nil afterDelay:2.0f];
}


#pragma mark - private Method

/* 音乐信息取得 & 播放 */
- (void)playSongByIndex:(NSInteger )index {
    
    // 1.取出下一首歌的信息
    _playingSongData = _dataArray[index];
    NSString *singerName = [_playingSongData objectForKey:@"singerName"];
    NSString *songName = [_playingSongData objectForKey:@"songName"];
    _collectFlg = [[_playingSongData objectForKey:@"collect"] boolValue];
    
    // 2.设置收藏图片
    [self setCollectButton:_collectFlg];
    
    // 3.设置歌名和歌手名字
    [_singerName setText:singerName];
    [_songName setText:songName];
    
    // 4.更换背景图片
    [_backgroundImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",singerName]]];
    
    // 5.设置上一首和下一首按钮
    if (_currentDataIndex == 0) {
        [_lastSongButton setEnabled:NO];
    } else {
        [_lastSongButton setEnabled:YES];
    }
    
    if (_currentDataIndex == _dataArray.count - 1) {
        [_nextSongButton setEnabled:NO];
    } else {
        [_nextSongButton setEnabled:YES];
    }
    
    // 6.加载并播放相应的音乐
    if (!_pauseFlg) {
        [self _playMusic:songName];
    }
}

/*  加载界面视图 */
- (void)_loadSubViews {
    
    // 1. 加载根视图
    RootView *rootView = [[RootView alloc] init];
    rootView.delegate = (id<RootViewDelegate>)self;
    
    [self.view addSubview:[rootView getBackGroundView]]; // 加载背景面板
    [self.view addSubview:[rootView getTopContentView]]; // 加载头部面板
    [self.view addSubview:[rootView getButtomContentView]]; // 加载尾部面板
    [self.view addSubview:[rootView getVolumeView]]; // 加载音量面板
    
    _musicList = [rootView getMusicListView];
    [self.view addSubview:_musicList]; // 加载播放列表
    
    
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
}

/* 播放音频 */
- (void) _playMusic:(NSString *)nameOfSongFile {
    
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

/* 暂停/播放 */
- (void) pauseOrPlay {
    
    _pauseFlg = !_pauseFlg;
    if (_pauseFlg) {
        
        // 暂停
        [_pauseButton setImage:[UIImage imageNamed:@"playing_btn_play_n@2x"]
                      forState:UIControlStateNormal];
        [_pauseButton setImage:[UIImage imageNamed:@"playing_btn_play_h@2x"]
                      forState:UIControlStateHighlighted];
        [_avAudioPlayer pause];
    } else {
        
        // 播放
        [_pauseButton setImage:[UIImage imageNamed:@"playing_btn_pause_n@2x"]
                      forState:UIControlStateNormal];
        [_pauseButton setImage:[UIImage imageNamed:@"playing_btn_pause_h@2x"]
                      forState:UIControlStateHighlighted];
        [_avAudioPlayer play];
    }
}

/* 同步slider和音频 */
- (void)_synchronizeSliderAndMusic {
    
    // 获取当前音频时间
    float musicTimeNow = _avAudioPlayer.currentTime;
    float sliderPointNow = _songSlider.maximumValue * musicTimeNow / _avAudioPlayer.duration;
    [_songSlider setValue:sliderPointNow animated:YES];
    
    // 设置slider现在的时间
    NSInteger sliderTime = musicTimeNow;
    NSString *musicTime = [NSString stringWithFormat:@"%02d:%02d",sliderTime/60,sliderTime % 60];
    [_sliderTimeLabel setText:musicTime];
    
}

/* 隐藏音量slider */
- (void)_hiddenVolumeSlider {
    
    [_volumeSlider setHidden:YES];
}

/*  获取数据 */
- (void)_loadData {
    
    // 读取plist文件（Music.plist）
    _plistPath = [[NSBundle mainBundle] pathForResource:@"Music" ofType:@"plist"];
    _dataArray = [[NSMutableArray alloc] initWithContentsOfFile:_plistPath];
}

/* 界面初始化 */
- (void)_init {
    
    // 1. 设置初始页面
    _playingSongData = _dataArray[0];
    NSString *singerName = [_playingSongData objectForKey:@"singerName"];  // 歌手名字
    NSString *songName = [_playingSongData objectForKey:@"songName"];      // 歌名
    _currentDataIndex = 0;
    
    // 1.1 获取歌手图片，作为背景图片
    UIImage *backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",singerName]];
    [_backgroundImageView setImage:backgroundImage];
    
    // 1.2 设置歌手名字 和 歌名
    [_singerName setText:singerName];
    [_songName setText:songName];
    
    
    // 2. 设置上一首按钮（第一首歌无效）
    [_lastSongButton setEnabled:NO];
    
    // 3. 设置下一首按钮
    if (_currentDataIndex == _dataArray.count - 1) {
        
        // 如果只有一首歌曲，下一首按钮不可用
        [_nextSongButton setEnabled:NO];
    }
    
    // 4. 收藏按钮
    _collectFlg = [[_playingSongData objectForKey:@"collect"] boolValue];
    [self setCollectButton:_collectFlg];
    
    // 5. 加载播放模式图片
    _playModleImageArray = @[[UIImage imageNamed:@"Loop"],
                             [UIImage imageNamed:@"selfLoop"],
                             [UIImage imageNamed:@"random"]];
    _playModleImageIndex = 1;
    
    // 6. 播放
    [self _playMusic:songName];
}



#pragma mark - system protocol Method

/* 音频播放完成时 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    // 音乐进度滑块清零
    [_songSlider setValue:0.0f];
    
    if (_playModle) {
        
        // 随即播放
        if (_currentDataIndex == _dataArray.count -1) {
            
            _currentDataIndex --;
            [self playSongByIndex:++_currentDataIndex];
            [self pauseOrPlay];
        } else {
            [self playSongByIndex:++_currentDataIndex];
        }
    } else {
        
        // 循环播放
        if (_currentDataIndex == _dataArray.count - 1) {
            
            _currentDataIndex = -1;
            [_lastSongButton setEnabled:NO];
            [_nextSongButton setEnabled:YES];
        }
        [self playSongByIndex:++_currentDataIndex];
    }
}

/* 收藏按钮UIAlertView监听事件 */
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
@end
