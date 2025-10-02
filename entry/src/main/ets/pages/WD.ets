import { ToggleModifier } from "@kit.ArkUI"

@Component
export struct WD{


  build() {
  Column(){
    Column(){
      Image($r('app.media.touxiang'))
        .width(50).fillColor(Color.Black)
      Text('TOM')
        .margin({top:20})
        .fontSize(34)
        .fontColor('#2c2c2c')
        .fontWeight(400)
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .backgroundColor('#FFF')
    .border({radius:20})
    .padding(10)
    Column(){

    }
  }.width('100%')
  .height('100%')
  .padding({left:10,right:10,top:5,bottom:5})
  }
}

