import { http } from "@kit.NetworkKit"
import { Data1,Data2 } from "../inter/Interface1";
export class HttpUtil{
  private static instance:HttpUtil=new HttpUtil()
  private httpRequest:http.HttpRequest
  private constructor() {
    this.httpRequest=http.createHttp()
  }
  public static getInstance():HttpUtil{
    return HttpUtil.instance
  }
  async setLightBrightness(url:string,light:number,temperature:number){
    let data1:Data2={
      timestamp: '',        // 请求时间戳，用于认证和防重放
      token: '',          // 认证令牌，基于时间戳和密钥生成
      control_sub_id:'',  // 控制的子设备ID（目标灯光设备ID）
      control_sub_state: '', // 设备控制状态：'0'=打开，'1'=关闭
      r_channel : 0,      // 红色通道值，可选参数
      g_channel : 0,      // 绿色通道值，可选参数
      b_channel : 0,      // 蓝色通道值，可选参数
      w_channel : light,      // 白光通道值（亮度控制），可选参数
      y_channel : temperature,      // 黄光通道值（色温控制），可选参数
      control_state : '',  // 控制状态，可选参数
      type_uuid: '',       // 设备类型UUID
      lightness : 0,      // 亮度值，可选参数（与w_channel可能重复，取决于API设计）
    }
    let options:http.HttpRequestOptions={
      method:http.RequestMethod.POST,
      header:{
        'Content-Type': 'application/json'
      },
      extraData:JSON.stringify(data1),
      connectTimeout:9000,  //前端发送数据给后端如果9秒没有结果，前端主动终止行为
      readTimeout:9000, //读取数据超过9秒，告诉前端请求失败
    }
    let response =await this.httpRequest.request(url,options)
      .then(res=>{console.log(`请求成功，返回数据：${JSON.stringify(res)}`)})
  }


}