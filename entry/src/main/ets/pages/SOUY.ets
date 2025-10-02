import { AppStorageV2 } from "@kit.ArkUI";
import { TokenGenerator } from "../inter/MD5";

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

interface  SceneClass{
  text:string
  icon:ResourceStr
}

interface ApiRequestData {
  scene?: string;
  device?: string;
  action?: string;
  timestamp: number;
}


@Builder
export function SOUYBuilder() {
  SOUY();
}
@Component
export struct  SOUY{
  pathStack: NavPathStack = AppStorageV2.connect(NavPathStack,'navStack',()=>new NavPathStack())!;
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
  @State currentIndex1:number=-1
  @State currentIndex2:number=-1

  /**
   * 生成API请求token
   */
  private async generateApiToken(): Promise<string> {
    try {
      const token = await TokenGenerator.generateToken();
      console.info('生成的API Token:', token);
      return token;
    } catch (error) {
      console.error('Token生成失败:', error);
      throw new Error(`Token生成失败: ${error}`);
    }
  }

  /**
   * 调用智能家居API的示例方法
   * 局域网地址: http://192.168.2.170:8081/{path}
   * 校内网地址: http://10.214.166.140:8081/{path}
   */
  private async callSmartHomeApi(path: string, data?: ApiRequestData): Promise<void> {
    try {
      // 生成token
      const token = await this.generateApiToken();
      
      // 这里可以根据需要选择网络环境
      const baseUrl = "http://192.168.2.170:8081"; // 603教室局域网
      // const baseUrl = "http://10.214.166.140:8081"; // 校内网
      
      const url = `${baseUrl}${path.startsWith('/') ? path : '/' + path}`;
      
      console.info(`准备调用API: ${url}`);
      console.info(`Token: ${token}`);
      
      if (data) {
        console.info('请求数据:', JSON.stringify(data));
      }
      
      // 这里可以添加实际的HTTP请求代码
      // 目前只是打印日志，您可以根据需要添加实际的网络请求
      
    } catch (error) {
      console.error('API调用失败:', error);
    }
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
                  const sceneNames = ['reading', 'sleep', 'meeting', 'entertainment'];
                  const sceneName = sceneNames[index];
                  
                  // 调用API设置场景
                  const sceneData: ApiRequestData = {
                    scene: sceneName,
                    timestamp: Date.now()
                  };
                  await this.callSmartHomeApi('/scene/set', sceneData);
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
                  const deviceTypes = ['color_temperature', 'timer', 'voice_control', 'custom'];
                  const deviceType = deviceTypes[index1];
                  
                  const deviceData: ApiRequestData = {
                    device: deviceType,
                    action: 'activate',
                    timestamp: Date.now()
                  };
                  await this.callSmartHomeApi('/device/control', deviceData);
                  
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
