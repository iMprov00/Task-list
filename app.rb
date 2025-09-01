require 'json'
require 'date'

class TaskRepository # класс задач
	attr_reader :parsed_data, :file_path #инициализиурем переменную хранящую в себе спарсенный файл

	def initialize 
		read_json
	end

	def read_json
	  @file_path = File.join(__dir__, 'tasks.json') #сохраняем в переменную путь к файлу
	  return unless File.exist?(file_path) 

	  json_data = File.read(file_path)  
	  @parsed_data = if File.exist?(file_path) 
	           json_data = File.read(file_path)
	           JSON.parse(json_data, symbolize_names: true)
	         else
	           { task: [] } # Если файла нет, создаем пустой массив задач
	         end #парсим данные в переменную
	end

	def save_task(options={})
	  name_task = options[:name]&.chomp # Убираем символ новой строки
	  return if name_task.nil? || name_task.empty? # Проверяем, что название не пустое

	  # Создаем новую задачу
	  new_task = {
	    completed: false,
	    name: name_task,
	    date: DateTime.now.strftime('%Y-%m-%d %H:%M:%S') #текущая дата и время
	  }
	  
	  # Добавляем задачу в массив
	  @parsed_data[:task] << new_task

	  # Записываем обновленные данные обратно в файл
	  File.open(@file_path, 'w') do |file|
	    file.write(JSON.pretty_generate(@parsed_data))
	  end
	  
	  puts "Задача добавлена: #{name_task}"
	end #end def

	def edit_name(name, index)
		read_json

		@parsed_data[:task][index][:name] = name
	end

	def edit_statud(index)

	end

	def is_available?(input)
		ret = false
		@parsed_data[:task].each_with_index do |value, index|
			if value == input || index == (input.to_i - 1)
				ret = true
			end
		end
		ret
	end

end #end class

class Message # класс для управления сообщениями

	def menu_message # метод для отображения меню программы
		puts
		puts "Меню программы"
		puts "--------------"
		puts "1 - создать задачу"
		puts "2 - посмотреть задачи"
		puts "Enter - выйти из программы"
		puts "--------------"
		puts
		print "Ввод: "
	end #end def

	def editing_task_message
		puts "Редактироване задачи"
		puts "--------------"
		puts "1 - название"
		puts "2 - выполнение"
		puts "Enter - вернуться назад"
		puts "--------------"
		puts
	end

	def task_message
		print "Введите название задачи: "
	end

	def view_all_tasks(data)
		data[:task].each_with_index do |value, index|
			puts "Задача: №#{(index + 1)}, #{value[:name]}"
			puts "Выполнена: #{value[:completed]? "X" : " "}"
			puts "Дата создания: #{value[:date]}"
			puts "----------------------------"
		end
	end #end def

	def view_task(data)
			puts
			puts "Задача: #{data[:name]}"
			puts "Выполнена: #{data[:completed]? "X" : " "}"
			puts "Дата создания: #{data[:date]}"
			puts 
	end

	def no_task
		puts
		puts "Такой задачи нет в списке"
	end #end def

end #end class

message = Message.new #создаем экземпляр класса сообщений 
task = TaskRepository.new #создаем экземпляр класса задачи

loop do 
	message.menu_message #выводим сообщение

	input = gets.chomp #принимает ввод с клавиатуры

	puts

	case input
		when "1" #создаем задачу
			message.task_message # выводим сообщение 
			input_task_create = gets # сохраняем ввод пользователя
			params_task_create = {name: input_task_create} # сохраняем ввод пользователя в переменную параметров		
			task.save_task(params_task_create) #передаем этим параметры в метод для сохранения задач
			puts

		when "2"
			message.view_all_tasks(task.parsed_data)
			
			print "Введите номер задачи или Enter чтобы вернуться назад: "
			input_task = gets.chomp

			if input_task.empty? 
				message.menu_message
			else
				if task.is_available?(input_task)
					loop do	
						data = task.parsed_data
						message.view_task(data[:task][(input_task.to_i - 1)])
						
						message.editing_task_message
						print "Ввод: "
						input_editing = gets.to_i

						case input_editing

							when 1
								print "Введите новое название: "
								input_name = gets
								task.edit_name(input_name, (input_task.to_i - 1))

							when 2
								task.edti_status((input_task.to_i - 1))
								puts "Статус задачи изменился"

							when 0
								break

							else
								puts "Некорректный ввод! Попробуйте ещё раз"
						end # end case
					end #end loop
				else
					message.no_task
				end # end if 2
			end #end if 1

		when ""
			exit # выходим из программы если нажали Enter

		else
			puts "Некорректный ввод! Попробуйте ещё раз" # обработчик в случае ввода любого значения не относящегося к управлению программой
	end
	
end