class Slogger::Transaction
	include UUIDTools
	attr_reader :app, :id, :default_id

	class <<self
		attr_accessor :transaction
		def to_s()  transaction.to_s  end
		def id()  transaction.id  end
	end

	def new_id
		UUID.random_create
	end

	def initialize app, logger = nil, default_id = nil
		@app, @default_id = app, default_id || new_id
		(logger||self.class).transaction = self
	end

	def call *paras
		@id = new_id
		@app.call *paras
	ensure
		@id = @default_id
	end

	def to_s()  @id.to_s  end
end
