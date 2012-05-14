class Slogger::Tailer < Rails::Rack::LogTailer
	def initialize app, log = nil
		@app = app
		log ||= Rails.root.join( 'log', Rails.env).to_s.gsub('%', '%%') + '.%Y-%m-%d.%$.log'
		@path = Pathname.new( log).cleanpath.to_s
		@files = {}
	end

	def dirscan path, time
		path = path.gsub /(%.)/ do |f|
			case f
			when '%%' then '%%'
			when '%Y' then yesterday.year
			when '%m' then yesterday.month
			when '%d' then yesterday.day
			when /%./ then '*'
			end
		end
		preday = time - 1.day
		Dir[ files].each do |file|
			@files[file] ||= [::File.open( file, 'r'), 0, preday]
		end
	end

	def tail!
		yesterday, today = 1.day.ago.beginning_of_day, Time.now.beginning_of_day
		dirscan @path, yesterday
		dirscan @path, today

		@files.each do |fn, meta|
			file = meta[0]
			file.seek meta[1]
			unless file.eof?
				contents = file.read
				cursor = file.tell
				$stdout.print contents
			end
			meta[2] = today  if meta[1] == cursor
			meta[1] = cursor
			if yesterday > meta[2]
				meta[0].close
				@files.delete fn
			end
		end
	end
end
