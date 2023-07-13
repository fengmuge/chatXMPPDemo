学习xmpp的练习之作

通过openfire+xmppframwork实现了单聊、群聊等功能

通过JSQMessagesViewController实现了聊天页面的UI

记录 一 2023-06-25

1 关于Roster状态问题： 

      1 为什么在fetchroster后不能获取到用户的状态，反而是在登录之后能够获取
      
      2 didReceivePresence回调的触发条件是什么
      
2 创建群之后的逻辑：

      1 判断群创建成功后，应跳转到聊天页面 
      
      2 应该根据广播配置，发送某种角色加入群聊的消息 
      
      3 应该添加群加入权限，密码提示等 
      
      4 添加展示各种角色的用户列表 
      
      5 添加群设置页面 
      
3 问题： 

     1 在群组长时间未活动，会导致自动离开群组 
     
     2 长时间未活动，再发送消息会导致异常断开socket连接 

记录 —— 2023-07-13

1 添加WebRTC

2 由于libWebRTC.a文件过大，所以保存在了百度网盘
       链接: https://pan.baidu.com/s/1KEwDMtZc4s50faKAgzKeKQ  密码: eu7m
