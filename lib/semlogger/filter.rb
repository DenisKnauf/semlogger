class Semlogger::Filter
	attr_accessor :level, :logdev

	def initialize level, logdev
		@level = level
		@logdev = logdev
	end

	def call severity, *a
		return true  if @level > severity
		@logdev.add severity, *a
	end
	alias add call
end

%w[debug info warn error fatal].each do |level|
	eval <<-EOC
		class ::Semlogger::F#{level.camelcase} < Semlogger::Filter
			def initialize *a
				super Semlogger::#{level.upcase}, *a
			end
		end
	EOC
end
