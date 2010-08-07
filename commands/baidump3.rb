#!/usr/bin/env ruby
require 'autoweb/page' 
require 'iconv'

include Autoweb

Page.define "BaiduMp3" do |page|
  page.url_tpl = 'http://mp3.baidu.com/m?f=3&rf=idx&tn=baidump3&ct=134217728&lf=&rn=&word=#{word}&lm=-1&oq=go&rsp=1'
  
  page.subs "result", "#Tbs tr" do |sub|
    sub.ele "music", "td:nth(1) a"
    sub.ele "artist", "td:nth(2) a"
    sub.ele "album", "td:nth(3) a"
    sub.ele "lyrics", "td:nth(5) a"
    sub.ele "size", "td:nth(7)"
    sub.ele "format", "td:nth(8)"
  end
end

module Autoweb
  module Command

    class Baidump3 < Autoweb::Command::Base
      MEGABYTE = 1024.0 * 1024.0
      attr_accessor :dest_dir, :word
   
      def index
        @word = args[0]
        @dest_dir = args[1]
        
        if @word.nil?
          return usage
        end
        
        if @dest_dir
          if File.directory?(dest_dir)
            @dest_dir = File.expand_path(dest_dir)+"/"
          else
            error "#{@dest_dir} is not directory"
          end
        end
        
        search
      end
  
      def search 
        display("searching...")
        page = Page.pages["BaiduMp3"].parse(:word => word)
        result = page["result"][1]
        music_url = result["music"][:href]
        mp3url = decode open(URI.encode music_url).read[/var encurl = "([^"]*)"/,1]
        display2("ok, parsing mp3...")
        #size = `curl -I #{mp3url} 2>/dev/null`[/Content-Length:\ (\d+)/,1]
        #display2(", size: %.2fM. " % (Integer(size)/MEGABYTE))
        confirm("sure to download?") do
          download_mp3(mp3url, word, result["format"].innerText)
        end
      end
  
      def usage
        display "usage: autoweb mp3search MUSIC_NAME"
      end
  
      def download_mp3(url, word, format)
        `wget #{url} -O #{dest_dir}#{word.gsub(/[\+|\ |_]/, "-")}.#{format}`
      end
  
      def decode(s)  
        s.tr(_mktab(s[0].chr), s=~ /....:\// ? _mktab('h') : _mktab('f')) #http|ftp  
      end

      def _mktab(x)  
        t0 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"  
        p = t0.partition(x)  
        p[1] + p[2] + p[0]  
      end
  
    end
  end
end