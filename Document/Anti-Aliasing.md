# Unreal Engine 抗锯齿方法（Anti-Aliasing Method）详解

## 作用
**抗锯齿（Anti-Aliasing, AA）** 用于减少或消除渲染图像中的锯齿（Aliasing），提升边缘平滑度和视觉质量。Unreal Engine 提供多种抗锯齿技术，适用于不同场景和性能需求。

---

## 支持的抗锯齿方法

| 方法       | 技术原理                                                                 | 优点                          | 缺点                          | 适用场景                     |
|------------|--------------------------------------------------------------------------|-------------------------------|-------------------------------|------------------------------|
| **None**   | 关闭抗锯齿                                                               | 零性能开销                    | 锯齿明显                      | 调试/像素风/性能测试         |
| **FXAA**   | 后处理模糊边缘（Fast Approximate AA）                                    | 低开销，兼容性强              | 画面变模糊                    | 低端设备/快速渲染            |
| **TAA**    | 基于多帧历史数据（Temporal AA）                                          | 动态场景效果好，支持超分辨率  | 可能产生鬼影（Ghosting）      | 现代3A游戏（默认推荐）       |
| **MSAA**   | 几何边缘多重采样（Multisample AA）                                       | 几何边缘锐利                  | 仅限前向渲染，高开销          | VR/前向渲染项目              |
| **TSAA**   | 混合TAA+SMAA（子像素形态抗锯齿）                                         | 比TAA更清晰，鬼影更少         | 计算量较高                    | 需要高清晰度的项目           |

---

## 参数调整建议
### 通用设置（`Project Settings > Rendering > Anti-Aliasing`）
- **TAA Sharpness**：提高可减少模糊（默认值0.2~0.5）。
- **TAA Sample Count**：增加采样提升质量（性能开销↑）。
- **FXAA Quality**：调整后处理强度（0~3，越高越平滑）。

### 针对不同平台
| 平台       | 推荐方法          | 附加优化                                  |
|------------|-------------------|-------------------------------------------|
| **PC/主机**| TAA + TSR         | 启用`Temporal Upscaling`提升分辨率        |
| **移动端** | FXAA 或 TAA Low   | 关闭`Motion Blur`降低开销                 |
| **VR**     | MSAA 4x/8x        | 前向渲染（Forward Shading）必需           |

---

## 常见问题
❓ **TAA鬼影严重怎么办？**  
➡️ 调整`TAA Velocity Scale`或使用`TAA Upsampling`优化动态物体。

❓ **FXAA太模糊？**  
➡️ 换用TSAA或降低`FXAA Quality`，同时增加屏幕分辨率。

❓ **MSAA无效？**  
➡️ 确认使用**前向渲染**（`Project Settings > Rendering > Forward Renderer`）。
