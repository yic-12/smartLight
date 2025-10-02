import { http } from "@kit.NetworkKit";
import { TokenGenerator } from "./MD5";

/**
 * 智能家居API客户端
 * 支持603教室局域网和校内网环境自动切换
 */
export class SmartHomeApi {
  private static instance: SmartHomeApi;
  
  // API基础地址
  private readonly LOCAL_BASE_URL = "http://192.168.2.170:8081";  // 603教室局域网
  private readonly CAMPUS_BASE_URL = "http://10.214.166.140:8081"; // 校内网
  
  private currentBaseUrl: string = this.LOCAL_BASE_URL;
  private isLocalNetwork: boolean = true;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): SmartHomeApi {
    if (!SmartHomeApi.instance) {
      SmartHomeApi.instance = new SmartHomeApi();
    }
    return SmartHomeApi.instance;
  }

  /**
   * 切换到局域网环境（603教室）
   */
  public useLocalNetwork(): void {
    this.currentBaseUrl = this.LOCAL_BASE_URL;
    this.isLocalNetwork = true;
    console.info("已切换到603教室局域网环境");
  }

  /**
   * 切换到校内网环境
   */
  public useCampusNetwork(): void {
    this.currentBaseUrl = this.CAMPUS_BASE_URL;
    this.isLocalNetwork = false;
    console.info("已切换到校内网环境");
  }

  /**
   * 获取当前网络环境信息
   */
  public getCurrentNetwork(): { baseUrl: string, isLocal: boolean, description: string } {
    return {
      baseUrl: this.currentBaseUrl,
      isLocal: this.isLocalNetwork,
      description: this.isLocalNetwork ? "603教室局域网" : "校内网"
    };
  }

  /**
   * 发送API请求
   */
  public async request<T = any>(
    path: string, 
    method: http.RequestMethod = http.RequestMethod.GET,
    data?: any
  ): Promise<T> {
    try {
      // 生成token
      const token = await TokenGenerator.generateToken();
      
      // 构建完整URL
      const url = `${this.currentBaseUrl}${path.startsWith('/') ? path : '/' + path}`;
      
      // 创建HTTP请求
      const httpRequest = http.createHttp();
      
      // 构建请求选项
      const options: http.HttpRequestOptions = {
        method: method,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': token  // 根据接口文档要求添加token字段
        },
        connectTimeout: 10000,
        readTimeout: 10000
      };

      // 如果有数据需要发送
      if (data && (method === http.RequestMethod.POST || method === http.RequestMethod.PUT)) {
        options.extraData = JSON.stringify(data);
      }

      console.info(`[SmartHome API] ${method} ${url}`);
      console.info(`[SmartHome API] Token: ${token}`);
      
      if (data) {
        console.info(`[SmartHome API] Data:`, JSON.stringify(data));
      }

      // 发送请求
      const response = await httpRequest.request(url, options);
      
      // 销毁请求对象
      httpRequest.destroy();

      console.info(`[SmartHome API] Response Code: ${response.responseCode}`);
      console.info(`[SmartHome API] Response:`, response.result);

      // 处理响应
      if (response.responseCode === 200) {
        try {
          return typeof response.result === 'string' 
            ? JSON.parse(response.result) 
            : response.result;
        } catch (parseError) {
          console.error('[SmartHome API] JSON解析失败:', parseError);
          return response.result as T;
        }
      } else {
        throw new Error(`HTTP请求失败: ${response.responseCode}`);
      }
    } catch (error) {
      console.error('[SmartHome API] 请求失败:', error);
      throw error;
    }
  }

  /**
   * GET请求
   */
  public async get<T = any>(path: string, params?: Record<string, any>): Promise<T> {
    let fullPath = path;
    if (params) {
      const queryString = Object.entries(params)
        .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
        .join('&');
      fullPath += `?${queryString}`;
    }
    return this.request<T>(fullPath, http.RequestMethod.GET);
  }

  /**
   * POST请求
   */
  public async post<T = any>(path: string, data?: any): Promise<T> {
    return this.request<T>(path, http.RequestMethod.POST, data);
  }

  /**
   * PUT请求
   */
  public async put<T = any>(path: string, data?: any): Promise<T> {
    return this.request<T>(path, http.RequestMethod.PUT, data);
  }

  /**
   * DELETE请求
   */
  public async delete<T = any>(path: string): Promise<T> {
    return this.request<T>(path, http.RequestMethod.DELETE);
  }

  /**
   * 测试网络连接
   */
  public async testConnection(): Promise<boolean> {
    try {
      // 可以根据实际API调整测试路径
      await this.get('/health');
      return true;
    } catch (error) {
      console.error(`[SmartHome API] 连接测试失败 (${this.getCurrentNetwork().description}):`, error);
      return false;
    }
  }

  /**
   * 自动切换网络环境
   * 如果当前环境连接失败，自动尝试另一个环境
   */
  public async autoSwitchNetwork(): Promise<boolean> {
    const currentIsLocal = this.isLocalNetwork;
    
    // 测试当前网络
    const currentWorks = await this.testConnection();
    if (currentWorks) {
      return true;
    }

    console.info('[SmartHome API] 当前网络环境连接失败，尝试切换...');
    
    // 切换到另一个网络环境
    if (currentIsLocal) {
      this.useCampusNetwork();
    } else {
      this.useLocalNetwork();
    }

    // 测试新环境
    const newWorks = await this.testConnection();
    if (newWorks) {
      console.info(`[SmartHome API] 网络环境切换成功: ${this.getCurrentNetwork().description}`);
      return true;
    } else {
      // 如果新环境也不行，切换回原来的环境
      if (currentIsLocal) {
        this.useLocalNetwork();
      } else {
        this.useCampusNetwork();
      }
      console.error('[SmartHome API] 所有网络环境都无法连接');
      return false;
    }
  }
}

/**
 * 获取智能家居API实例的便捷方法
 */
export function getSmartHomeApi(): SmartHomeApi {
  return SmartHomeApi.getInstance();
}
