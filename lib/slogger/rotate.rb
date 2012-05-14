class Slogger::Rotate
	attr_reader :file

	def filename()  @filename.dup  end

	def initialize filename
		@filename = filename
	end

	def open_if
		name = Time.now.strftime( @filename).gsub /%\$/, $$.to_s
		#p at: Time.now, open_if: name, cur: @file ? @file.path : nil, e: @file ? name == @file.path : nil
		if @file and name == @file.path
			@file.close
			@file = nil
		end
		@file = File.open name, 'a'  unless @file
		@file
	end

	def write message
		open_if.write message
	end

	def close
		@file.close
	end
end
