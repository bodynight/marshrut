#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def t_str time
	time.strftime("%H:%M")
end
def init_db
	@db = SQLite3::Database.new 'marshruts.db'
	@db.results_as_hash = true
end

before do
		init_db
end

configure do
	 init_db
	@db.execute 'CREATE TABLE if not exists`Tables` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`start`	TEXT,
	`end`	TEXT,
	`krug`	INTEGER,
	`nomer_marshruta`	TEXT,
	`mashins`	INTEGER,
	 tp_krug  TEXT,
	 t_mash   TEXT

)'

@db.execute 'CREATE TABLE if not exists`Selected` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`nomer_marshruta`	TEXT,
	 coment   TEXT

)'
end



get '/' do
	erb :index 		
end

get '/input' do
	erb :input
end

post '/input' do

	
	@mashins = params[:mashins]
	@time_krug = params[:time_krug]
	@nomer_marshruta = params[:nomer_marshruta]
	@time_otdih = params[:time_otdih].to_i

	@time_polkruga = @time_krug.to_i / 2

	@time_van = params[:time_van]
	arr = @time_van.split(':')
	@time_van_hh =arr[0].to_i
	@time_van_mm = arr[1].to_i

	@time_posled = params[:time_posled]
	arr2 = @time_posled.split(':')
	@time_posled_hh =arr2[0].to_i
	@time_posled_mm = arr2[1].to_i
	

	hh ={
		:mashins => 'Введите количество машин!',
		:time_krug => 'Введите время круга!',
		:time_van => 'Введите время первой машины!',
		:time_posled => 'Введите время последней машины',
		:nomer_marshruta =>'Введите номер маршрута',
		:time_otdih => 'Введите время на отдых'
    	}

    @error = hh.select{|key,value|  params[key] == ''}.values.join(', ')

     @sel = @db.execute 'select * from Selected'

     
     	
     
     	
     @sel.each do |rows|
     	if rows["nomer_marshruta"] == @nomer_marshruta
     		@error = 'Такой маршрут существует. Удалите или переименуйте маршрут '
     		@sovpad = 'sovpad'
     	end
     end

     @del = params[:delit]
	if @del == 'ok'
		@db.execute 'DELETE FROM Tables WHERE nomer_marshruta = ?', [@nomer_marshruta,]
		@db.execute 'DELETE FROM Selected WHERE nomer_marshruta = ?', [@nomer_marshruta,]
		redirect '/input'
	end


    if @mashins.to_i > 20 || @time_krug.to_i > 300 || @time_otdih > 60
    	@error = 'Нее чет не так! Чегото много!!!'
    end	

    if @error != ""
    	return erb :input
    end


    @prom = @time_krug.to_i / ( @mashins.to_i - 2 )
    @otvet = params[:otvet]

    @t0 = Time.local(2021,5,1,@time_van_hh,@time_van_mm)
	@t1 = @t0 + @time_polkruga * 60 + @time_otdih * 60
	@t3 = Time.local(2021,5,1,@time_posled_hh,@time_posled_mm)
	@tp_krug = @mashins.to_i * @otvet.to_i

	    
	
	if @otvet != ""
	 return	erb :tables
    end

	erb :input

end

get '/tables' do

		
	if @otvet == nil
		@error = 'Сначало введите данные:'
		return erb :input
	end

	return erb :tables
end

post '/tables' do
	
	 @coment = params[:coment] 

	 @result = @db.execute 'select * from Tables order by id desc'
	 @row = @result[0]
	 @num_marshruta = @row["nomer_marshruta"]

	 @db.execute 'insert into Selected (nomer_marshruta, coment ) values (?, ?)', 
	[@num_marshruta, @coment]  

	redirect '/saved_tables'
end

get '/contacts' do
  erb "<h2>Мы лучшие</h2>"
end

get '/saved_tables' do
	@result_2 = @db.execute 'select * from Tables order by id desc'
	 @row_2 = @result_2[0]
	 @nomer_marshruta = @row_2["nomer_marshruta"]
	 
	 	

	@per_tables = @db.execute 'select * from Selected order by nomer_marshruta'
	@sel_table = @db.execute 'select * from Tables where nomer_marshruta = ? ', [@nomer_marshruta]
	@row = @sel_table[0]
	@b_coment = @db.execute 'select * from Selected where nomer_marshruta = ?', [@nomer_marshruta]
	@coment_row =@b_coment[0]

  erb :saved_tables
end

post '/saved_tables' do
	@nomer_marshruta = params[:ns_marshruta]
	
	@per_tables = @db.execute 'select * from Selected order by nomer_marshruta'
	@sel_table = @db.execute 'select * from Tables where nomer_marshruta = ? ', [@nomer_marshruta]
	@row = @sel_table[0]
	@b_coment = @db.execute 'select * from Selected where nomer_marshruta = ?', [@nomer_marshruta]
	@coment_row =@b_coment[0]
	 erb :saved_tables
	
end