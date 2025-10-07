export interface Data1{
  project_id:string,
  timestamp:string
}

export interface Data2{
  timestamp: string;        // 请求时间戳，用于认证和防重放
  token: string;           // 认证令牌，基于时间戳和密钥生成
  control_sub_id: string;  // 控制的子设备ID（目标灯光设备ID）
  control_sub_state: string; // 设备控制状态：'0'=打开，'1'=关闭
  r_channel?: number;      // 红色通道值，可选参数
  g_channel?: number;      // 绿色通道值，可选参数
  b_channel?: number;      // 蓝色通道值，可选参数
  w_channel?: number;      // 白光通道值（亮度控制），可选参数
  y_channel?: number;      // 黄光通道值（色温控制），可选参数
  control_state?: string;  // 控制状态，可选参数
  type_uuid: string;       // 设备类型UUID
  lightness?: number;      // 亮度值，可选参数（与w_channel可能重复，取决于API设计）
}

export interface  SceneClass{
  text:string
  icon:ResourceStr
}

export interface ApiRequestData {
  scene?: string;
  device?: string;
  action?: string;
  timestamp: number;
}

/**
 * 定时任务项接口
 * 定义单个定时任务的完整信息
 */
export interface TimerItem {
  id: string;                    // 定时任务唯一标识符
  name: string;                  // 定时任务名称（如：早晨起床、晚上休息）
  time: string;                  // 执行时间，格式：HH:mm（如：07:00、23:00）
  enabled: boolean;              // 是否启用该定时任务
  repeat: number[];              // 重复周期数组，数字1-7代表周一到周日
  deviceId: string;              // 关联的设备ID
  action: '0' | '1';  // 定时动作：开灯或关灯
}
export interface colorRgb{
  r:number,
  g:number,
  b:number
}
export interface scenceRgb{
  scence:string,
  Rbg:colorRgb
  Brightness:number,
  temperature:number
}

