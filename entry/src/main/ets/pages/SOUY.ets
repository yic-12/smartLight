import { AppStorageV2 } from "@kit.ArkUI";

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
              .onClick(()=>{
                this.currentIndex1 = this.currentIndex1 === index ? -1 : index;
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
