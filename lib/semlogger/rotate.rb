class Semlogger::Rotate
	attr_reader :file

	def filename()  @filename.dup  end

	def initialize filename
		@filename = filename
	end

	def open_if
		name = Time.now.strftime( @filename).gsub /%\$/, $$.to_s
		@file.close  if @file and name != @file.path
		@file = File.open name, 'a'  unless @file
		@file
	end

	def write message
		open_if.write message
	end

	def close
		@file.close
		@file = nil
	end
end
