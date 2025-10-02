// 跳转页面入口函数

@Builder
export function YYBuilder() {
  YY();
}
@Entry
@Component
export struct YY {
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column(){
        Text("语音控制")
          .fontSize(23)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Blue)
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    }).backgroundColor('#F2F8FB')
  }
}