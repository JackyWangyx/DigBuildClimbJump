-- [💻 其他 UI 命名规范]

-- MainFrame : 所有页面的根节点为一个全屏的 Frame，用于查找 UI 根节点并处理缩放动画
-- Toggle_Name_True : 指定名字 bool 类型的值如果为 true，则名称后缀为 True 的会打开，False 的会关闭，反之亦然
-- Image_Name : Name 属性对应的值会作为资源路径加载图片并赋值给图片组件
-- Image_FillAmount_Name : 百分比填充
-- Button_FunctionName : 按钮自动绑定到对应功能代码中指定的函数名
-- Button / Tooltip : 按钮子节点中的 Tooltip 节点，会在鼠标进入和离开时自动打开和关闭显示提示
-- Enum_EnumName_EnumValue : 枚举，匹配枚举名字和枚举值自动开关对应节点

-- [⏹ 特殊命名]

-- Button_Close : 固定为关闭 当前UI界面 的按钮
-- Button_ProductKey_DevelopProduct : 开发者商品 购买按钮
-- Button_ProductKey_GamePass : GamePass 购买按钮
-- Button_ProductKey_NewbiePack : 特殊 DevelopProduct, 对应发放奖励为 RewardPackage 一次性购买的礼包
-- Toggle_Purchased : GamePsss / NewbiePack 购买按钮中的子节点，表示已购买

-- Text_Account_Coin : 账户金币余额
-- Text_Property_Power : 当前总 Power

-- [⏹ UI 效果]

-- 直接将需要效果的对象，命名成指定效果名称即可。

-- UIEffect_Rotate
-- UIEffect_Scale
-- UIEffect_Shake
-- UIEffect_Float
-- UIEffect_Bounce