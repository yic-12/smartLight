import {  httpGet ,httpPost} from "../inter/SmartHomeApi";
import { http } from "@kit.NetworkKit";
import { TokenGenerator } from "../inter/MD5";
import { Data1,Data2 } from "../inter/Interface1";

@Builder
export function YYBuilder() {
  YY();
}
@Entry
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
  build() {
    NavDestination() {
      Column(){
        Text("语音控制")
          .fontSize(23)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Blue)
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    }).backgroundColor('#F2F8FB')
  }
}