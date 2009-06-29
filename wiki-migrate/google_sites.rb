class GoogleSites

  def initialize(host, target, ua='Mac Safari')
    @host = host
    @uri = 'https://sites.google.com' + @host
    @target = target
    @wuid, @rev, @jotxtok = nil, nil, nil
    @agent = WWW::Mechanize.new
    @agent.user_agent_alias = ua
    @system_path = {
      :lockNode => "system/services/lockNode?jot.xtok=",
      :editorSave => "system/services/editorSave?jot.xtok=",
      :asciify => "system/services/asciify?jot.xtok=",
      :create => "system/services/create?jot.xtok=",
      :createPage => "system/app/pages/createPage",
      :DefaultForm => "/system/app/forms/DefaultForm"
    }
  end

  def login(email,passwd)
    login_page = @agent.get(@uri)
    login_form = login_page.forms.first

    login_form['Email'] = email
    login_form['Passwd'] = passwd
    @agent.submit(login_form)
    self.get
    self.set_jotxtok
  end

  def get(target=@target)
    uri = @uri + target
    @agent.get(uri)
  end

  def set_jotxtok
    @jotxtok = @agent.cookie_jar.jar["sites.google.com"]["jotxtok"].value
  end

  def set_wuid
    @agent.page.links_with(:href => /revisions/).each do |link|
      @wuid = $1 if /target=(.+)$/ =~ link.href
    end
  end

  def set_rev
    @agent.post_connect_hooks <<  Proc.new{|params|
      if /revision\":(\d+)/ =~ params[:response_body]
        @rev = $1
      end
    }
    page = @uri + @system_path[:lockNode] + @jotxtok
    @agent.post(page, {"val1" => @wuid, "key1" => "wuid"})
    @agent.post_connect_hooks.clear
  end

  def edit(main_title,main_text,target=@target)
    self.get(target)
    self.set_wuid
    self.set_rev

    page = @uri + @system_path[:editorSave] + @jotxtok
    requestPath = @host + target

    rst = @agent.post(page,
      "json" => "{
        \"uri\":\"#{@wuid}\",
        \"form\":\"#{@system_path[:DefaultForm]}\",
        \"properties\":{
          \"main/text\":[\"<DIV DIR='ltr'>#{main_text}</DIV>\"],
          \"main/title\":\"#{main_title}\"},
        \"requestPath\":\"#{requestPath}\",
        \"verifyLockRevision\":#{@rev}
      }"
    )
  end

  def asciify(path)
    unless /^(?:-*[a-z0-9])+$/ =~ path
      page = @uri + @system_path[:asciify] + @jotxtok
      requestPath = @host + @target
      rst = @agent.post(page,"json" => "{\"string\":\"#{path}\",\"delimiter\":\"-\"}")
      if /:\"([a-z0-9-]+)\"/ =~ rst.body
        path = $1
      end
    end
    path
  end

  def create(path,main_title,main_text=nil,dir=@target)
    target = @system_path[:createPage] + "?source=/" + dir
    self.get(target)

    path = self.asciify(path)
    path = dir + "/" + path

    page = @uri + @system_path[:create] + @jotxtok
    pagetype = "text"
    requestPath = @host + "/" + @system_path[:createPage]

    rst = @agent.post(page,
      "json" => "{
        \"path\":\"/#{path}\",
        \"pagetype\":\"#{pagetype}\",
        \"properties\":{
          \"main/title\":\"#{main_title}\"
        },
        \"requestPath\":\"#{requestPath}\"
      }"
    )

    unless main_text.nil?
      self.edit(main_title, main_text, path)
    end
  end
end
