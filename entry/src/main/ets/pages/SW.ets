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
  //URL = "http://192.168.2.170:8081";
  URL= "http://10.214.166.140:8081"
  timestamp: string = Date.now().toString()
  url1 = "/SmartHome/ShenDaRest/getLights"
  url2 = '/SmartHome/ShenDaRest/controlLight'
  //httpRequest = http.createHttp()
  @State data1: Data1 = {
    project_id: '',
    timestamp: ''
  }
  @State   data2: Data2 = {
    timestamp: '', // 请求时间戳，用于认证和防重放
    token: '', // 认证令牌，基于时间戳和密钥生成
    control_sub_id: '', // 控制的子设备ID（目标灯光设备ID）
    control_sub_state: '0', // 设备控制状态：'0'=打开，'1'=关闭
    r_channel: 100, // 红色通道值，可选参数
    g_channel: 0, // 绿色通道值，可选参数
    b_channel: 0, // 蓝色通道值，可选参数
    w_channel: 100, // 白光通道值（亮度控制），可选参数
    y_channel: 100, // 黄光通道值（色温控制），可选参数
    control_state: '', // 控制状态，可选参数
    type_uuid: 'LIGHT_GROUP', // 设备类型UUID
    lightness: 50, // 亮度值，可选参数（与w_channel可能重复，取决于API设计）
  }
  @State currentBrightness: number = 50
  @State currentColorTemperature: number = 50
  @State turn:'1'|'0'='1'

  async setBrightness(value1: number,value2:number,id:string) {
     await HttpUtil.getInstance().setLightBrightness(`${this.URL}${this.url2}`, value1,value2,'0',this.data2.control_sub_id)
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
      this.data2.control_sub_id = this.data2.control_sub_id || '6b3f2977496844fd879845645099c5dd';
      // 控制类型：0=打开，1=关闭；若未设置，默认打开
      this.data2.control_sub_state = this.data2.control_sub_state || '1';
      // 灯类型必填：LIGHT_GROUP
      this.data2.type_uuid = this.data2.type_uuid || 'LIGHT_GROUP';
      this.setBrightness(this.currentBrightness,this.currentColorTemperature,this.data2.control_sub_id)
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
          this.data2.control_sub_id = this.data2.control_sub_id || 'b4e3359c8c3c420faa81e2b0c7aed1e0';
          // 控制类型：0=打开，1=关闭；若未设置，默认打开
          this.data2.control_sub_state = this.data2.control_sub_state || '1';
          // 灯类型必填：LIGHT_GROUP
          this.data2.type_uuid = this.data2.type_uuid || 'LIGHT_GROUP';
         this.setBrightness(this.currentBrightness,this.currentColorTemperature,this.data2.control_sub_id)
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
            // 先生成时间戳，确保token使用的时间戳与URL中的一致
            this.timestamp = Date.now().toString();
            const token: string = (await TokenGenerator.generateToken(this.timestamp)).toLowerCase()
            // 使用路径参数而非查询参数
            httpGet(`${this.URL}${this.url1}/${this.timestamp}/${token}`, http.RequestMethod.GET, this.data1)
            console.log(`请求GET  ${this.URL}${this.url1}/${this.timestamp}/${token}`)
          })

        Button("POST")
          .fontSize(23)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Blue)
          .onClick(async () => {
            // 先生成时间戳，确保token使用的时间戳与请求中的一致
           // this.timestamp = Date.now().toString();
           // const token = await TokenGenerator.generateToken(this.timestamp);
            
            // 更新data2中的时间戳和token
           // this.data2.timestamp = this.timestamp;
            //this.data2.token = token;

            // 填充必填字段，避免为空导致服务端校验失败
            // control_sub_id 应为实际灯具/子设备ID，此处示例使用与 HttpUtil 保持一致的占位符
            this.data2.control_sub_id = '0a18195ec9d54e56801e073a2e3feebc';;
            // 控制类型：0=打开，1=关闭；若未设置，默认打开
            this.data2.control_sub_state = '1';
            // 灯类型必填：LIGHT_GROUP
            this.data2.type_uuid = this.data2.type_uuid || 'LIGHT_GROUP';
            
            // 走统一的 HttpUtil，内部使用与服务端兼容的表单提交与小写token
            await HttpUtil.getInstance().setLightBrightness(
              `${this.URL}${this.url2}`,
              this.currentBrightness,
              this.currentColorTemperature,
              this.data2.control_sub_state || '0',
              this.data2.control_sub_id
            )
            console.log(`已通过 HttpUtil 提交控制请求 -> brightness=${this.currentBrightness}, temp=${this.currentColorTemperature},data=${this.data2.control_sub_state},data1=${this.data2.control_sub_id}`)
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