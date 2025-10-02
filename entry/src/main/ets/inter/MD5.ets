import { cryptoFramework } from "@kit.CryptoArchitectureKit";
import util from "@ohos.util";

/**
 * Token生成器类
 * 使用MD5加密算法生成智能家居API所需的token
 * 生成公式: MD5(timestamp + key)
 * 其中 key = "2023GSD_smart_home%$Sd"
 */
export class TokenGenerator {
  private static readonly SECRET_KEY: string = "2023GSD_smart_home%$Sd";

  /**
   * 生成API请求token
   * @returns Promise<string> 生成的MD5 token
   */
  static async generateToken(): Promise<string> {
    try {
      // 获取当前时间戳
      const timestamp: number = Date.now();
      
      // 拼接时间戳和密钥
      const rawStr: string = `${timestamp}${TokenGenerator.SECRET_KEY}`;
      
      console.info(`[TokenGenerator] 原始字符串: ${rawStr}`);

      // 使用标准编码方式将字符串转换为字节数组
      const encodedData: Uint8Array = new util.TextEncoder().encodeInto(rawStr);

      // 创建MD5摘要算法实例
      const md5 = cryptoFramework.createMd("MD5");
      
      // 更新摘要数据
      await md5.update({ data: encodedData });

      // 计算MD5摘要
      const md5Result = await md5.digest();
      
      // 将结果转换为十六进制字符串
      const hexToken = TokenGenerator.dataBlobToHex(md5Result);
      
      console.info(`[TokenGenerator] 生成的Token: ${hexToken}`);
      
      return hexToken;
    } catch (error) {
      console.error("[TokenGenerator] Token生成失败：", error);
      throw new Error(`Token生成失败: ${error}`);
    }
  }

  /**
   * 将DataBlob转换为十六进制字符串
   * @param blob cryptoFramework.DataBlob 数据块
   * @returns string 十六进制字符串
   */
  private static dataBlobToHex(blob: cryptoFramework.DataBlob): string {
    return Array.from(blob.data)
      .map(byte => byte.toString(16).padStart(2, "0"))
      .join("");
  }

  /**
   * 获取当前时间戳
   * @returns number 当前时间戳
   */
  static getCurrentTimestamp(): number {
    return Date.now();
  }

  /**
   * 获取密钥
   * @returns string 密钥字符串
   */
  static getSecretKey(): string {
    return TokenGenerator.SECRET_KEY;
  }

  /**
   * 验证token格式是否正确（32位十六进制字符串）
   * @param token 要验证的token
   * @returns boolean 是否为有效的MD5格式
   */
  static isValidTokenFormat(token: string): boolean {
    const md5Regex = /^[a-f0-9]{32}$/i;
    return md5Regex.test(token);
  }
}
