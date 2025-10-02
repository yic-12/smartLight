// 跳转页面入口函数

@Builder
export function ZDYBuilder() {
  ZDY();
}
@Entry
@Component
export struct ZDY {
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column(){
        Text("自由选择")
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