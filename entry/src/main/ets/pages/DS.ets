// 跳转页面入口函数

@Builder
export function DSBuilder() {
  DS();
}
@Entry
@Component
export struct DS {
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column(){
        Text("定时功能")
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