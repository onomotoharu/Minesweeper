class Minesweaper 

	def initialize x = 5, y = 5, m = 5
		@field_height = x
		@field_width = y
		@mine_num = m
		@result = 0 # 0:carry on 1:game over 2:cleard
		make_field
		set_mine
	end

	#  init
	def make_field
		@field  = Array.new(@field_height).map{Array.new(@field_width,0)}
		@field_shown = Array.new(@field_height).map{Array.new(@field_width,'*')}
	end


	def set_mine
		(0...@field_height*@field_width).to_a.sample(@mine_num).each do |pos|
			x = pos / @field_width
			y = pos % @field_width
			@field[x][y] = 'x'
			set_hint_num x,y
		end
	end

	def out_of_range x,y
		begin 
			return x < 0 || y < 0 || x >= @field_height || y >= @field_width
		rescue
			puts '不正な入力です'
			return true
		end
	end


	def set_hint_num x, y
		[[x+1,y], [x-1,y], [x,y+1], [x,y-1]].each do |pos|
			x = pos[0]
			y = pos[1]

			next if out_of_range x,y
			if !!@field[x] && !!@field[x][y] then
				@field[x][y] = @field[x][y] == 'x' ? 'x' : @field[x][y]+1
			end
		end
	end


	# user input
	def open x, y
		if out_of_range x,y
			puts "不正な入力です"
			return
		end

		if @field_shown[x][y] == '?'
			puts 'そのマスは地雷チェックがされています'
			return
		end

		@field_shown[x][y] = @field[x][y]
		if @field[x][y] == 0
			open_around_zero x,y
		end
		@result = 1 if @field[x][y] == 'x'
	end


	def flag x, y
		if out_of_range  x,y
			puts "不正な入力です"
			return
		end
	
		unless @field_shown[x][y] == '?' 
			@field_shown[x][y] = '?'
		else
			@field_shown[x][y] = '*'
		end
	end


	# util
	def open_around_zero x,y
		[[x+1,y], [x-1,y], [x,y+1], [x,y-1]].each do |pos|
			x = pos[0]
			y = pos[1]

			next if out_of_range x,y

			if !!@field[x] && !!@field[x][y] && @field[x][y] == 0 && @field_shown[x][y] != 0  then
				@field_shown[x][y] = 0 unless @field_shown[x][y] == '?'
				open_around_zero x,y
			end
		end

	end


	def display
		puts '========'

		puts '   |	'+(0..@field_shown.first.length-1).to_a.join("	")

		puts '―	'*(@field_shown.first.length+1)


		@field_shown.each_with_index do |line, index|
			puts index.to_s+"  |	"+line.join("	")
		end
		puts '========'
	end


	def check_flug
		# 地雷チェックされているマスと、地雷マスが完全に一致しているかどうか
		field_for_check = @field.flatten
		field_shown_for_check = @field_shown.flatten

		field_for_check.map! do |cell|
			cell == 'x'
		end

		field_shown_for_check.map! do |cell|
			cell == '?'
		end

		@result = 2  if field_for_check == field_shown_for_check
	end


	def get_result
		check_flug	
		return @result
	end

end

# main
puts 'こんにちは。フィールドの高さ、幅、地雷の数を設定してください。指定しない場合は、高さ５,幅5,地雷の数5になります。(例"5 5 5")'
x,y,m = gets.split.map{|pos|pos.to_i}

if !!x && !!y && !!m
	minesweaper = Minesweaper.new(x,y,m)
else
	minesweaper = Minesweaper.new()
end

minesweaper.display


while true
	puts '選択する行・列を選択してください。(例"0 4")'
	x,y = gets.split.map{|pos|pos.to_i}
	puts "開く場合はo,地雷チェックはxを入力してください"
	mode = gets.chomp
	if mode == 'o'
		minesweaper.open(x,y)
	elsif mode == 'x'
		minesweaper.flag(x,y)
	else
		puts '入力が不正です。'
	end

	minesweaper.display

	result = minesweaper.get_result
	if result == 1
		puts 'GAME OVER'
		break
	elsif result == 2
		puts 'CLEAR!'
		break
	end

end
