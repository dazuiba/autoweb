# Welcome to Autoweb

1. [Autoweb][homepage]能让更好地分析HTML中的数据
 	 你可以先使用Autoweb提供的DSL,针对HTML建模, 然后抓取数据
2. 它能把你写的抓取程序分享出来, 他人可以通过命令行或者web界面使用

### 集成进来的工具
1. baidu mp3 下载器
 
使用举例:

下载 齐秦的大约在冬季, 在命令行输入:

	autoweb baidump3 "大约在冬季 齐秦" ~/Download/mp3

autoweb会自动搜索歌曲, 然后下载到指定的目录


## Install Autoweb

安装前需要安装以下工具:

  * curl
  * wget
  * hpricot

然后安装autoweb

  gem install autoweb


## Contributing

### 页面建模 
用到了css3作为页面元素定位语法, 参照: [css3语法介绍][w3c-css3-selector]

	Page.define "BaiduMp3" do |page|
    
    # 搜索url模板
		page.url_tpl = 'http://mp3.baidu.com/m?f=3&rf=idx&tn=baidump3&ct=134217728&lf=&rn=&word=#{word}&lm=-1&oq=go&rsp=1'
		
		page.subs "result", "#Tbs tr" do |sub| # 定义名为"result"的"sub page"

			sub.ele "music", "td:nth(1) a"  #音乐链接
			sub.ele "artist", "td:nth(2) a" #演唱者
			sub.ele "album", "td:nth(3) a"  #专辑
			sub.ele "lyrics", "td:nth(5) a" #歌词
			sub.ele "size", "td:nth(7)"     #文件大小
			sub.ele "format", "td:nth(8)"   #文件格式
		end
	end

使用页面对象:
 
	page = Page.pages["BaiduMp3"].parse(:word=>"大约在冬季")
	first_mp3 = page["result"][1]
	link = first_mp3["music"]
	puts link[:href]

更多实际代码, 参考 [commands/baidump3.rb][baidump3-code] 

### 新建一个命令(和baidump3类似)

将以下代码放到autoweb/commands/helloworld.rb下

	module Autoweb::Command
		class HelloWorld < Base  
			def index
				display "hello world!"
			end
		end
	end

直接运行 autoweb helloworld 即可

更多实际代码, 参考 [commands/help.rb][help-code] 和 [commands/baidump3.rb][baidump3-code] 

### 将代码提交到[autoweb][homepage]

   请直接fork github上的autoweb, 提交ticket以及push request即可

## License

Autoweb released under the MIT license.

[homepage]:http://dazuiba.github.com/autoweb
[w3c-css3-selector]:http://wiki.github.com/mxcl/homebrew/installation
[baidump3-code]:http://github.com/dazuiba/autoweb/blob/master/commands/baidump3.rb
[help-code]:http://github.com/dazuiba/autoweb/blob/master/commands/help.rb


