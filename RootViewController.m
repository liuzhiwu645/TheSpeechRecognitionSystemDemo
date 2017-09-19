//
//  RootViewController.m
//  SpeekSearch
//
//  Created by pc37 on 2017/9/15.
//  Copyright © 2017年 AME. All rights reserved.
//

#import "RootViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Speech/Speech.h>



#define LzwScreen_width [UIScreen mainScreen].bounds.size.width
#define LxwScreen_height [UIScreen mainScreen].bounds.size.height

@interface RootViewController ()
<AVSpeechSynthesizerDelegate, //AVSpeechSynthesizer代理
SFSpeechRecognizerDelegate
>

@property (nonatomic, strong) UILabel *labelResult;
@property (nonatomic, strong) UILabel *labelContent;
//声明AVSpeechSynthesizer属性
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@property (nonatomic,strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic,strong) AVAudioEngine *audioEngine;
@property (nonatomic,strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic,strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;

@property (nonatomic, strong) UIButton *buttonSpeakResult;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"系统语音";
    
    //创建一个AVSpeechSynthesizer对象
    self.synthesizer = [[AVSpeechSynthesizer alloc]init];
    //设置代理人为当前控制器对象
    self.synthesizer.delegate = self;
    
    [self creatRootUI];
}
#pragma mark -- 创建一个AVSpeechSynthesizer对象
- (void)creatSpeechSynthesizer:(NSString *)string
{
    
    //创建AVSpeechUtterance对象(播放的语音内容都是通过实例化AVSpeechUtterance而得到)
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:string];
    
    // 语速 0.0f～1.0f
    utterance.rate = 0.5f;
    // 声音的音调 0.5f～2.0f
    utterance.pitchMultiplier = 0.8f;
    // 使播放下一句的时候有0.1秒的延迟
    utterance.postUtteranceDelay = 0.1f;
    
    //系统默认是不支持中文的(下面是设置中文)
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//国家语言
    //播放
    [_synthesizer speakUtterance:utterance];
}
//AVSpeechSynthesizer的代理方法
-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    
    NSLog(@"开始播放");
}
-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
    
    NSLog(@"暂停播放");
}
-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"结束播放");
}
-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"退出播放状态");
}
-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"跳出播放状态");
}
-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance{
    NSLog(@"播放状态时，当前所播放的字符串范围，及AVSpeechUtterance实例（可通过此方法监听当前播放的字或者词");
}

#pragma mark -- 创建UI
- (void)creatRootUI
{
    self.labelResult = [[UILabel alloc]initWithFrame:CGRectMake(10, 90, LzwScreen_width - 20, 20)];
    _labelResult.textColor = [UIColor darkGrayColor];
    _labelResult.font = [UIFont systemFontOfSize:13.0];
    _labelResult.textAlignment = NSTextAlignmentCenter;
    _labelResult.text = @"语音识别结果:";
    [self.view addSubview:_labelResult];
    
    self.labelContent = [[UILabel alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(_labelResult.frame) + 20, LzwScreen_width - 80, 150)];
    _labelContent.text = @"人生若只如初见,何事秋风悲画扇。去年今日此门中,人面桃花相映红。 人面不知何处去,桃花依旧笑春风。纤云弄巧，飞星传恨，银汉迢迢暗渡。金风玉露一相逢，便胜却人间无数。柔情似水，佳期如梦，忍顾鹊桥归路。两情若是久长时，又岂在朝朝暮暮,山无棱，天地合，冬雷阵阵，夏雨雪，乃敢与君绝。只愿君心似我心，定不负相思意,愿得一心人，白首不相离。";
    _labelContent.numberOfLines = 0;
    _labelContent.textColor = [UIColor darkGrayColor];
    _labelContent.font = [UIFont systemFontOfSize:13.0];
    _labelContent.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_labelContent];
    
    UIButton *buttonRead = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonRead.frame = CGRectMake(30, LxwScreen_height - 50, LzwScreen_width - 60, 30);
    buttonRead.backgroundColor = [UIColor yellowColor];
    [buttonRead setTitle:@"朗读文字" forState:UIControlStateNormal];
    buttonRead.tag = 20170915;
    [buttonRead setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:buttonRead];
    [buttonRead addTarget:self action:@selector(buttonReadAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonSpeakResult = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonSpeakResult.frame = CGRectMake(30, LxwScreen_height - 90, LzwScreen_width - 60, 30);
    buttonSpeakResult.backgroundColor = [UIColor yellowColor];
    [buttonSpeakResult setTitle:@"开始录音" forState:UIControlStateNormal];
    buttonSpeakResult.tag = 20170916;
    [buttonSpeakResult setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.view addSubview:buttonSpeakResult];
    [buttonSpeakResult addTarget:self action:@selector(buttonSpeakResultAction:) forControlEvents:UIControlEventTouchUpInside];
    self.buttonSpeakResult = buttonSpeakResult;
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(buttonSpeakResultAction:)];
//    [buttonSpeakResult addGestureRecognizer:longPress];
    
    UIButton *buttonPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonPlay.frame = CGRectMake(30, LxwScreen_height - 130, LzwScreen_width - 60, 30);
    buttonPlay.backgroundColor = [UIColor blueColor];
    [buttonPlay setTitle:@"播放本地" forState:UIControlStateNormal];
    buttonPlay.tag = 20170917;
    [self.view addSubview:buttonPlay];
    [buttonPlay addTarget:self action:@selector(buttonPlayAction:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark -- 朗读文字按钮点击事件
- (void)buttonReadAction:(UIButton *)button
{
    [self creatSpeechSynthesizer:_labelContent.text];
}
#pragma mark -- 将语音转化成文字
- (void)buttonSpeakResultAction:(UIButton *)longPress
{
      /*
    if (longPress.state == UIGestureRecognizerStateEnded) {
        //长按中
        NSLog(@"123123");
        
        [self.audioEngine stop];
        if (_recognitionRequest) {
            [_recognitionRequest endAudio];
        }
    }
    else if (longPress.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"456456");
        [self startRecording];
    }
    else
    {
        NSLog(@"789789");
        
    }
    
  */
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
        if (_recognitionRequest) {
            [_recognitionRequest endAudio];
        }
        self.buttonSpeakResult.enabled = NO;
        [self.buttonSpeakResult setTitle:@"正在停止" forState:UIControlStateDisabled];
        
    }
    else{
        [self startRecording];
        [self.buttonSpeakResult setTitle:@"停止录音" forState:UIControlStateNormal];
    }
    
}
#pragma mark -- 播放本地音乐
- (void)buttonPlayAction:(UIButton *)button
{
    NSLocale *local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    SFSpeechRecognizer *localRecognizer =[[SFSpeechRecognizer alloc] initWithLocale:local];
    NSURL *url =[[NSBundle mainBundle] URLForResource:@"录音.m4a" withExtension:nil];
    
    if (!url) return;
    SFSpeechURLRecognitionRequest *res =[[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
    __weak typeof(self) weakSelf = self;
    [localRecognizer recognitionTaskWithRequest:res resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"语音识别解析失败,%@",error);
        }
        else
        {
            weakSelf.labelResult.text = result.bestTranscription.formattedString;
        }
    }];}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    __weak typeof(self) weakSelf = self;
    [SFSpeechRecognizer  requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                    weakSelf.buttonSpeakResult.enabled = NO;
                    [weakSelf.buttonSpeakResult setTitle:@"语音识别未授权" forState:UIControlStateDisabled];
                    break;
                case SFSpeechRecognizerAuthorizationStatusDenied:
                    weakSelf.buttonSpeakResult.enabled = NO;
                    [weakSelf.buttonSpeakResult setTitle:@"用户未授权使用语音识别" forState:UIControlStateDisabled];
                    break;
                case SFSpeechRecognizerAuthorizationStatusRestricted:
                    weakSelf.buttonSpeakResult.enabled = NO;
                    [weakSelf.buttonSpeakResult setTitle:@"语音识别在这台设备上受到限制" forState:UIControlStateDisabled];
                    
                    break;
                case SFSpeechRecognizerAuthorizationStatusAuthorized:
                    weakSelf.buttonSpeakResult.enabled = YES;
                    [weakSelf.buttonSpeakResult setTitle:@"开始录音" forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }
            
        });
    }];
}
- (void)startRecording{
    if (_recognitionTask) {
        [_recognitionTask cancel];
        _recognitionTask = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    NSParameterAssert(!error);
    [audioSession setMode:AVAudioSessionModeMeasurement error:&error];
    NSParameterAssert(!error);
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    NSParameterAssert(!error);
    
    _recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    NSAssert(inputNode, @"录入设备没有准备好");
    NSAssert(_recognitionRequest, @"请求初始化失败");
    _recognitionRequest.shouldReportPartialResults = YES;
    __weak typeof(self) weakSelf = self;
    _recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:_recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        BOOL isFinal = NO;
        if (result) {
            strongSelf.labelResult.text = result.bestTranscription.formattedString;
            isFinal = result.isFinal;
        }
        if (error || isFinal) {
            [self.audioEngine stop];
            [inputNode removeTapOnBus:0];
            strongSelf.recognitionTask = nil;
            strongSelf.recognitionRequest = nil;
            strongSelf.buttonSpeakResult.enabled = YES;
            [strongSelf.buttonSpeakResult setTitle:@"开始录音" forState:UIControlStateNormal];
        }
        
    }];
    
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    //在添加tap之前先移除上一个  不然有可能报"Terminating app due to uncaught exception 'com.apple.coreaudio.avfaudio',"之类的错误
    [inputNode removeTapOnBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.recognitionRequest) {
            [strongSelf.recognitionRequest appendAudioPCMBuffer:buffer];
        }
    }];
    
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
    NSParameterAssert(!error);
    self.labelResult.text = @"正在录音。。。";
}
#pragma mark - lazyload
- (AVAudioEngine *)audioEngine{
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc] init];
    }
    return _audioEngine;
}
- (SFSpeechRecognizer *)speechRecognizer{
    if (!_speechRecognizer) {
        //腰围语音识别对象设置语言，这里设置的是中文
        NSLocale *local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        
        _speechRecognizer =[[SFSpeechRecognizer alloc] initWithLocale:local];
        _speechRecognizer.delegate = self;
    }
    return _speechRecognizer;
}
#pragma mark - SFSpeechRecognizerDelegate
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available{
    if (available) {
        self.buttonSpeakResult.enabled = YES;
        [self.buttonSpeakResult setTitle:@"开始录音" forState:UIControlStateNormal];
    }
    else{
        self.buttonSpeakResult.enabled = NO;
        [self.buttonSpeakResult setTitle:@"语音识别不可用" forState:UIControlStateDisabled];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
