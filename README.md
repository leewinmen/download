一些静态网页



#### 群晖使用shell实现IPV6的ddns外网访问



本脚本的工作流程是：对比云端解析记录-> 不存在则添加 -> 存在则更新。

##### 使用方法

```
1、首先，登录阿里控制台，获取AccessKey（没有则创建）；
2、然后，打开aliddns.sh脚本，在Setting里设置AccessKey，如下：
                access_key_id=""
                access_key_secret=""
                
2.1 chmod +x aliddns.sh（选填）

3、最后，执行aliddns.sh脚本，如：

./aliddns.sh [OPTION] <String>
         
Options:
 -d, --domain    域名 (必需参数)
 -h, --host    主机记录, 默认为: @
 -t, --type    记录类型, 默认为: A，候选有：A, AAAA, CNAME, MX, REDIRECT_URL, FORWARD_URL ...
 -v, --value   记录值, 默认为:自动获取的公网IPv4地址，其他类型可以自由设置
 -l, --ttl     TTL, 默认为: 600s，免费用户固定为600秒，付费用户可以设置其他值。
        
eg：
  --在example.com下，创建或更新两条记录：@、www [ IPv4 ]
 ./aliddns.sh -d example.com -h @ -h www
             
  --在example.com下，创建或更新两条记录：@、www [ IPv6 ]
 ./aliddns.sh -d darler.cn -h dsm -t AAAA -v 240e:3b4:483:ead0:211:32ff:fee9:e278
           
 --将所有域名*.example.com都指向二级域名abc.sample.com，同时指定TTL为60秒
 ./aliddns.sh -d example.com -h \* -t CNAME -v abc.sample.com -l 60
```



##### 纯代码演示


```
cd /root
mkdir ddns && cd ddns
wget https://raw.githubusercontent.com/leewinmen/download/master/aliddns.sh

vi aliddns.sh #修改如下信息
i #编辑
            access_key_id=""
            access_key_secret=""
:wq  #保存

chmod +x aliddns.sh
./aliddns.sh -d example.com -h @ -h www

crontab -e
添加一行
*/5 * * * * /bin/bash /root/ddns/aliddns.sh -d example.com -h @ -h www
:wq
```

 

##### **群晖设置自定义脚本** 

```
1.进入“控制面板” 找到“计划任务”，点击点击 新增>计划任务>用户定义的脚本，新建一个计划任务。 
2.“常规”选项可以修改一下任务名称，也可以默认不动。
3.“计划”选项设置“每天运行”，运行频率“每隔10分种”。
4."任务设置" 选项，用户定义的脚本框内填入我们前面复制保存的aliddns.sh的路径。
/root/ddns/aliddns.sh -d darler.cn -h dsm -t AAAA -v 240e:3b4:483:ead0:211:32ff:fee9:e278
```





##### 自动循环方法2

获取脚本文件，之后在`#!/bin/sh`后面加上如下两行：

```
while true
do
```

然后在代码的结尾处加上两行：

```
sleep 300
done
```

作用就是无限循环，执行完成这个脚本后，调用sleep睡眠300秒 (间隔自行决定)，之后重新开始循环 (再次更新DDNS)

之后保存退出，使用如下命令行启动：

```
nohup /root/ddns/aliddns.sh >/dev/null 2>&1 &
```

