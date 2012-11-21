require 'json'

class Object
	def to_semlogger
		[
			self.class.name.to_sym,
			self.respond_to?( :serializable_hash) ? self.serializable_hash : self
		]
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
		class <<self
			attr_accessor :logger
		end
		attr_accessor :logger

		def initialize
			@logger = self.class.logger
		end

		def add severity, logger = nil, &block
			(logger || @logger).add severity, self, &block
		end

		::Semlogger::Severity.constants.each do |severity|
			module_eval <<-EOC, __FILE__, __LINE__+1
				def #{severity.downcase} *a, &e
					add #{::Semlogger::Severity.const_get severity}, *a, &e
				end
			EOC
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

	# some libs use #log_level
	def log_level=( level)  @level = level  end
	def log_level()  @level  end

	class <<self
		attr_accessor :progname, :logger

		def new_rails_logger config, logdev = nil
			require 'semlogger/rack'
			logdev ||= ::Rails.root.join 'log', "#{::Rails.env.to_s.gsub('%', '%%')}.%Y-%m-%d.%$.log"
			logdev = logdev.to_s
			logger = nil
			if Rails.env.production?
				logger = new logdev
				logger.level = Semlogger::INFO
			elsif Rails.env.development?
				logger = new Semlogger::Multiplex.new( Semlogger::FInfo.new( Semlogger::Printer.new), Semlogger::Writer.new( logdev))
				logger.level = Semlogger::DEBUG
			else
				logger = new logdev
				logger.level = Semlogger::DEBUG
			end
			config.middleware.swap Rails::Rack::Logger, Semlogger::Rack, [], {reqid: :uuid}
			config.logger = logger
		end

		def custom( *a)  CustomType.new( *a).tap {|t| t.logger = self.logger }  end
	end
	def custom( *a)  CustomType.new( *a).tap {|t| t.logger = self }  end

	@@progname = nil

	def initialize logdev = nil, *a, &e
		case logdev
		when String, nil then logdev = ::Semlogger::Writer.new logdev
		end
		@progname = a[0] || @@progname
		@level, @data, @tags, @logdev = DEBUG, {}, [], logdev
		self.class.logger = self  if !self.class.logger && self.class.logger.is_a?( Semlogger::Default)
	end

	def tagged *tags, &e
		@tags += tags.flatten.compact
		tags = tags.size
		yield
	ensure
		#tags.times { @tags.pop }
		@tags.slice! -tags .. -1
	end

	def add severity, message = nil, progname = nil, &block
		severity ||= UNKNOWN
		return true  if @logdev.nil? or severity < @level
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
require 'semlogger/filter'
require 'semlogger/writer'

class Semlogger
	class Default < Semlogger
	end
	self.logger ||= Default.new
end
