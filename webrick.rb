 # webrick.rb
 require 'webrick'
 require "erb"
 
 server = WEBrick::HTTPServer.new({ 
   :DocumentRoot => './',
   :BindAddress => '127.0.0.1',
   :Port => 8000
 })
 
 WEBrick::HTTPServlet::FileHandler.add_handler("erb", WEBrick::HTTPServlet::ERBHandler)
 server.config[:MimeTypes]["erb"] = "text/html"
 
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
   
   # ここにロジックを書く
   @selected_category = req.query['category']

   @foods = if @selected_category != "all"
              foods.select { |f| f[:category] == @selected_category }
            else
              foods
            end
 
   res.body << template.result( binding )
 end
 
 trap(:INT){
     server.shutdown
 }
 
 server.start
 