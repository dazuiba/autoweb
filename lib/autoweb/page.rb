#!/usr/bin/env ruby
require "ostruct"
require "open-uri"
require "hpricot"
module Autoweb
  module Container
    attr_reader :name,  :sub_pages, :elements

    def subs(name,sub_css,&block)
     def_sub(name, sub_css, true, &block)
    end

    def sub(name,sub_css,&block)
     def_sub(name, sub_css, false, &block)
    end  

    def ele(name, css)
      @elements[name] = Element.new(self,name,css)
    end

    private

    def def_sub(name, sub_css, is_array, &block)
      sub = SubPage.new(self,name,sub_css,is_array)
      yield sub
      @sub_pages[name] = sub
    end
  end

  class SubPage
    attr_reader :parent, :css, :is_array
    include Container  
    def initialize(parent, name, css, is_array=false)
      @parent = parent
      @css = css
      @name = name
      @sub_pages = {}
      @elements  = {}
      @is_array = is_array
    end 
  end

  class Element
    attr_reader :parent, :name, :css
    def initialize(parent,name, css)
      @parent = parent
      @name = name
      @css = css
    end
  end

  class Page
    class << self
      def pages
        @pages||={}
      end
    end
    attr_accessor :name, :url_tpl
    include Container

    def initialize(name)
      @name = name
      @sub_pages = {}
      @elements  = {}
    end

    def self.define(name,&block)
      page = self.new(name)
      yield page
      self.pages[name] = page
      page
    end

    def parse(hash) 
      Parser.new(self,hash).go
    end

    def url(locals) 
      OpenStruct.new(locals.merge(:url_tpl=>self.url_tpl)).instance_eval{
        eval %Q{"#{url_tpl.gsub(/"/, '\"')}"}
      }
    end
  end

  class Parser
    attr_accessor :page, :url
    def initialize(page, hash)
      @page = page
      if hash.is_a?(String) 
        @url = hash
      else
        @url = page.url(hash)
      end
    end

    def go
      contaent_parser
      self
    end

    def [](key)
      contaent_parser[key]
    end

    def contaent_parser
      @content_parser||=ContentParser.new(doc,page)
    end

    def doc
      @doc||=Hpricot(open(URI.encode url))
    end

  end

  class ContentParser
    attr_accessor :doc, :page

    def initialize(doc, page)
      @doc = doc
      @page = page
    end

    def [](key)
      if r = page.sub_pages[key]
        if r.is_array
          doc.search(r.css).map{|e|self.class.new(e,r)}
        else
          self.new(doc.at(page.css),r)
        end
      elsif r = page.elements[key]
         doc.at(r.css)
      else
        raise "key not found" 
      end
    end

    def method_missing(key, *args, &block)
      if doc.respond_to?(key)
        doc.send key, *args, &block
      else
        super
      end
    end
  end
end