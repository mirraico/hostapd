##README
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
#### 10月21号
##### 代码改进
使用driver api warpped函数以**不重启方式**修改SSID, 修复更换SSID后, WPA认证失败的问题
自定义SSID消息解析函数声明:
src/ap/ctrl_iface_ap.h
L27
自定义SSID消息解析函数实现:
src/ap/ctrl_iface_ap.c
L563-L572
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





