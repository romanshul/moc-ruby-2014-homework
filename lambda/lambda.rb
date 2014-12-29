require 'json'
RESPONSE = File.read('data.json')
response = JSON.parse(RESPONSE)

class ScheduleCreator
	def self.create(title, actor, time)

	->(ownblock) do
      yield if block_given?
	  puts "#{title}\nstars:#{actor.join ", "}\ntime:#{time} hours\n"
	  ownblock.call
	  puts "\n"
    end
		
	end
end


class Films
	attr_accessor :schedule
	def initialize(data)
		self.schedule = []
		data.each do |theater|
			schedule.push ScheduleCreator.create(theater[:name], theater[:actor], theater[:time]) {puts "Look:"}
		end
	end

	def call_over(actions)
		self.schedule.each_with_index {|film, index| film.call(actions[index])}
	end

end

GetFilm = Struct.new(*response["catalog"].keys.collect(&:to_sym)) do

	def get_group(data, par)
		data.fetch(par)
	end

	def get_list
		self.get_array('l')
	end

	def get_directors
		self.get_array('d')
	end

	def get_array(sw)
		result = []
		
		self.each_pair do |k, v|
			case v
				when Hash
						title = self.get_group(v, "title")
						writers = self.get_group(v, "Writers")
						director = self.get_group(v, "Director")
						stars = self.get_group(v, "Stars")
						description = self.get_group(v, "description")
						time = self.get_group(v, "time")
				result.push Hash[name: title, actor: stars, time: time] if sw == "l"
				result.push -> {puts "Director: #{director}"} if sw == "d"
				end
		end
		result
	end
end

film = GetFilm.new(*response["catalog"].values)
list = film.get_list
directors = film.get_directors

Parameters = Films.new(list)

Parameters.call_over(directors)

