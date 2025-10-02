import { SOUY } from './SOUY'
import { WD } from './WD'

interface  TabClass{
  text:string
  icon:ResourceStr
}

@Builder
export function LayoutBuilder() {
  Layout();
}
@Entry
@Component
struct Layout {
  @State currentIndex:number=0
  pathStack: NavPathStack = new NavPathStack();
  tabData: TabClass[] = [
    { text: 'Home', icon: $r('app.media.home') },
    { text: 'Setting', icon: $r('app.media.setting') }
  ]
  @Builder
  tabBuilder(item:TabClass,index:number){
    Row({space:5}){
      Image(item.icon)
        .width(24)
        .fillColor(this.currentIndex===index?'#e16531':'#707070')
        .margin({top:20})
      Text(item.text)
        .fontSize(14)
        .fontColor(this.currentIndex===index?'#e16531':'#707070')
        .margin({top:20})
    }
  }
  build(){
    NavDestination(){
      Tabs({barPosition:BarPosition.End}){
        ForEach(this.tabData,(item:TabClass,index:number)=>{
          TabContent(){
            if(this.currentIndex===0){
              SOUY()
            }else if(this.currentIndex===1){
              WD()
            }
          }
          .tabBar( this.tabBuilder(item, index) )
          //.tabBar(this.tabBuilder(item,index))
          .backgroundColor('#F2F8FB')
          .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
        })

      }.onChange((index:number)=>{
        this.currentIndex=index
      })
      .backgroundColor('#FFFFFF')
      .scrollable(false)
      .animationDuration(0)
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
    } .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })

  }




}