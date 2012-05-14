class Slogger::Formatter < ::Logger::Formatter
	def initialize tags, data
		@tags, @data = tags, data
	end

	def obj2ser obj
		case obj
		when Proc then obj.call
		else obj
		end
	end

	def tags2list tags
		tags = tags ? tags.dup : []
		tags.map &method( :obj2ser)
	end

	def data2ser data
		data = data ? data.dup : {}
		data.each {|k,v| data[k] = obj2ser v }
	end

	def entry severity, time, progname, msg, tags, data
		e = { 
			lvl: severity,
			ts: time,
		}
		e[:prog] = progname  if progname
		e[:tags] = tags  if tags and not tags.empty?
		e[:data] = data  if data and not data.empty?
		e[:msg]  = msg
		e
	end

	def call severity, time, progname, msg
		[severity, time.xmlschema(9), progname, msg, tags, data].to_json + "\n"
	end
end
