import { AppStorageV2 } from "@kit.ArkUI";
import {  httpGet ,httpPost} from "../inter/SmartHomeApi";
import { http } from "@kit.NetworkKit";
import { TokenGenerator } from "../inter/MD5";
import { Data1,Data2 ,SceneClass,ApiRequestData, colorRgb,scenceRgb} from "../inter/Interface1";
import { HttpUtil } from "../inter/HttpUtil";

// 获取当前日期并格式化为 Dec 5, 2019 格式
function formatDate(date?: Date): string {
  // 如果未传入日期，默认使用当前日期
  const targetDate = date ? date : new Date();

  // 月份缩写数组
  const monthAbbr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  // 获取月份（0-11），对应到缩写数组
  const month = monthAbbr[targetDate.getMonth()];
  // 获取日期
  const day = targetDate.getDate();
  // 获取年份
  const year = targetDate.getFullYear();

  // 拼接成 Dec 5, 2019 格式
  return `${month} ${day}, ${year}`;
}
@Builder
export function SOUYBuilder() {
  SOUY();
}
@Component
export struct  SOUY{
  pathStack: NavPathStack = AppStorageV2.connect(NavPathStack,'navStack',()=>new NavPathStack())!;
  URL = "http://192.168.2.170:8081";
  timestamp: string = Date.now().toString()
  url1="/SmartHome/ShenDaRest/getLights"
  url2='/SmartHome/ShenDaRest/controlLight'
  @State scene:SceneClass[]=[
    {text:'阅读',icon:$r('app.media.reading')},
    {text:'睡眠',icon:$r('app.media.sleep')},
    {text:'会客',icon:$r('app.media.chat')},
    {text:'影视',icon:$r('app.media.watch')}
  ]
  @State devices:SceneClass[]=[
    {text:'色温调节',icon:$r('app.media.sewen')},
    {text:'定时功能',icon:$r('app.media.dinshi')},
    {text:'语音控制',icon:$r('app.media.yuying')},
    {text:'自由选择',icon:$r('app.media.gexinghua')}
  ]
  @State scence1:scenceRgb[]=[
    {scence:'阅读',Rbg:{r:1,g:2,b:3},Brightness:20,temperature:20},
    {scence:'睡眠',Rbg:{r:1,g:2,b:3},Brightness:20,temperature:20},
    {scence:'会客',Rbg:{r:1,g:2,b:3},Brightness:20,temperature:20},
    {scence:'影视',Rbg:{r:1,g:2,b:3},Brightness:20,temperature:20},
  ]
  @State currentIndex1:number=-1
  @State currentIndex2:number=-1

  async setBrightness(value1: number,value2:number,value3:string,color1:colorRgb) {
    await HttpUtil.getInstance().setLightColorBrightness(`${this.URL}${this.url2}`, value1,value2,value3,color1)
    console.log('测试场景')
  }

  build() {
      Column() {
        Column({ space: 8 }) {
          Text(`${formatDate()}`)
            .fontSize(12)
          Row({space:100}){
            Text("Welcome,")
              .fontSize(34)
              .fontColor('#2c2c2c')
              .fontWeight(700)
            Image($r('app.media.touxiang')).width(70).fillColor(Color.Black).margin({bottom:10})
          }
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .backgroundColor('#FFF')
        .border({radius:20})
        .padding(10)

        Column(){
          Text('Scenes')
            .fontSize(22)
            .fontColor('#2c2c2c')
            .fontWeight(600)
          Row({space:10}) {
            ForEach(this.scene, (item: SceneClass, index: number) => {
              Column(){
                Image(item.icon)
                  .width(24)
                Text(item.text)
                  .fontSize(14)
                  .fontWeight(500)
                  .fontColor(Color.Black)
              }
              .onClick(async ()=>{
                this.currentIndex1 = this.currentIndex1 === index ? -1 : index;
                
                // 当选中场景时，调用智能家居API
                if (this.currentIndex1 === index) {
                 // const sceneNames = ['reading', 'sleep', 'meeting', 'entertainment'];
                  const sceneName = this.scence1[index];
                  
                  // 调用API设置场景
               //   const sceneData: ApiRequestData = {
                   // scene: sceneName,
                   // timestamp: Date.now()
                 // };
                 // await this.callSmartHomeApi('/SmartHome/ShenDaRest/controlLight', sceneData);
                  await this.setBrightness(sceneName.Brightness,sceneName.temperature,'0',sceneName.Rbg)
                }
              })
              .padding(15)
              .layoutWeight(1)
              .backgroundColor(this.currentIndex1===index?'#e16531':'#FFF')
              .border({radius:20})
            })
          }.margin({top:30})
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        //.backgroundColor('#FFF')
        .border({radius:20})
        .padding(10)

        Column() {
          Text('Devices')
            .fontSize(22)
            .fontColor('#2c2c2c')
            .fontWeight(600)
            .margin({bottom:10})
          List() {
            ForEach(this.devices, (item1: SceneClass, index1: number) => {
              ListItem() {
                Column({space:7}) {
                  Image(item1.icon).width(40).fillColor(Color.Black)
                  Text(item1.text)
                    .fontSize(14)
                    .fontWeight(500)
                    .fontColor(Color.Black)
                }.width('100%').height(150).backgroundColor('#FFF').border({radius:20}).padding(40)
                .onClick(async () => {
                  this.currentIndex2 = index1;
                  
                  // 调用API控制设备
                 // const deviceTypes = ['color_temperature', 'timer', 'voice_control', 'custom'];
                 // const deviceType = deviceTypes[index1];
                  
                  //const deviceData: ApiRequestData = {
                  //  device: deviceType,
                   // action: 'activate',//告诉 API “对该设备模块执行什么操作”（动作指令），activate 表示 “激活 / 启用”（对应场景：如激活定时功能、启用语音控制）。
                                      // 若后续需要 “关闭” 操作，可将 action 改为 'deactivate'，需与后端 API 约定一致）
                   // timestamp: Date.now()
                //  };
                 // await this.callSmartHomeApi('/device/control', deviceData);
                  
                  // 导航到对应页面
                  if (this.currentIndex2 === 0) {
                    this.pathStack.pushPathByName('SW', null, false);
                  } else if (this.currentIndex2 === 1) {
                    this.pathStack.pushPathByName('DS', null, false);
                  } else if (this.currentIndex2 === 2) {
                    this.pathStack.pushPathByName('YY', null, false);
                  } else if (this.currentIndex2 === 3) {
                    this.pathStack.pushPathByName('ZDY', null, false);
                  }
                })
              }
              .padding(10)
            })
          }.listDirection(Axis.Vertical).lanes(2,2) .layoutWeight(1)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .border({radius:20})
        .padding(10)
      }
      .width('100%')
      .height('100%')
      .padding({left:10,right:10,top:5,bottom:5})
    }
  }
