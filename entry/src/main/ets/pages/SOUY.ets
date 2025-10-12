import { AppStorageV2 } from "@kit.ArkUI";
import {  httpGet ,httpPost} from "../inter/SmartHomeApi";
import { http } from "@kit.NetworkKit";
import { TokenGenerator } from "../inter/MD5";
import { Data1,Data2 ,SceneClass,ApiRequestData, colorRgb,scenceRgb,DeviceControlItem} from "../inter/Interface1";
import { HttpUtil } from "../inter/HttpUtil";
import { deviceClass,exper,per,break1 } from "../utils/device";

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
  //URL= "http://10.214.166.140:8081"
  timestamp: string = Date.now().toString()
  url1="/SmartHome/ShenDaRest/getLights"
  url2='/SmartHome/ShenDaRest/controlLight'
  @State scene:SceneClass[]=[
    {text:'教学',icon:$r('app.media.reading')},
    {text:'实操',icon:$r('app.media.sleep')},
    {text:'会议',icon:$r('app.media.chat')},
    {text:'休息',icon:$r('app.media.watch')}
  ]
  @State devices:SceneClass[]=[
    {text:'色温调节',icon:$r('app.media.sewen')},
    {text:'定时功能',icon:$r('app.media.dinshi')},
    {text:'语音控制',icon:$r('app.media.yuying')},
    {text:'自由选择',icon:$r('app.media.gexinghua')}
  ]
  @State scence1:scenceRgb[]=[
    {scence:'教学',device:deviceClass},
    {scence:'实操',device:exper},
    {scence:'会议',device:per},
    {scence:'休息',device:break1},
  ]
  @State currentIndex1:number=-1
  @State currentIndex2:number=-1

  async setBrightness(value1: number,value2:number,value3:string,id:string) {
    await HttpUtil.getInstance().setLightBrightness(`${this.URL}${this.url2}`, value1,value2,value3,id)
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
                const sceneData = this.scence1[index];
                // 切换选择：首次选中为“开”，再次点击同一项为“关”
                const isTurningOff = this.currentIndex1 === index;
                // 更新当前索引，高亮仅在“开”时保留
                this.currentIndex1 = isTurningOff ? -1 : index;

                // 根据点击意图构造设备列表：开= '0'，关= '1'
                const mappedDevices: DeviceControlItem[] = []
                for (let i = 0; i < sceneData.device.length; i++) {
                  const d = sceneData.device[i]
                  const item = {
                    control_sub_id: d.control_sub_id,
                    control_sub_state: isTurningOff ? '1' : '0',
                    r_channel:d.r_channel,
                    w_channel: d.w_channel,
                    y_channel: d.y_channel,
                    type_uuid: d.type_uuid ? d.type_uuid : 'LIGHT_GROUP',
                  } as DeviceControlItem
                  mappedDevices.push(item)
                }
                await HttpUtil.getInstance().controlColorMultipleDevices(`${this.URL}${this.url2}`, mappedDevices);
                //await HttpUtil.getInstance().controlMultipleDevices(`${this.URL}${this.url2}`, mappedDevices);
                console.log('场景控制多设备：', sceneData.scence);
                console.log('设备', JSON.stringify(mappedDevices))
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
