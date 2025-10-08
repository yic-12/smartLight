import {  httpGet ,httpPost} from "../inter/SmartHomeApi";
import { http } from "@kit.NetworkKit";
import { TokenGenerator } from "../inter/MD5";
import { Data1,Data2,commands } from "../inter/Interface1";
import { audio } from "@kit.AudioKit";
import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { PermissionManager } from '../utils/permissionMananger'
import { Permissions } from '@kit.AbilityKit'
import SpeechRecognizerManager from '../utils/SpeechRecognizerManager'
import { HttpUtil } from "../inter/HttpUtil";

// 语音识别组件
@Component
export struct VoiceRecognitionComponent {
  URL = "http://192.168.2.170:8081";
  timestamp: string = Date.now().toString()
  url1 = "/SmartHome/ShenDaRest/getLights"
  url2 = '/SmartHome/ShenDaRest/controlLight'
  @State
  text: string = ""
  // 2 实时语音识别
  fn2 = () => {
    SpeechRecognizerManager.init(res => {
      console.log("实时语音识别", JSON.stringify(res))
     this.text = res.result
    })
    console.log("打开语音")
  }
  //3.停止语音识别
  fn3 = () => {
    SpeechRecognizerManager.release();
    console.log("停止语音识别并释放资源");
  }
  fn4=()=>{
    if(this.text==='开'||'亮'){
      HttpUtil.getInstance().setLightBrightness(`${this.URL}${this.url2}`, 50,50,'0')
    }else if(this.text==='关'||'熄'){
      HttpUtil.getInstance().setLightBrightness(`${this.URL}${this.url2}`, 0,0,'1')
    }
  }
@State Command:commands[]=[
  {name:'turn_on_light',patter:['打开灯', '开灯', '亮灯'],action:'0'},
  {name:'turn_off_light',patter:['关闭灯', '关灯', '熄灯'],action:'1'},
  {name:'adjust_brightness',patter:['调亮一点', '调暗一点', '亮度调到50%'],action:'0'},
  {name:'change_color',patter:['切换颜色', '变成红色', '蓝色灯光'],action:'0'},
]

  @State isRecording: boolean = false;
  @State recordingTime: number = 0;
  @State recordingText: string = "点击开始语音识别";
  @State animationScale: number = 1.0;
  @State waveAmplitudes: number[] = [0.3, 0.5, 0.7, 0.4, 0.6, 0.8, 0.5, 0.3];

  private timer: number = -1;
  private animationTimer: number = -1;

  // 开始录音
  private startRecording() {
    this.isRecording = true;
    this.recordingTime = 0;
    this.recordingText = "正在录音...";
    this.startTimer();
    this.startAnimation();
    console.info("开始录音");
  }

  // 结束录音
  private stopRecording() {
    this.isRecording = false;
    this.recordingText = "录音结束，正在识别...";
    this.stopTimer();
    this.stopAnimation();
    console.info("结束录音");

    // 模拟识别过程
    setTimeout(() => {
      this.recordingText = "识别完成！";
      setTimeout(() => {
        this.recordingText = "点击开始语音识别";
      }, 2000);
    }, 1500);
  }

  // 开始计时器
  private startTimer() {
    this.timer = setInterval(() => {
      this.recordingTime++;
    }, 1000);
  }

  // 停止计时器
  private stopTimer() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  // 开始动画
  private startAnimation() {
    this.animationTimer = setInterval(() => {
      // 更新波形振幅
      this.waveAmplitudes = this.waveAmplitudes.map(() => Math.random() * 0.8 + 0.2);
      // 更新按钮缩放
      this.animationScale = this.animationScale === 1.0 ? 1.1 : 1.0;
    }, 200);
  }

  // 停止动画
  private stopAnimation() {
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
      this.animationTimer = -1;
    }
    this.animationScale = 1.0;
  }

  // 格式化时间显示
  private formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // 波形动画组件
  @Builder
  private WaveAnimation() {
    Row({ space: 4 }) {
      ForEach(this.waveAmplitudes, (amplitude: number, index: number) => {
        Rect()
          .width(4)
          .height(amplitude * 30 + 10)
          .fill(this.isRecording ? '#FF6B6B' : '#E0E0E0')
          .radius(2)
          .animation({
            duration: 200,
            curve: Curve.EaseInOut
          })
      })
    }
    .justifyContent(FlexAlign.Center)
    .opacity(this.isRecording ? 1 : 0.3)
  }

  build() {
    Column({ space: 30 }) {
      // 标题
      Text("语音识别")
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')
        .margin({ top: 20 })

      // 状态文本
      Text(this.recordingText)
        .fontSize(16)
        .fontColor('#7F8C8D')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 10 })

      // 录音时间显示
      if (this.isRecording) {
        Text(this.formatTime(this.recordingTime))
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E74C3C')
          .margin({ bottom: 20 })
      }

      // 波形动画
      Row() {
        this.WaveAnimation()
      }
      .margin({ bottom: 20 })

      // 录音按钮
      Button() {
        Column({ space: 8 }) {
          Image($r('app.media.yuying'))
            .width(40)
            .height(40)
            .fillColor(this.isRecording ? Color.White : '#3498DB')

          Text(this.isRecording ? "停止录音" : "开始录音")
            .fontSize(14)
            .fontColor(this.isRecording ? Color.White : '#3498DB')
            .fontWeight(FontWeight.Medium)
        }
      }
      .width(120)
      .height(120)
      .backgroundColor(this.isRecording ? '#E74C3C' : '#FFFFFF')
      .borderRadius(60)
      .border({
        width: this.isRecording ? 0 : 3,
        color: '#3498DB'
      })
      .shadow({
        radius: this.isRecording ? 20 : 10,
        color: this.isRecording ? '#E74C3C' : '#3498DB',
        offsetX: 0,
        offsetY: 4
      })
      .scale({ x: this.animationScale, y: this.animationScale })
      .animation({
        duration: 200,
        curve: Curve.EaseInOut
      })
      .onClick(() => {
        if (this.isRecording) {
          this.stopRecording();
          this.fn3()
        } else {
          this.startRecording();
          this.fn2()
          this.fn4()
        }
      })

      // 使用说明
      Column({ space: 8 }) {
        Text("使用说明")
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C3E50')

        Text("• 点击按钮开始录音")
          .fontSize(14)
          .fontColor('#7F8C8D')

        Text("• 再次点击结束录音")
          .fontSize(14)
          .fontColor('#7F8C8D')

        Text("• 系统将自动识别语音内容")
          .fontSize(14)
          .fontColor('#7F8C8D')
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 40 })
      .padding(20)
      .backgroundColor('#F8F9FA')
      .borderRadius(12)
      .width('90%')
      Blank()
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .padding({ left: 20, right: 20 })
  }
}

@Entry
@Component
export struct YYPage {
  build() {
    Column() {
      YY();
    }
    .width('100%')
    .height('100%')
  }
}

@Builder
export function YYBuilder() {
  YY();
}

@Component
export struct YY {
  pathStack: NavPathStack = new NavPathStack();
  URL = "http://192.168.2.170:8081";
  timestamp: string = Date.now().toString()
  url1="/SmartHome/ShenDaRest/getLights"
  url2='/SmartHome/ShenDaRest/controlLight'
  httpRequest =http.createHttp()
  @State data1:Data1={
    project_id: '',
    timestamp : ''
  }
  @State data2:Data2={
    timestamp: '',        // 请求时间戳，用于认证和防重放
    token: '',          // 认证令牌，基于时间戳和密钥生成
    control_sub_id:'',  // 控制的子设备ID（目标灯光设备ID）
    control_sub_state: '', // 设备控制状态：'0'=打开，'1'=关闭
    r_channel : 1,      // 红色通道值，可选参数
    g_channel : 1,      // 绿色通道值，可选参数
    b_channel : 1,      // 蓝色通道值，可选参数
    w_channel : 1,      // 白光通道值（亮度控制），可选参数
    y_channel : 1,      // 黄光通道值（色温控制），可选参数
    control_state : '',  // 控制状态，可选参数
    type_uuid: '',       // 设备类型UUID
    lightness : 1,      // 亮度值，可选参数（与w_channel可能重复，取决于API设计）
  }

  // 1 申请权限
  fn1 = async () => {
    // 准备好需要申请的权限 麦克风权限
    const permissions: Permissions[] = ["ohos.permission.MICROPHONE"]
    // 检查是否拥有权限
    const isPermission = await PermissionManager.checkPermission(permissions)
    if (!isPermission) {
      //   如果没权限，就主动申请
      PermissionManager.requestPermission(permissions)
    }
  }
    aboutToAppear(): void {
       this.fn1()
      //console.log('litePagr')
   }
  build() {
    NavDestination() {
      Column(){
        VoiceRecognitionComponent()
      }

    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .backgroundColor('#F2F8FB')
  }
}