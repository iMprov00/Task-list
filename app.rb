require 'json'

class Task # класс задач

	def save_task(options={}) #метод сохраняющий новую задачу
		name_task = options[:name] || 0
	end #end def
end #end class

class Message # класс для управления сообщениями

	def menu_message # метод для отображения меню программы
		puts "Меню программы"
		puts "--------------"
		puts "1 - создать задачу"
		puts "Enter - выйти из программы"
		puts "--------------"
		puts
		print "Ввод: "
	end #end def

	def task_message
		print "Введите название задачи: "
	end

end #end class

message = Message.new #создаем экземпляр класса сообщений 
task = Task.new #создаем экземпляр класса задачи

loop do 
	message.menu_message #выводим сообщение

	input = gets.chomp #принимает ввод с клавиатуры

	puts

	case input
		when "1"
			message.task_message
			input_task_create = gets
			params_task_create = {name: input_task_create}			
			task.save_task(params_task_create)
		when ""
			exit # выходим из программы если нажали Enter

		else
			puts "Некорректный ввод! Попробуйте ещё раз" # обработчик в случае ввода любого значения не относящегося к управлению программой
	end
	
end