require 'json'

class Object
	def to_semlogger
		[self.class.name.to_sym, self.respond_to?( :serializable_hash) ? self.serializable_hash : self ]
	end
end

class Exception
	def to_semlogger
		[:exception] + super
	end
end

class String
	def to_semlogger
		[:String, self]
	end
end

%w[Numeric FalseClass TrueClass NilClass].each do |cl|
	Object.const_get( cl).class_eval do
		def to_semlogger
			[:const, self]
		end
	end
end

class Semlogger < ::Logger
	class Base
		attr_accessor :logger

		def add severity, progname = nil, &block
			@logger.add severity, self, progname = nil, &block
		end

		::Semlogger::Severity.constants.each do |severity|
			module_eval "def #{severity.downcase}( *a, &e) add #{::Semlogger::Severity.const_get severity}, *a, &e end", __FILE__, __LINE__
		end
	end

	class CustomType < Base
		def initialize name, *obj
			@name, @obj = name.to_s.to_sym, obj
		end

		def to_semlogger
			[@name] + @obj
		end
	end

	attr_accessor :logdev, :level, :progname
	class <<self
		attr_accessor :progname

		def custom( *a)  CustomType.new *a  end
	end

	def custom *a
		r = CustomType.new *a
		r.logger = self
		r
	end

	@@progname = nil

	def initialize logdev = nil, *a, &e
		case logdev
		when String, nil then logdev = ::Semlogger::Writer.new logdev
		end
		@progname = a[0] || @@progname
		@level, @data, @tags, @logdev = DEBUG, {}, [], logdev
	end

	def tagged *tags, &e
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
		msg = msg.to_semlogger
		case msg
		when Array then msg
		else [msg.class.name.to_sym, msg.inspect]
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
		return @data  unless e
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
