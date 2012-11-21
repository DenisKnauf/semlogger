class Semlogger::Rack < Rails::Rack::Logger
	def initialize app, tags = nil, data = nil
		super app, tags
		@data = data || {}
	end

	def call_app request, env
		path = request.filtered_path
		Rails.logger.custom( :connection, request.ip, Thread.current.object_id, request.request_method, path).info
		@app.call env
	ensure
		ActiveSupport::LogSubscriber.flush_all!
	end

	def call env
		request = ActionDispatch::Request.new env
		compute_tagged_ request do
			compute_data_ request do
				call_app request, env
			end
		end
	end

	def compute_tagged_ request
		if Rails.logger.respond_to? :tagged
			Rails.logger.tagged( compute_tags( request)) { yield }
		else
			yield
		end
	end

	def compute_data_ request
		if Rails.logger.respond_to? :data
			Rails.logger.data( compute_data( request)) { yield }
		else
			yield
		end
	end

	def compute_data request
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
