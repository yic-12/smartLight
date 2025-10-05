import { http } from "@kit.NetworkKit";
import { Data1,Data2 } from "../inter/Interface1";


export function httpGet(url:string, method:http.RequestMethod, requestData?:Data1){
  const httpRequest = http.createHttp()
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


export function httpPost(url:string, method:http.RequestMethod, requestData?:Data2){
  const httpRequest = http.createHttp()
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