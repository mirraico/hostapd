####简介 
该程序修改了hostapd_cli和hostapd程序部分源码，完成了通过cli修改hostapd的SSID的功能  
modified:   hostapd/ctrl_iface.c  
modified:   hostapd/hostapd_cli.c  
modified:   src/ap/ctrl_iface_ap.c  
modified:   src/ap/ctrl_iface_ap.h  


####使用 
编译完成后先运行hostapd程序，在hostapd程序运行时运行hostapd_cli程序，格式：
./hostapd_cli ssid "new_ssid"

####下一步 
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
