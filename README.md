## README

---

#### 11月9号

**重新设计hostapd启动入口函数**

将启动入口函数改为start_hostapd(const char *config_dir);

新函数需要指定配置文件的路径

调用方法：#include "starthostapd.h"

**下一步**

补齐所有配置文件中设计到的参数更改

---
#### 10月28号
##### 启动封装
将hostapd启动的main入口函数重新封装, 新的入口函数名称为

```start_hostapd_daemon(struct hostapd_simple_config *s_conf);```

hostapd启动方式改为直接启动, ./hostapd无需跟配置文件路径

##### 程序问题

* 目前支持的配置还很少
```
struct hostapd_simple_config {
    char *ssid;
    char *wlan_interface;
    char *wpa_passphrase;
    char *wpa_key_mgmt;
    char *wpa_pairwise;
    char *rsn_pairwise;
    char *ctrl_interface;
    char *hw_mode;
    int channel;
    int wpa;
    int auth_algs;
};
```
* 程序**Bug**: 加上wpa认证配置后, wifi将无法接入设备, 设备连接错误提示为**密码错误**.

##### 下一步
**解决bug**, **完善**配置参数.

---

#### 10月22号
##### 代码改进
之前代码存在修改ssid后, 旧的信标没有被移除,使用wifi-analyzer可以看到旧的ssid同样存在.
**停止信标发送,删除旧信标**: ctrl_iface_ap.c(L569-L573)

**重建信标帧并发送**: ctrl_iface_ap.c(L575-579)

**新的channel代码**: ctrl_iface_ap.c(L588-L615)

思路和ssid一样, 就是通过重建信标帧实现.

##### 启动脚本
![image_1avlkheou6ab18no1nc41efr1i6a9.png-3.4kB][1]

加上-dd参数打印所有调试信息方便测试, 不需要可以将-dd去掉.默认启动将不打印调试信息.

---
#### 10月21号
##### 代码改进
使用driver api warpped函数以**不重启方式**修改SSID, 修复更换SSID后, WPA认证失败的问题

自定义SSID消息解析函数声明:

src/ap/ctrl_iface_ap.h(L27)

自定义SSID消息解析函数实现:

src/ap/ctrl_iface_ap.c(L563-L572)

#### 启动脚本

增加了启动脚本starthostapd.sh
```sh
SYS_LOG_MODULES=-1
SYS_LOG_LEVEL=4
STDOUT_LOG_MODULES=-1
STDOUT_LOG_LEVEL=2

DHCP server Configuration(user configuration)
WLAN_IFACE_NAME="wlx14cf92afb710"
LAN_IFACE_NAME="ens33"
NETWORK_ADDRESS="10.10.50.0/24"
LISTEN_ADDRESS="10.10.50.1"
DHCP_RANGE="10.10.50.128,10.10.50.254,255.255.255.0,12h"
DHCP_OPTION="3,10.10.50.1"
DHCP_OPTION2="6,8.8.8.8"
```
以上参数可自定义, 启动脚本后将会检查系统环境, 安装确实组件, 同时在指定接口上启动dhcp和nat功能.

---
#### 10月14号
该程序修改了hostapd_cli和hostapd程序部分源码，完成了通过cli修改hostapd的SSID的功能

modified:   hostapd/ctrl_iface.c 

modified:   hostapd/hostapd_cli.c  

modified:   src/ap/ctrl_iface_ap.c  

modified:   src/ap/ctrl_iface_ap.h

**下一步**
请关注以下文件及行数并尝试模仿出不重启AP的情况下修改信道的功能：  

hostapd_cli.c    	

1161 1089-1100 227-230 195-224行  

这一部分自定义SSID消息的封装和发送部分   

ctrl_iface.c		

2280-2282行   

这一部分自定义SSID消息的接收及解析部分  

ctrl_iface_ap.c	 

558-580行   

这一部分自定义SSID消息的应用部分，此处使用的是先disable再修改SSID再enable，杨老师让我们关注可不可以不disable再enable的情况下（也就是不重启AP）直接修改诸如信道的参数

---


[1]: http://static.zybuluo.com/sammyyx/4yfv5rnglzjqzpm48g2lf68e/image_1avlkheou6ab18no1nc41efr1i6a9.png