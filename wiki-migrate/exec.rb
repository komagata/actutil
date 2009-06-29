#!/usr/bin/env ruby

# You need mechanize
# -- gem install mechanize

# At first, you set email and password in EMAIL and PASSWORD (google account)

# Second, you set your google sites path in path(except for "https://sites.google.com")
# ex) path = "/a/actindi.net/share/"

# Third, you set your request_path that means path in detail
# ex) https://sites.google.com/a/actindi.net/share/test
#=> path = '/a/actindi.net/'
#=> request_path = 'test'
# if there is a Basic authentication in your pukiwiki, you set BASIC_USER_NAME and BASIC_PASSWORD

# At last, you execute under the command
# -- ruby exec.rb

require 'rubygems'
require 'mechanize'
require 'google_sites'
require 'pukiwiki'

EMAIL = ''
PASSWORD = ''
BASIC_USER_NAME = ""
BASIC_PASSWORD = ""

path = '/a/actindi.net/share/'
request_path = 'test/test1'

gs = GoogleSites.new(path, request_path)
gs.login(EMAIL, PASSWORD)

host = 'http://localhost/pukiwiki/'
page = 'index.php?cmd=list'
agent = WWW::Mechanize.new
agent.auth(BASIC_USER_NAME, BASIC_PASSWORD) unless BASIC_USER_NAME.empty?
agent.get(host + page)

pat_host = host.gsub("/","\/")
links = agent.page.links_with(:href => /^#{pat_host}/)

links.each do |link|
  page = link.click

  title = page.title.gsub(/\ -\ PukiWiki$/,'')
  next if title.check_page?

  #body = page.root.search('table tr td div#body').inner_text
  body = page.root.search('table tr td div#body').inner_html
  body = body.modify_html

  path = title.dup

  # 現状、bodyの値が登録できません
  # 多分、encodeの問題だと思います
  # 下記SAMPLEは動作確認しました
  # gs.create(path, title, body)

  # SAMPLE
  #  path = "test-command8"
  #  title = "テスト8"
  #  body = "test8"
  #  gs.create(path, title, body)
  #  break
end


# Create a new page
#create_target = "test/test/test"
#create_path = "test27"
#create_main_title = "テスト27"
#create_main_text = "hoge"
#gs.create(create_path,create_main_title)
#gs.create(create_path, create_main_title, create_main_text)
#gs.create(create_path, create_main_title, create_main_text, create_target)

# Edit a page
#main_title = "テスト1"
#main_text = "テスト本文1"
#gs.edit(main_title, main_text)
#gs.edit(main_title, main_text, create_target)
