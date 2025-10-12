import { http } from "@kit.NetworkKit"
import { Data1,Data2,colorRgb,DeviceControlItem,MultiDeviceControlData } from "../inter/Interface1";
import { TokenGenerator } from "../inter/MD5";
export class HttpUtil{
  private static instance:HttpUtil=new HttpUtil()
  private constructor() {
  }
  public static getInstance():HttpUtil{
    return HttpUtil.instance
  }
  async setLightBrightness(url:string,light:number,temperature:number,state:string,id:string){
    let isOff = state === '1'
    const timestamp: string = Date.now().toString()
    const token: string = (await TokenGenerator.generateToken(timestamp)).toLowerCase()
    let data1:Data2={
      timestamp: timestamp,        // 请求时间戳，用于认证和防重放（与token一致）
      token: token, // 认证令牌：MD5(timestamp + key)
      control_sub_id:id,  // 控制的子设备ID（目标灯光设备ID）
      control_sub_state: state, // 设备控制状态：'0'=打开，'1'=关闭
      r_channel : 0,      // 红色通道值，可选参数
      g_channel : 0,      // 绿色通道值，可选参数
      b_channel : 0,      // 蓝色通道值，可选参数
      w_channel : isOff ? 0 : light,      // 白光通道值（亮度控制），可选参数
      y_channel : temperature,      // 黄光通道值（色温控制），可选参数
      control_state : '',  // 控制状态，可选参数
      type_uuid: 'LIGHT_GROUP',       // 设备类型UUID
      lightness : 0,      // 亮度值，可选参数（与w_channel可能重复，取决于API设计）
    }
    // 构建 x-www-form-urlencoded 请求体（避免参数解构语法）
    let formPairs1: string[] = []
    const entries1: Array<[string, string | number]> = [
      ['timestamp', data1.timestamp],
      ['token', data1.token],
      ['control_sub_id', data1.control_sub_id],
      ['control_sub_state', data1.control_sub_state],
      ['r_channel', data1.r_channel ?? ''],
      ['g_channel', data1.g_channel ?? ''],
      ['b_channel', data1.b_channel ?? ''],
      ['w_channel', data1.w_channel ?? ''],
      ['y_channel', data1.y_channel ?? ''],
      ['control_state', data1.control_state ?? ''],
      ['type_uuid', data1.type_uuid],
      ['lightness', data1.lightness ?? ''],
    ]
    for (let i = 0; i < entries1.length; i++) {
      const key = entries1[i][0]
      const value = entries1[i][1]
      if (value !== undefined && value !== null && String(value) !== '') {
        formPairs1.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`)
      }
    }
    const formBody = formPairs1.join('&')
    let options:http.HttpRequestOptions={
      method:http.RequestMethod.POST,
      header:{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      extraData:formBody,
      connectTimeout:9000,  //前端发送数据给后端如果9秒没有结果，前端主动终止行为
      readTimeout:9000, //读取数据超过9秒，告诉前端请求失败
    }
    const httpRequest = http.createHttp()
    let response =await  await httpRequest.request(url,options,(error:Error,data:http.HttpResponse)=>{
      //error没有内容代表成功
      if (!error) {
        console.log(`请求成功，返回数据：${JSON.stringify(data)}`)
        // 取消订阅HTTP响应头事件。
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
      httpRequest.destroy();
      }else {
        console.log(`请求失败，具体原因：${JSON.stringify(error)}`)
        // 取消订阅HTTP响应头事件。
       httpRequest.off('headersReceive');
        // 当该请求使用完毕时，调用destroy方法主动销毁该JavaScript Object。
        httpRequest.destroy();
      }
    })
    // .then(res=>{console.log(`请求成功，返回数据：${JSON.stringify(res)}`)})
  }
  async setLightColorBrightness(url:string,light:number,temperature:number,state:string,r:number,g:number,b:number,id:string){
    let isOff = state === '1'
    const timestamp: string = Date.now().toString()
    const token: string = (await TokenGenerator.generateToken(timestamp)).toLowerCase()
    let data1:Data2={
      timestamp: timestamp,        // 请求时间戳，用于认证和防重放（与token一致）
      token: token,          // 认证令牌：MD5(timestamp + key)
      control_sub_id:id,  // 控制的子设备ID（目标灯光设备ID）
      control_sub_state: state, // 设备控制状态：'0'=打开，'1'=关闭
      r_channel : r  ,    // 红色通道值
      g_channel : g,      // 绿色通道值
      b_channel : b,      // 蓝色通道值
      w_channel : isOff ? 0 : light,      // 白光通道值（亮度控制），可选参数
      y_channel : temperature,      // 黄光通道值（色温控制），可选参数
      control_state : '',  // 控制状态，可选参数
      type_uuid: 'LIGHT_GROUP',       // 设备类型UUID
      lightness : 0,      // 亮度值，可选参数（与w_channel可能重复，取决于API设计）
    }
    // 构建 x-www-form-urlencoded 请求体（避免参数解构语法）
    let formPairs2: string[] = []
    const entries2: Array<[string, string | number]> = [
      ['timestamp', data1.timestamp],
      ['token', data1.token],
      ['control_sub_id', data1.control_sub_id],
      ['control_sub_state', data1.control_sub_state],
      ['r_channel', data1.r_channel ?? ''],
      ['g_channel', data1.g_channel ?? ''],
      ['b_channel', data1.b_channel ?? ''],
      ['w_channel', data1.w_channel ?? ''],
      ['y_channel', data1.y_channel ?? ''],
      ['control_state', data1.control_state ?? ''],
      ['type_uuid', data1.type_uuid],
      ['lightness', data1.lightness ?? ''],
    ]
    for (let i = 0; i < entries2.length; i++) {
      const key = entries2[i][0]
      const value = entries2[i][1]
      if (value !== undefined && value !== null && String(value) !== '') {
        formPairs2.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`)
      }
    }
    const formBody = formPairs2.join('&')
    let options:http.HttpRequestOptions={
      method:http.RequestMethod.POST,
      header:{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      extraData:formBody,
      connectTimeout:9000,  //前端发送数据给后端如果9秒没有结果，前端主动终止行为
      readTimeout:9000, //读取数据超过9秒，告诉前端请求失败
    }
    const httpRequest = http.createHttp()
    let response =await httpRequest.request(url,options,(error:Error,data:http.HttpResponse)=>{
      //error没有内容代表成功
      if (!error) {
        console.log(`请求成功，返回数据：${JSON.stringify(data)}`)
        // 取消订阅HTTP响应头事件。
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
        httpRequest.destroy();
      }else {
        console.log(`请求失败，具体原因：${JSON.stringify(error)}`)
        // 取消订阅HTTP响应头事件。
         httpRequest.off('headersReceive');
        // 当该请求使用完毕时，调用destroy方法主动销毁该JavaScript Object。
        httpRequest.destroy();
      }
    })
    // .then(res=>{console.log(`请求成功，返回数据：${JSON.stringify(res)}`)})
  }
  /**
   * 控制多个设备
   * @param url API地址
   * @param deviceControls 设备控制项列表
   */
  async controlMultipleDevices(url: string, deviceControls: DeviceControlItem[]) {
    // 兼容后端单设备接口：逐个设备调用单设备控制，保证 control_sub_id 在表单顶层
    for (let i = 0; i < deviceControls.length; i++) {
      const item = deviceControls[i]
      try {
        await this.setLightBrightness(
          url,
         // item.r_channel?? 0,
         // item.g_channel??0,
         // item.b_channel??0,
          item.w_channel ?? 0,
          item.y_channel ?? 0,
          item.control_sub_state,
          item.control_sub_id
        )
        console.log(`多设备子请求成功：id=${item.control_sub_id}`)
      } catch (e) {
        console.error(`多设备子请求失败：id=${item.control_sub_id}, err=${e}`)
      }
    }
  }
  async controlColorMultipleDevices(url: string, deviceControls: DeviceControlItem[]) {
    // 兼容后端单设备接口：逐个设备调用单设备控制，保证 control_sub_id 在表单顶层
    for (let i = 0; i < deviceControls.length; i++) {
      const item = deviceControls[i]
      try {
        await this.setLightColorBrightness(
          url,
          item.w_channel ?? 0,
          item.y_channel ?? 0,
          item.control_sub_state,
          item.r_channel??0,
          item.g_channel??0,
          item.b_channel??0,
          item.control_sub_id,
        )
        console.log(`多设备子请求成功：id=${item.control_sub_id}`)
      } catch (e) {
        console.error(`多设备子请求失败：id=${item.control_sub_id}, err=${e}`)
      }
    }
  }
}