#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

def t_str time
	time.strftime("%H:%M")
end


get '/' do
	erb "<h2>Приветствую!!!<br/>
	 Мы облегчим тебе жизнь,<br/>
	 Не трать время на расчет таблицы маршрута!!!</h2>
	 <h3>Давайте <a href=/input>Попробуем</a></h3>"			
end

get '/input' do
	erb :input
end

post '/input' do


	@mashins = params[:mashins]
	@time_krug = params[:time_krug]

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
		:time_posled => 'Введите время последней машины'
    	}

    @error = hh.select{|key,value|  params[key] == ''}.values.join(', ')

    if @mashins.to_i > 20 || @time_krug.to_i > 300 
    	@error = 'Нее чет не так! Чегото много!!!'
    end	

    if @error != ""
    	return erb :input
    end


    @prom = @time_krug.to_i / ( @mashins.to_i - 2 )
    @otvet = params[:otvet]

    @t0 = Time.local(2021,5,1,@time_van_hh,@time_van_mm)
	@t1 = @t0 + @time_polkruga * 60
	@t3 = Time.local(2021,5,1,@time_posled_hh,@time_posled_mm)
    
	
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
	erb :tables
end

get '/contacts' do
  erb "<h2>Мы лучшие</h2>"
end