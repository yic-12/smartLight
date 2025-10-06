import {  httpGet ,httpPost} from "../inter/SmartHomeApi";
import { http } from "@kit.NetworkKit";
import { TokenGenerator } from "../inter/MD5";
import { Data1,Data2 } from "../inter/Interface1";
import { HttpUtil } from "../inter/HttpUtil";
import {PreferencesUtil,DeviceSettings} from "../inter/PreferencesUtil"
import EntryAbility from "../entryability/EntryAbility"
import { Context } from '@kit.AbilityKit'

@Builder
export function SWBuilder() {
  SW();
}

@Entry
@Component
 struct SW {
  pathStack: NavPathStack = new NavPathStack();
  URL = "http://192.168.2.170:8081";
  timestamp: string = Date.now().toString()
  url1 = "/SmartHome/ShenDaRest/getLights"
  url2 = '/SmartHome/ShenDaRest/controlLight'
  httpRequest = http.createHttp()
  @State data1: Data1 = {
    project_id: '',
    timestamp: ''
  }
  @State data2: Data2 = {
    timestamp: '', // 请求时间戳，用于认证和防重放
    token: '', // 认证令牌，基于时间戳和密钥生成
    control_sub_id: '', // 控制的子设备ID（目标灯光设备ID）
    control_sub_state: '', // 设备控制状态：'0'=打开，'1'=关闭
    r_channel: 1, // 红色通道值，可选参数
    g_channel: 1, // 绿色通道值，可选参数
    b_channel: 1, // 蓝色通道值，可选参数
    w_channel: 1, // 白光通道值（亮度控制），可选参数
    y_channel: 1, // 黄光通道值（色温控制），可选参数
    control_state: '', // 控制状态，可选参数
    type_uuid: '', // 设备类型UUID
    lightness: 1, // 亮度值，可选参数（与w_channel可能重复，取决于API设计）
  }
  @State currentBrightness: number = 50
  @State currentColorTemperature: number = 50
  @State turn:'1'|'0'='1'

  async setBrightness(value1: number,value2:number) {
     await HttpUtil.getInstance().setLightBrightness(`${this.URL}${this.url2}`, value1,value2,'0')
  }




  build() {
    NavDestination() {
      Column() {
        Column(){
          Text("色温调节")
            .fontSize(23)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Blue)
            .textAlign(TextAlign.Center)

        }
         .margin({bottom:20})

         Column({space:20}){
             Row() {
               Text('亮度调节')
               .fontSize(16)
               .fontWeight(FontWeight.Medium)
               .fontColor('#2c2c2c')
                Blank()  // 占位空间
               Text(this.currentBrightness + '%')  // 当前亮度百分比
              .fontSize(16)
               .fontColor('#2c2c2c')
           }
         .width('100%')
  Slider({
    value: this.currentBrightness,
    min: 0,      // 最小值 0%
    max: 100,    // 最大值 100%
    step: 1,     // 步长 1%
    style: SliderStyle.OutSet  // 外凸样式
  })
    .onChange(async (value1: number) => {
      // 亮度调节滑块
      this.currentBrightness = value1  // 更新亮度值
      this.setBrightness(this.currentBrightness,this.currentColorTemperature)
      console.log(`请求GET `)
      const ctx: Context = EntryAbility.appContext
      if (ctx) {
        PreferencesUtil.saveSettings(ctx, { brightness: this.currentBrightness, colorTemperature: this.currentColorTemperature })
      }
    })
}
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .border({radius:20})
          .margin({ bottom: 40 })
    Column({space:20}){
      Row() {
        Text('色温调节')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2c2c2c')
        Blank()  // 占位空间
        Text(this.currentColorTemperature + '%')  // 当前亮度百分比
          .fontSize(16)
          .fontColor('#2c2c2c')
      }
      .width('100%')
      Slider({
        value: this.currentColorTemperature,
        min: 0,      // 最小值 0%
        max: 100,    // 最大值 100%
        step: 1,     // 步长 1%
        style: SliderStyle.OutSet  // 外凸样式
      })
        .onChange(async (value2: number) => {
          // 亮度调节滑块
          this.currentColorTemperature = value2 // 更新亮度值
          this.setBrightness(this.currentBrightness,this.currentColorTemperature)
          console.log(`请求GET `)
          const ctx: Context = EntryAbility.appContext
          if (ctx) {
            PreferencesUtil.saveSettings(ctx, { brightness: this.currentBrightness, colorTemperature: this.currentColorTemperature })
          }
        })
    }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
           .border({radius:20})
          .margin({ top: 40 })



        Button("get")
          .fontSize(23)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Blue)
          .onClick(async () => {
            const token = await TokenGenerator.generateToken();
            const queryParams = `timestamp=${encodeURIComponent(this.timestamp)}&token=${encodeURIComponent(token)}`
            httpGet(`${this.URL}${this.url1}?${queryParams}`, http.RequestMethod.GET, this.data1)
            console.log(`请求GET  ${this.URL}${this.url1}?${queryParams}`)
          })

        Button("POST")
          .fontSize(23)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Blue)
          .onClick(async () => {
            const token = await TokenGenerator.generateToken();
            const queryParams = `timestamp=${encodeURIComponent(this.timestamp)}&token=${encodeURIComponent(token)}`
            httpPost(`${this.URL}${this.url2}`, http.RequestMethod.POST, this.data2)
            console.log(`请求POST  ${this.URL}${this.url2}`)
          })
      }
      .width('100%')
      .padding(20)
      .borderRadius(20)
      .margin({ bottom: 20 })

    }.backgroundColor('#F2F8FB')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
        // 加载已保存的亮度与色温
        const ctx: Context = EntryAbility.appContext;
        if (ctx) {
          const settings: DeviceSettings = PreferencesUtil.loadSettings(ctx);
          this.currentBrightness = settings.brightness;
          this.currentColorTemperature = settings.colorTemperature;
        }
    })
      .onAppear(() => {
        // 页面出现时确保状态与存储同步
        const ctx: Context = EntryAbility.appContext;
        if (ctx) {
          const settings: DeviceSettings = PreferencesUtil.loadSettings(ctx);
          this.currentBrightness = settings.brightness;
          this.currentColorTemperature = settings.colorTemperature;
        }
      })

  }
  }