class Semlogger::Output
end

class Semlogger::Writer < Semlogger::Output
	def initialize logdev = nil
		@logdev = case logdev
			when String then ::Semlogger::Rotate.new logdev
			when nil then ::Semlogger::Rotate.new "log/#{File.basename $0}.%Y-%m-%d.%$.log"
			else logdev
			end
	end

	def add severity, time, progname, data, tags, message
		@logdev.write [severity, time.xmlschema(9), progname, data, tags, message].to_json+"\n"
	end
end

class Semlogger::Printer < Semlogger::Output
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
			when :String, :const then message[1]
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
