
@Builder
export function SWBuilder() {
  SW();
}
@Entry
@Component
export struct SW {
  pathStack: NavPathStack = new NavPathStack();
  build() {
    NavDestination() {
      Column(){
        Text("色温调节")
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