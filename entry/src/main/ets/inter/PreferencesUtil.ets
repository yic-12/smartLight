import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { TimerItem } from './Interface1';

export interface DeviceSettings {
  brightness: number;
  colorTemperature: number;
}

export class PreferencesUtil {
  private static readonly STORE_NAME: string = 'device_settings_store';
  private static readonly TIMER_STORE_NAME: string = 'timer_tasks_store';
  private static readonly KEY_BRIGHTNESS: string = 'brightness';
  private static readonly KEY_COLOR_TEMPERATURE: string = 'color_temperature';
  private static readonly KEY_TIMER_LIST: string = 'timer_list';

  static loadSettings(appContext: Context): DeviceSettings {
    const options: preferences.Options = { name: PreferencesUtil.STORE_NAME };
    const store = preferences.getPreferencesSync(appContext, options);
    const brightness = store.getSync(PreferencesUtil.KEY_BRIGHTNESS, 50) as number;
    const colorTemperature = store.getSync(PreferencesUtil.KEY_COLOR_TEMPERATURE, 50) as number;
    return { brightness, colorTemperature };
  }

  static saveSettings(appContext: Context, settings: DeviceSettings): void {
    const options: preferences.Options = { name: PreferencesUtil.STORE_NAME };
    const store = preferences.getPreferencesSync(appContext, options);
    store.putSync(PreferencesUtil.KEY_BRIGHTNESS, settings.brightness);
    store.putSync(PreferencesUtil.KEY_COLOR_TEMPERATURE, settings.colorTemperature);
    store.flushSync();
  }

  /**
   * 保存定时任务列表
   * @param appContext 应用上下文
   * @param timerList 定时任务列表
   */
  static saveTimerList(appContext: Context, timerList: TimerItem[]): void {
    try {
      const options: preferences.Options = { name: PreferencesUtil.TIMER_STORE_NAME };
      const store = preferences.getPreferencesSync(appContext, options);
      const timerListJson = JSON.stringify(timerList);
      store.putSync(PreferencesUtil.KEY_TIMER_LIST, timerListJson);
      store.flushSync();
    } catch (error) {
      console.error('保存定时任务列表失败:', error);
    }
  }

  /**
   * 加载定时任务列表
   * @param appContext 应用上下文
   * @returns 定时任务列表
   */
  static loadTimerList(appContext: Context): TimerItem[] {
    try {
      const options: preferences.Options = { name: PreferencesUtil.TIMER_STORE_NAME };
      const store = preferences.getPreferencesSync(appContext, options);
      const timerListJson = store.getSync(PreferencesUtil.KEY_TIMER_LIST, '[]') as string;
      const timerList = JSON.parse(timerListJson) as TimerItem[];
      return timerList || [];
    } catch (error) {
      console.error('加载定时任务列表失败:', error);
      return [];
    }
  }

  /**
   * 清空定时任务列表
   * @param appContext 应用上下文
   */
  static clearTimerList(appContext: Context): void {
    try {
      const options: preferences.Options = { name: PreferencesUtil.TIMER_STORE_NAME };
      const store = preferences.getPreferencesSync(appContext, options);
      store.deleteSync(PreferencesUtil.KEY_TIMER_LIST);
      store.flushSync();
    } catch (error) {
      console.error('清空定时任务列表失败:', error);
    }
  }
}