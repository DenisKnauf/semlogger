class Slogger::Rack < Rails::Rack::Logger
	def initialize app, tags = nil, data = nil
		super app, tags
		@data = data
	end

	def call_app env
		request = ActionDispatch::Request.new env
		path = request.filtered_path
		Rails.logger.info [:connection, request.ip, Thread.current.object_id, request.request_method, path]
		@app.call env
	ensure
		ActiveSupport::LogSubscriber.flush_all!
	end

	def call env
		if @data
			Rails.logger.data( compute_data( env)) { super env }
		else
			super env
		end
	end

	def compute_data env
		request = ActionDispatch::Request.new env

		data = @data.dup
		data.each do |k, v|
			case v
			when Proc
				data[k] = v.call request
			when Symbol
				data[k] = request.send v
			end
		end
	end
end
