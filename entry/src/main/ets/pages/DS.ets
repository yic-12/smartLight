// 跳转页面入口函数
import {  httpGet ,httpPost} from "../inter/SmartHomeApi";
import { http } from "@kit.NetworkKit";
import { TokenGenerator } from "../inter/MD5";
import { Data1,Data2,TimerItem } from "../inter/Interface1";
import EntryAbility from "../entryability/EntryAbility"
import { Context } from '@kit.AbilityKit'
import { HttpUtil } from "../inter/HttpUtil";
import { PreferencesUtil } from "../inter/PreferencesUtil";
@Builder
export function DSBuilder() {
  DS();
}
@Entry
@Component
export struct DS {
  pathStack: NavPathStack = new NavPathStack();
  URL = "http://192.168.2.170:8081";
  timestamp: string = Date.now().toString()
  url1="/SmartHome/ShenDaRest/getLights"
  url2='/SmartHome/ShenDaRest/controlLight'
  httpRequest =http.createHttp()
  context: Context = getContext(this) as Context;
  @State data1:Data1={
    project_id: '',
    timestamp : ''
  }
  @State data2:Data2={
    timestamp: '',        // 请求时间戳，用于认证和防重放
    token: '',          // 认证令牌，基于时间戳和密钥生成
    control_sub_id:'',  // 控制的子设备ID（目标灯光设备ID）
    control_sub_state: '', // 设备控制状态：'0'=打开，'1'=关闭
    r_channel : 1,      // 红色通道值，可选参数
    g_channel : 1,      // 绿色通道值，可选参数
    b_channel : 1,      // 蓝色通道值，可选参数
    w_channel : 1,      // 白光通道值（亮度控制），可选参数
    y_channel : 1,      // 黄光通道值（色温控制），可选参数
    control_state : '',  // 控制状态，可选参数
    type_uuid: '',       // 设备类型UUID
    lightness : 1,      // 亮度值，可选参数（与w_channel可能重复，取决于API设计）
  }
  @State timerList: TimerItem[] = [];

  @State isAdding: boolean = false;              // 是否处于添加新定时任务模式
  @State newTimerName: string = '';              // 新定时任务名称
  @State selectedTime: string = '08:00';         // 选中的时间
  @State selectedTimeIndex: number = 480;        // 选中的时间索引（8:00对应的分钟数）
  @State selectedDevice: string = 'light_001';   // 当前选中的设备ID
  @State selectedAction: '0' | '1' = '0';        // 选中的动作
  //@State deviceList: LightDevice[] = [];         // 设备列表
  @State showDeleteDialog: boolean = false;      // 显示删除确认对话框
  @State deletingTimerId: string = '';           // 正在删除的定时任务ID
  @State deletingTimerName: string = '';         // 正在删除的定时任务名称
  @State currentBrightness: number = 50
  @State currentColorTemperature: number = 50
  private scheduleIntervalId: number | undefined = undefined
  private lastTriggeredKey: string | undefined = undefined

  /**
   * 加载定时任务数据
   */
  async loadTimerData() {
    try {
      const savedTimerList = PreferencesUtil.loadTimerList(this.context);
      this.timerList = savedTimerList;
    } catch (error) {
      console.error('加载定时任务数据失败:', error);
    }
  }

  /**
   * 保存定时任务数据
   */
  async saveTimerData() {
    try {
      PreferencesUtil.saveTimerList(this.context, this.timerList);
    } catch (error) {
      console.error('保存定时任务数据失败:', error);
    }
  }

  async setBrightness(value1: number,value2:number,value3:string) {
    await HttpUtil.getInstance().setLightBrightness(`${this.URL}${this.url2}`, value1,value2,value3)
    console.log('测试定时')
  }
  build() {
    NavDestination() {
      Column(){
        Column(){
          Text("定时功能")
            .fontSize(23)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Blue)
        }.margin({bottom:10})

        // 主要内容区域：根据模式显示列表或添加表单
        Column() {
          if (this.isAdding) {
            this.BuildAddTimerView();  // 添加定时任务视图
          } else {
            this.BuildTimerListView();  // 定时任务列表视图
          }
        }
        .width('100%')
        .layoutWeight(1)  // 占据剩余空间

        // 圆形添加按钮 × 位于中下方
        if (!this.isAdding) {
          Row() {
            Blank()  // 左侧占位
            // 圆形+号按钮
            Button() {
              Text('+')
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
            }
            .width(60)
            .height(60)
            .backgroundColor('#e16531')  // 主题橙色
            .borderRadius(30)  // 圆形按钮
            .onClick(() => {
              this.isAdding = true;  // 进入添加模式
              this.newTimerName = '';  // 重置名称
              this.selectedTime = '08:00';  // 重置时间为默认值
              this.selectedTimeIndex = 480;  // 8:00对应的分钟数
              this.selectedAction = '0';  // 默认开灯动作
            })
            Blank()  // 右侧占位
          }
          .width('100%')
          .margin({ top: 20, bottom: 10 })
        }

      }
      .width('100%')
      .height('100%')
      .padding(20)


      // 删除确认对话框
      if (this.showDeleteDialog) {
        this.BuildDeleteDialog();
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      // 页面准备就绪时加载定时任务数据
      this.loadTimerData();
      // 启动分钟级调度器
      this.startScheduler();
    }).backgroundColor('#F2F8FB')
  }
  /**
   * 构建定时任务列表视图
   * 显示所有定时任务的列表或空状态
   */
  @Builder
  BuildTimerListView() {
    Column() {
      if (this.timerList.length === 0) {
        // 空状态：显示图标和提示文字
        Column() {
          Image($r('app.media.dinshi'))  // 定时功能图标
            .width(100)
            .height(100)
            .margin({ bottom: 20 })
          Text('暂无定时任务')
            .fontSize(16)
            .fontColor('#999')
          Text('点击下方"+"按钮创建定时任务')
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 10 })
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)  // 居中显示
      } else {
        // 定时任务列表
        List({ space: 10 }) {
          ForEach(this.timerList, (item: TimerItem) => {
            ListItem() {
              this.BuildTimerItem(item);  // 构建单个定时任务项
            }
          }, (item: TimerItem) => item.id)  // 使用id作为key
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 启动调度器：每分钟检查一次是否需要执行定时动作
   */
  startScheduler() {
    // 先清理旧的
    if (this.scheduleIntervalId !== undefined) {
      clearInterval(this.scheduleIntervalId as number)
    }
    // 对齐到下一个整分钟开始，再每分钟执行一次
    const now = new Date()
    const msToNextMinute = (60 - now.getSeconds()) * 1000 - now.getMilliseconds()
    setTimeout(() => {
      this.checkAndRunTimers()
      const id = setInterval(() => {
        this.checkAndRunTimers()
      }, 60 * 1000)
      this.scheduleIntervalId = id as number
    }, Math.max(0, msToNextMinute))
  }

  /**
   * 检查并执行符合条件的定时任务
   */
  async checkAndRunTimers() {
    if (!this.timerList || this.timerList.length === 0) {
      return
    }
    const now = new Date()
    const hh = now.getHours().toString().padStart(2, '0')
    const mm = now.getMinutes().toString().padStart(2, '0')
    const currentTime = `${hh}:${mm}`
    // OpenHarmony 周一=1 ... 周日=7
    const day = ((now.getDay() + 6) % 7) + 1

    for (const item of this.timerList) {
      if (!item.enabled) continue
      if (item.time !== currentTime) continue
      if (item.repeat && item.repeat.length > 0 && !item.repeat.includes(day)) continue

      const triggerKey = `${item.id}-${currentTime}`
      if (this.lastTriggeredKey === triggerKey) {
        // 本分钟已执行过，避免重复触发
        continue
      }

      this.lastTriggeredKey = triggerKey

      // 执行动作：'0'开灯，'1'关灯
      try {
        const brightness = this.currentBrightness
        const colorTemp = this.currentColorTemperature
        await this.setBrightness(brightness, colorTemp, item.action)
        // 执行完成后自动关闭该定时任务开关（Toggle 置为关）
        item.enabled = false
        await this.saveTimerData()
      } catch (e) {
        console.error('定时执行失败:', e)
      }
    }
  }
  /**
   * 构建单个定时任务项
   * 显示定时任务的详细信息和控制开关
   */
  @Builder
  BuildTimerItem(item: TimerItem) {
    Column() {
      // 第一行：任务名称、时间和开关
      Row() {
        Column() {
          // 任务名称和动作图标
          Row({ space: 8 }) {
            // 动作状态指示器
            Text(this.getActionSymbol(item.action))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getActionColor(item.action))

            Text(item.name)  // 任务名称
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2c2c2c')
          }
          .alignItems(VerticalAlign.Center)

          // 时间、重复周期和动作描述
          Text(`${item.time} • ${this.getRepeatText(item.repeat)} • ${this.getActionText(item.action)}`)
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 5 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)  // 占据左侧空间

        // 右侧操作区域：开关和删除按钮
        Row({ space: 10 }) {
          // 启用/禁用开关
          Toggle({ type: ToggleType.Switch, isOn: item.enabled })
            .onChange(async (value: boolean) => {
              item.enabled = value;  // 更新启用状态
              if(item.enabled){
                this.setBrightness(this.currentBrightness,this.currentColorTemperature,this.selectedAction)
              }else{
                this.setBrightness(this.currentBrightness,this.currentColorTemperature,this.selectedAction='1')
              }
              await this.saveTimerData();  // 保存到持久化存储
            })

          // 删除按钮 乘 圆形红色背景的减号
          Button() {
            Text('×')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
          .width(36)
          .height(36)
          .backgroundColor('#FF6B6B')  // 红色背景
          .borderRadius(18)  // 圆形按钮
          .onClick(() => {
            this.showDeleteConfirmation(item.id, item.name);  // 显示删除确认
          })
        }
        .alignItems(VerticalAlign.Center)
      }

      // 第二行：关联设备信息
      /* Text('设备: ' + this.getDeviceName(item.deviceId))
           .fontSize(12)
           .fontColor('#999')
           .alignSelf(ItemAlign.Start)
           .margin({ top: 8 })*/
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)  // 白色背景卡片
    .borderRadius(15)  // 圆角边框
  }
  /**
   * 构建删除确认对话框
   */
  @Builder
  BuildDeleteDialog() {
    // 半透明背景层
    Column() {
      // 对话框内容
      Column() {
        // 对话框标题
        Text('删除定时任务')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2c2c2c')
          .margin({ bottom: 10 })

        // 确认消息
        Text(`确定要删除"${this.deletingTimerName}"吗？`)
          .fontSize(16)
          .fontColor('#666')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 20 })

        // 操作按钮
        Row({ space: 15 }) {
          Button('取消')
            .layoutWeight(1)
            .backgroundColor('#F0F0F0')
            .fontColor(Color.Black)
            .borderRadius(20)
            .height(45)
            .onClick(() => {
              this.showDeleteDialog = false;  // 关闭对话框
            })

          Button('删除')
            .layoutWeight(1)
            .backgroundColor('#FF6B6B')  // 红色删除按钮
            .fontColor(Color.White)
            .borderRadius(20)
            .height(45)
            .onClick(() => {
              this.deleteTimer(this.deletingTimerId);  // 执行删除
              this.showDeleteDialog = false;  // 关闭对话框
            })
        }
        .width('100%')
      }
      .width('80%')
      .padding(25)
      .backgroundColor(Color.White)
      .borderRadius(20)
      .shadow({ radius: 20, color: '#1A000000', offsetX: 0, offsetY: 5 })  // 添加阴影效果
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#80000000')  // 半透明黑色背景
    .position({ x: 0, y: 0 })  // 覆盖整个页面
  }
  /**
   * 构建添加定时任务视图
   * 提供表单用于创建新的定时任务
   */
  @Builder
  BuildAddTimerView() {
    Column() {
      Text('新建定时')  // 表单标题
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2c2c2c')
        .margin({ bottom: 20 })

      // 定时名称输入区域
      Column() {
        Text('定时名称')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })
        TextInput({ placeholder: '输入定时任务名称', text: this.newTimerName })
          .onChange((value: string) => {
            this.newTimerName = value;  // 更新定时任务名称
          })
      }
      .width('100%')
      .padding(15)
      .backgroundColor(Color.White)
      .borderRadius(15)
      .margin({ bottom: 15 })

      // 动作选择区域
      Column() {
        Text('定时动作')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        // 动作选择按钮组
        Row({ space: 10 }) {
          Button('打开灯光')
            .backgroundColor(this.selectedAction === '0' ? '#e16531' : '#F0F0F0')
            .fontColor(this.selectedAction === '0' ? Color.White : Color.Black)
            .borderRadius(20)
            .padding(10)
            .layoutWeight(1)
            .onClick(() => {
              this.selectedAction = '0';  // 选择开灯动作
            })

          Button('关闭灯光')
            .backgroundColor(this.selectedAction === '1' ? '#e16531' : '#F0F0F0')
            .fontColor(this.selectedAction === '1' ? Color.White : Color.Black)
            .borderRadius(20)
            .padding(10)
            .layoutWeight(1)
            .onClick(() => {
              this.selectedAction = '1';  // 选择关灯动作
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(15)
      .backgroundColor(Color.White)
      .borderRadius(15)
      .margin({ bottom: 15 })

      // 执行时间选择区域 - 使用滑动选择器
      Column() {
        Text('执行时间')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        // 当前选中时间显示
        Text(this.selectedTime)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#e16531')
          .margin({ bottom: 15 })

        // 滑动时间选择器
        Column() {
          // 时间刻度滑块 + 加减1分钟按钮
          Row({ space: 10 }) {
            Button('-1')
              .borderRadius(14)
              .height(28)
              .padding({ left: 10, right: 10 })
              .backgroundColor('#F0F0F0')
              .fontColor(Color.Black)
              .onClick(() => {
                if (this.selectedTimeIndex > 0) {
                  this.selectedTimeIndex = this.selectedTimeIndex - 1;
                  this.updateSelectedTime();
                }
              })

            Slider({
              value: this.selectedTimeIndex,
              min: 0,
              max: 1439,
              step: 1,
              style: SliderStyle.OutSet
            })
              .layoutWeight(1)
              .onChange((value: number) => {
                this.selectedTimeIndex = value;
                this.updateSelectedTime();
              })

            Button('+1')
              .borderRadius(14)
              .height(28)
              .padding({ left: 10, right: 10 })
              .backgroundColor('#F0F0F0')
              .fontColor(Color.Black)
              .onClick(() => {
                if (this.selectedTimeIndex < 1439) {
                  this.selectedTimeIndex = this.selectedTimeIndex + 1;
                  this.updateSelectedTime();
                }
              })
          }
          .width('100%')

          // 时间刻度标签
          Row() {
            Text('00:00')
              .fontSize(12)
              .fontColor('#999')
            Blank()
            Text('12:00')
              .fontSize(12)
              .fontColor('#999')
            Blank()
            Text('23:59')
              .fontSize(12)
              .fontColor('#999')
          }
          .width('100%')
          .margin({ top: 10 })
        }
        .width('100%')
      }
      .width('100%')
      .padding(15)
      .backgroundColor(Color.White)
      .borderRadius(15)
      .margin({ bottom: 15 })

      // 设备选择区域
      /*   Column() {
           Text('选择设备')
             .fontSize(14)
             .fontWeight(FontWeight.Medium)
             .alignSelf(ItemAlign.Start)
             .margin({ bottom: 8 })

           // 设备按钮列表
           Row({ space: 10 }) {
             ForEach(this.deviceList, (device: LightDevice) => {
               Button(device.deviceName)
                 .backgroundColor(this.selectedDevice === device.deviceId ? '#e16531' : '#F0F0F0')  // 选中状态高亮
                 .fontColor(this.selectedDevice === device.deviceId ? Color.White : Color.Black)
                 .borderRadius(20)
                 .padding(10)
                 .onClick(() => {
                   this.selectedDevice = device.deviceId;  // 更新选中的设备
                 })
             })
           }
           .width('100%')
         }
         .width('100%')
         .padding(15)
         .backgroundColor(Color.White)
         .borderRadius(15)
         .margin({ bottom: 20 })
   */
      // 操作按钮：取消和保存
      Row({ space: 15 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F0F0F0')  // 灰色取消按钮
          .fontColor(Color.Black)
          .borderRadius(20)
          .onClick(() => {
            this.isAdding = false;  // 退出添加模式
          })

        Button('保存')
          .layoutWeight(1)
          .backgroundColor('#e16531')  // 橙色保存按钮
          .fontColor(Color.White)
          .borderRadius(20)
          .onClick(() => {
            this.saveNewTimer();  // 保存新定时任务
          })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
  /**
   * 根据滑块值更新选中时间
   */
  updateSelectedTime() {
    const totalMinutes = this.selectedTimeIndex;
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;

    const hourStr = hours.toString().padStart(2, '0');
    const minuteStr = minutes.toString().padStart(2, '0');

    this.selectedTime = `${hourStr}:${minuteStr}`;
  }
  /**
   * 保存新定时任务
   * 验证输入并添加到定时任务列表
   */
  async saveNewTimer() {
    // 验证定时任务名称不能为空
    if (!this.newTimerName.trim()) {
      return;
    }

    // 创建新的定时任务对象
    const newTimer: TimerItem = {
      id: Date.now().toString(),  // 使用时间戳作为唯一ID
      name: this.newTimerName,
      time: this.selectedTime,
      enabled: true,  // 默认启用
      repeat: [1,2,3,4,5,6,7],  // 默认每天重复
      deviceId: this.selectedDevice,
      action: this.selectedAction  // 保存选择的动作
    };

    // 添加到列表
    this.timerList.push(newTimer);

    // 保存到持久化存储
    await this.saveTimerData();

    // 退出添加模式
    this.isAdding = false;
  }
  /**
   * 显示删除确认对话框
   */
  showDeleteConfirmation(timerId: string, timerName: string) {
    this.deletingTimerId = timerId;
    this.deletingTimerName = timerName;
    this.showDeleteDialog = true;
  }

  /**
   * 删除定时任务
   */
  async deleteTimer(timerId: string) {
    // 从列表中移除指定ID的定时任务
    this.timerList = this.timerList.filter(item => item.id !== timerId);

    // 保存更新后的列表到持久化存储
    await this.saveTimerData();

    // 重置删除状态
    this.deletingTimerId = '';
    this.deletingTimerName = '';
  }

  /**
   * 获取动作对应的符号
   */
  getActionSymbol(action: '0' | '1'): string {
    return action === '0' ? '●' : '○';
  }

  /**
   * 获取动作对应的颜色
   */
  getActionColor(action: '0' | '1'): Color {
    return action === '0' ? Color.Green : Color.Red;
  }

  /**
   * 获取动作描述文本
   */
  getActionText(action: '0' | '1'): string {
    return action === '0' ? '开灯' : '关灯';
  }

  /**
   * 获取重复周期的文本描述
   * 将数字数组转换为用户友好的文本
   */
  getRepeatText(repeat: number[]): string {
    if (repeat.length === 7) return '每天';  // 包含所有7天
    if (repeat.length === 5 && !repeat.includes(6) && !repeat.includes(7)) return '工作日';  // 周一到周五
    return '自定义';  // 其他组合
  }


}