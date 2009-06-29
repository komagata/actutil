$exception_page = %w{
  FrontPage
  PukiWiki
  BracketName
  Help
  MenuBar
  RecentChanges
  InterWikiSandBox
  InterWiki
  InterWikiName
  RecentDeleted
  FormattingRules
  SandBox
  WikiEngines
  WikiName
  WikiWikiWeb
  YukiWiki
  ページ新規作成
  ページの一覧
  ページファイルの一覧
  単語検索
}

$exception_grep_page = [
  'PukiWiki\/\d+.\d+\.*'
]

class String
  def check_page?
    if self.empty? || $exception_page.include?(self)
      return true
    end

    $exception_grep_page.each do |pat|
      if /#{pat}/ =~ self
        return true
      end
    end

    false
  end

  def modify_html
    self.gsub!(/<a class=\"anchor_super\".*>.*<\/a>/,'')
    self.gsub!(/<div class=\"jumpmenu\"><a href=\"#navigator\">↑<\/a><\/div>/,'')
    self
  end
end
