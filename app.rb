require 'json'

def menu_message # метод для отображения меню программы
	puts "Меню программы"
	puts "--------------"
	puts "1 - создать задачу"
	puts "Enter - выйти из программы"
	puts "--------------"
	puts
	print "Ввод: "
end

loop do 
	menu_message #выводим сообщение

	input = gets.chomp #принимает ввод с клавиатуры

	puts

	case input
		when "1"

		when ""
			exit # выходим из программы если нажали Enter

		else
			puts "Некорректный ввод! Попробуйте ещё раз" # обработчик в случае ввода любого значения не относящегося к управлению программой
	end
	
end