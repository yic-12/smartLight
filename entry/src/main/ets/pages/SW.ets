import {  MyRequest ,SmartHomeApi} from "../inter/SmartHomeApi";
import { http } from "@kit.NetworkKit";
import { TokenGenerator } from "../inter/MD5";
@Builder
export function SWBuilder() {
  SW();
}
@Entry
@Component
export struct SW {
  pathStack: NavPathStack = new NavPathStack();
    URL = "http://192.168.2.170:8081";
    timestamp: number = Date.now()
   url1="/SmartHome/ShenDaRest/getLights"
   url2='/SmartHome/ShenDaRest/controlLight'
  httpRequest =http.createHttp()
  build() {
    NavDestination() {
      Column(){
        Button("get")
          .fontSize(23)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Blue)
          .onClick(async () => {
        try{
        const  token = await TokenGenerator.generateToken();
          const queryParams = `timestamp=${encodeURIComponent(this.timestamp)}&token=${encodeURIComponent(token)}`
          MyRequest(`${this.URL}${this.url1}?${queryParams}`,http.RequestMethod.GET)
          console.log(`请求GET  ${this.URL}${this.url1}?${queryParams}`)
        }catch (error) {
          // 10. 捕获所有错误（Token 生成失败、请求失败等）
          console.error(`[SW] 获取灯光列表失败: ${(error as Error).message}`, error);
          // （可选）添加错误提示 UI，如 Toast 提示用户
        }
          })
        Button("POST")
          .fontSize(23)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Blue)
          .onClick(async () => {
            try{
              const  token = await TokenGenerator.generateToken();
              const queryParams = `timestamp=${encodeURIComponent(this.timestamp)}&token=${encodeURIComponent(token)}`
              MyRequest(`${this.URL}${this.url2}`,http.RequestMethod.POST)
              console.log(`请求POST  ${this.URL}${this.url2}`)
            }catch (error) {
              // 10. 捕获所有错误（Token 生成失败、请求失败等）
              console.error(`[SW] 获取灯光列表失败: ${(error as Error).message}`, error);
              // （可选）添加错误提示 UI，如 Toast 提示用户
            }


          })

      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    }).backgroundColor('#F2F8FB')
  }
}