require 'json' #подключение библиотеки
require 'date'

class TaskRepository # класс задач
	attr_reader :parsed_data, :file_path #инициализиурем переменную хранящую в себе спарсенный файл и переменную для пути к файлу

	def initialize  
		read_json #вызываем метод для сохранения пути к файлу при создании объекта и парсинка в переменную
	end

	def read_json #метод чтения и парсинга 
	  @file_path = File.join(__dir__, 'tasks.json') #сохраняем в переменную путь к файлу
	  return unless File.exist?(file_path) 

	  json_data = File.read(@file_path) # присваиваем переменной команду прочитать файл по пути
	  @parsed_data = if File.exist?(@file_path)  #парсим файл
	           json_data = File.read(@file_path)
	           JSON.parse(json_data, symbolize_names: true)
	         else
	           { task: [] } # Если файла нет, создаем пустой массив задач
	         end #парсим данные в переменную
	end

	def save_task #метод для сохранения изменений в файл
		# Записываем обновленные данные обратно в файл
	  File.open(@file_path, 'w') do |file|
	    file.write(JSON.pretty_generate(@parsed_data))
	  end
	end

	def save_task_new(options={}) #метод для сохранения новой задачи
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
	  
	  save_task #сохраняем задачу

	end #end def

	def edit_name(name, index) #измненеие название задачи
		read_json #обновляем данные в переменной для парсинга

		@parsed_data[:task][index][:name] = name #изменяем название

		save_task #сохраняем эти данные в файл
	end

	def edit_status(index) #изменение статуса задачи
		read_json

		@parsed_data[:task][index][:completed]? @parsed_data[:task][index][:completed] = false : @parsed_data[:task][index][:completed] = true  #меняем статус взаисимости от того какой он сейчас

		save_task
	end

	def task_delete(index) #удаление задачи по номеру
		read_json 

		@parsed_data[:task].delete_at(index)

		save_task
	end

	def is_available?(input) #метод для проверки, что такая задача существует 
		ret = false
		@parsed_data[:task].each_with_index do |value, index|
			if index == (input.to_i - 1)
				ret = true
			end
		end
		ret
	end
end #end class

class Message # класс для управления сообщениями

	def menu_message # метод для отображения меню программы
		puts "Меню программы"
		puts "--------------"
		puts "1 - создать задачу"
		puts "2 - посмотреть задачи"
		puts "Enter - выйти из программы"
		puts "--------------"
		puts
		print "Ввод: "
	end #end def

	def editing_task_message #отображает список команд при изменении задачи
		puts "Редактироване задачи"
		puts "--------------"
		puts "1 - название"
		puts "2 - выполнение"
		puts "3 - удалить"
		puts "Enter - вернуться назад"
		puts "--------------"
		puts
	end

	def task_message 
		print "Введите название задачи: "
	end

	def view_all_tasks(data) #отображает список всех задач
		data[:task].each_with_index do |value, index|
			puts "Задача: №#{(index + 1)}, #{value[:name]}"
			puts "Выполнена: #{value[:completed]? "X" : " "}"
			puts "Дата создания: #{value[:date]}"
			puts "----------------------------"
		end
	end #end def

	def view_task(data) #отображает выбарнную задачу
			puts "Задача: #{data[:name]}"
			puts "Выполнена: #{data[:completed]? "X" : " "}"
			puts "Дата создания: #{data[:date]}"
			puts 
	end

	def clear #метод для очистки экрана
		puts "\e[H\e[2J"
	end 
end #end class

message = Message.new #создаем экземпляр класса сообщений 
task = TaskRepository.new #создаем экземпляр класса задачи

message.clear #очищаем экран

loop do
	message.menu_message #выводим сообщение

	input = gets.chomp #принимает ввод с клавиатуры

	puts

	case input #запускаем метод кейс для определения выбора пользователя
		when "1" #создаем задачу
			message.clear #очищаем экран

			message.task_message # выводим сообщение 
			input_task_create = gets # сохраняем ввод пользователя
			params_task_create = {name: input_task_create} # сохраняем ввод пользователя в переменную параметров		
			task.save_task_new(params_task_create) #передаем этим параметры в метод для сохранения задач
			puts

		when "2" #изменяем задачу
			message.clear #очищаем экран

			message.view_all_tasks(task.parsed_data) #отображаем все задачи
			
			print "Введите номер задачи или Enter чтобы вернуться назад: " 
			input_task = gets.chomp

			if input_task.empty? #если ввели пусто, то возвращаемся назад и очищаем экран
				message.clear
			else
				message.clear 
				if task.is_available?(input_task) #если такой номер есть, то выполняется условие ниже 
					loop do	 #цикл для редактирование задачи
						message.clear
						data = task.parsed_data #сохраняем в переменную спарсенную строку
						message.view_task(data[:task][(input_task.to_i - 1)]) #отображаем выбранную задачу
						
						message.editing_task_message #выводим сообщение о вариантах редактирования
						print "Ввод: "
						input_editing = gets.to_i

						case input_editing #варианты редактирования

							when 1 #меняем название
								print "Введите новое название: "
								input_name = gets
								task.edit_name(input_name, (input_task.to_i - 1)) #передаем в метод новое название и иднекс массива (номер задачи)

							when 2 #меняем статус
								task.edit_status((input_task.to_i - 1)) #передаем в метод номер задачи

							when 3 #удаляем задачу
								loop do  #цикл для корректного вода при удалении
									print "Вы уверенны что хотите удалить задачу №#{input_task.to_i}? 1 - да, 2 - нет: " #подтверждаем удаление
									input_delete = gets.to_i

									if input_delete == 1 #если подтвердили то удаляем
										task.task_delete((input_task.to_i - 1))
										break
									elsif input_delete == 2 #если нет, то просто закрываем цикл 
										break 
									else
										message.clear
										puts "Некорректный ввод!"
										puts
									end #end if
								end #end loop
								break #выходим из цикла редактирования задачи
							when 0
								break 
							else
								puts "Некорректный ввод! Попробуйте ещё раз"
						end # end case
					end #end loop
				else
					message.clear
					puts "Такой задачи нет в списке"
					puts
				end # end if 2
			end #end if 1
			message.clear
		when ""
			exit # выходим из программы если нажали Enter

		else
			message.clear

			puts "Некорректный ввод! Попробуйте ещё раз" # обработчик в случае ввода любого значения не относящегося к управлению программой
			puts
	end
	
end