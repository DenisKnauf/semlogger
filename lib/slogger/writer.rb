class Slogger::Output
end

class Slogger::Writer < Slogger::Output
	def initialize logdev = nil
		@logdev = logdev || ::Slogger::Rotate.new( ::Rails.root.join( 'log', ::Rails.env).to_s.gsub('%', '%%') + '.%Y-%m-%d.%$.log')
	end

	def add severity, time, progname, data, tags, message
		@logdev.write [severity, time, progname, data, tags, message].to_json
	end
end

class Slogger::Printer < Slogger::Output
	def initialize logdev = nil
		@logdev = logdev || $stdout
		@last_reqid = nil
	end

	def add severity, time, progname, data, tags, message
		line = case message[0]
			when :exception
				ex = message[1]
				r = "Exception: #{message[2]} (#{message[1]}"
				r << "\n\t" << message[3].join( "\n\t")  if message[3]
				r
			when String, Numeric, true, false, nil then message[0]
			when :obj then message[1].inspect
			else message.inspect
			end
		reqid = data[:reqid]
		unless @last_reqid == reqid
			@last_reqid = reqid
			puts "\n"
		end
		puts line
	end
end
