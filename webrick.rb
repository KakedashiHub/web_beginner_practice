# webrick.rb
require 'webrick'

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
  current_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")

  body = "<html><body>Current_Time: #{current_time}</body></html>"

  res.status = 200
  res['Content-Type'] = 'text/html'
  res.body = body
end

#GETメソッド用の処理
server.mount_proc("/form_get") do |req, res|
  username = req.query["username"]
  age = req.query["age"]
  
  res['Content-Type'] = 'text/html; charset=UTF-8'
  res.body = "クエリパラメーターは#{{"username" => username, "age" => age}}です。<br>こんにちは#{username}さん。あなたの年齢は#{age}ですね。"
end

#POSTメソッド用の処理
server.mount_proc("/form_post") do |req, res|
  username = req.query["username"]
  age = req.query["age"]

  res['Content-Type'] = 'text/html; charset=UTF-8'
  res.body = "フォームデータは#{{"username"=> username, "age"=> age}}です。<br>こんにちは#{username}さん。あなたの年齢は#{age}ですね。"
end

# erb を使うにはこういった記述が必要。理解する必要はありません。このまま使いましょう。
WEBrick::HTTPServlet::FileHandler.add_handler("erb", WEBrick::HTTPServlet::ERBHandler)
server.config[:MimeTypes]["erb"] = "text/html"

server.mount_proc("/hello") do |req, res|
  template = ERB.new( File.read('hello.erb') )
  # 現在時刻についてはインスタンス変数をここで定義してみるといいかも？
  @current_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  res.body << template.result( binding )
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
  template = ERB.new( File.read('./foods/index.erb') )
  
  @categories = req.query["category"]
  
  @foods = []
  foods.each do |food|
    if @categories.nil? || @categories == "all" || food[:category] == @categories
      @foods << food
    end
  end

  res.body << template.result( binding )
end

server.start
