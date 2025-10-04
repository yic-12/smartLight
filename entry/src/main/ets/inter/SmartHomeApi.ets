//在common模块中封装一个基础的请求工具

import { http } from "@kit.NetworkKit";
import { TokenGenerator } from "./MD5";
//封装请求代码，考虑到以后每个模块都要发送请求，默认放在common模块中。
//1、导入
export class SmartHomeApi {

}
export function MyRequest(
  url:string,
  method:http.RequestMethod,
  requestData?:string){

  //2、创建http请求
  const httpRequest = http.createHttp()
  const  URL = "http://192.168.2.170:8081";
  const token =  TokenGenerator.generateToken();
  const timestamp: number = Date.now()
  const url1="/SmartHome/ShenDaRest/getLights"
  const url2='/SmartHome/ShenDaRest/controlLight'
  const  Url1 = `${URL}${url1.startsWith('/') ? url1 : '/' + url1}${url1}${timestamp}${token}`;
  const Url2=`${URL}${url1.startsWith('/') ? url1 : '/' + url}${url2}`
  httpRequest.request(url, {
    method:method,//请求方式
    header:{
      //设置请求头
      //前端浏览器告诉后端，前端传递的数据格式
      'Content-Type': 'application/json'
    },
    extraData:requestData, //设置请求要传给后端的数据
    connectTimeout:9000,  //前端发送数据给后端如果9秒没有结果，前端主动终止行为
    readTimeout:9000, //读取数据超过9秒，告诉前端请求失败
  },(error:Error,data:http.HttpResponse)=>{
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
}
