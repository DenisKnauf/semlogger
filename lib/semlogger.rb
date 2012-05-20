require 'json'

class Semlogger < ::Logger
	def initialize logdev = nil, *a, &e
		case logdev
		when String, nil then logdev = ::Semlogger::Writer.new logdev
		end
		@level, @data, @tags, @logdev = DEBUG, {}, [], logdev
	end

	def tagged tags, &e
		@tags += tags
		tags = tags.size
		yield
	ensure
		tags.times { @tags.pop }
	end

	def add severity, message = nil, progname = nil, &block
		severity ||= UNKNOWN
		if @logdev.nil? or severity < @level
			return true
		end
		progname ||= @progname
		if message.nil?
			if block_given?
				message = yield
			else
				message = progname
				progname = @progname
			end
		end
		@logdev.add severity, Time.new, progname, format_data( @data), format_tags( @tags), format_msg( message)
	end

	def format_msg msg
		case msg
		when Numeric, true, false, nil then [:const, msg]
		when String then [:str, msg]
		when Exception then [:exception, msg.class.name, msg.message.to_s, msg.backtrace]
		else [:obj, msg]
		end
	end

	def format_obj obj
		case obj
		when Proc then obj.call
		else obj
		end
	end

	def format_tags tags
		tags = tags ? tags.dup : []
		tags.map &method( :format_obj)
	end

	def format_data data
		data = data ? data.dup : {}
		data.each {|k,v| data[k] = format_obj v }
	end

	def data data, &e
		@data.update data
		keys = data.keys
		yield
	ensure
		keys.each &data.method( :delete)
	end

	def caller &e
		data caller: Kernel.method(:caller), &e
	end

	def thread &e
		data thread: Proc.new { Thread.current.object_id }, &e
	end
end

require 'semlogger/rotate'
require 'semlogger/multiplex'
require 'semlogger/rack'
require 'semlogger/filter'
require 'semlogger/writer'
