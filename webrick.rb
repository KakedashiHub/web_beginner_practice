 # webrick.rb
 require 'webrick'
 require "erb"

 server = WEBrick::HTTPServer.new({ 
   :DocumentRoot => './',
   :BindAddress => '127.0.0.1',
   :Port => 8000
  })
  
  trap(:INT){
    server.shutdown
  }
  
  server.mount_proc("/time") do |req, res|
    # レスポンス内容を出力
    body = "<html><body>\n"
    body += "#{Time.new}"
    body += "</body></html>\n"
    res.status = 200
    res['Content-Type'] = 'text/html'
    res.body = body
  end
  
  
  server.mount_proc("/form_get") do |req, res|
    puts "/form_getへのリクエストを受信しました"
    # レスポンス内容を出力
    body = "<html><head><meta charset='utf-8'></head><body>\n"
    body += "クエリパラメータは#{req.query}です<br>\n"
    body += "こんにちは#{req.query['username']}さん。"
    body += "あなたの年齢は#{req.query['age']}ですね"
    body += "</body></html>\n"
    res.status = 200
    res['Content-Type'] = 'text/html'
    res.body = body
  end
  
  server.mount_proc("/form_post") do |req, res|
    puts "/form_postへのリクエストを受信しました"
    # レスポンス内容を出力
    body = "<html><head><meta charset='utf-8'></head><body>\n"
    body += "フォームデータは#{req.query}です<br>\n"
    body += "こんにちは#{req.query['username']}さん。"
    body += "あなたの年齢は#{req.query['age']}ですね"
    body += "</body></html>\n"
    res.status = 200
    res['Content-Type'] = 'text/html'
    res.body = body
  end

  # erb を使うにはこういった記述が必要。
 WEBrick::HTTPServlet::FileHandler.add_handler("erb", WEBrick::HTTPServlet::ERBHandler)
 server.config[:MimeTypes]["erb"] = "text/html"
  
  # /hello パスにアクセスがあったときの処理
  server.mount_proc("/hello") do |req, res|
    template = ERB.new( File.read('hello.erb') )

    
    @now = Time.new
    
    
    # ERBを評価し、結果をレスポンスボディに追加
    res.body << template.result(binding)
  end

  foods = [
  { id: 1, name: "りんご", category: "fruits" },
  { id: 2, name: "バナナ", category: "fruits" },
  { id: 3, name: "いちご", category: "fruits" },
  { id: 4, name: "トマト", category: "vegetables" },
  { id: 5, name: "キャベツ", category: "vegetables" },
  { id: 6, name: "レタス", category: "vegetables" },
]

server.mount_proc("/foods") do |req, res|
  template = ERB.new( File.read('foods.erb') )
  
  # ここにロジックを書く
  # フォームから送信されたパラメータを取得
  category_filter = req.query["category"]

  # 選択されたカテゴリに基づいてフィルタリング
  filtered_foods =
    if category_filter == "fruits"
      foods.select { |food| food[:category] == "fruits" }
    elsif category_filter == "vegetables"
      foods.select { |food| food[:category] == "vegetables" }
    else
      foods
    end
  
  # ERB ファイルに変数を渡す
  res.body << template.result(binding)

end
  
 server.start
