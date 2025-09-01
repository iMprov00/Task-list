require 'json'
require 'date'

class TaskRepository # класс задач
	attr_reader :parsed_data #инициализиурем переменную хранящую в себе спарсенный файл

	def initialize 
		read_json
	end

	def read_json
	  file_path = File.join(__dir__, 'tasks.json')
	  return unless File.exist?(file_path)

	  json_data = File.read(file_path)  
	  @parsed_data = JSON.parse(json_data, symbolize_names: true)
	end

	def save_task(options={})
	  name_task = options[:name]&.chomp # Убираем символ новой строки
	  return if name_task.nil? || name_task.empty? # Проверяем, что название не пустое

	  # Определяем путь к файлу
	  file_path = File.join(__dir__, 'tasks.json') #определяем относительный путь
	  
	  # Читаем текущие данные или создаем пустую структуру
	  data = if File.exist?(file_path) 
	           json_data = File.read(file_path)
	           JSON.parse(json_data, symbolize_names: true)
	         else
	           { task: [] } # Если файла нет, создаем пустой массив задач
	         end

	  # Создаем новую задачу
	  new_task = {
	    completed: false,
	    name: name_task,
	    date: DateTime.now.strftime('%Y-%m-%d %H:%M:%S') #текущая дата и время
	  }
	  
	  # Добавляем задачу в массив
	  data[:task] << new_task

	  # Записываем обновленные данные обратно в файл
	  File.open(file_path, 'w') do |file|
	    file.write(JSON.pretty_generate(data))
	  end
	  
	  puts "Задача добавлена: #{name_task}"
	end #end def

	def view_task
		@parsed_data[:task].each_with_index do |value, index|
			puts "Задача: №#{(index + 1)}, #{value[:name]}"
			puts "Выполнена: #{value[:completed]? "X" : " "}"
			puts "Дата создания: #{value[:date]}"
			puts "----------------------------"
		end
	end #end def

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

	def task_message
		print "Введите название задачи: "
	end

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
			task.view_task
			puts "Enter - вернуться назад"
			gets
		when ""
			exit # выходим из программы если нажали Enter

		else
			puts "Некорректный ввод! Попробуйте ещё раз" # обработчик в случае ввода любого значения не относящегося к управлению программой
	end
	
end