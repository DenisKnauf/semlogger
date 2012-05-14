class Semlogger::Multiplex
	def initialize( *dests)  @__dests__ = dests  end

	def write( *a, &e)  @__dests__.each {|d| d.write *a, &e }  end
	def close( *a, &e)  @__dests__.each {|d| d.close *a, &e }  end
	def method_missing( m, *a, &e)
		if :'level=' == m and false
		 	p multiplex: m, a: a
			puts Kernel.caller.map {|l| "\t%s" % l }
		end
		r = true
		@__dests__.each {|d| r = d.send m, *a, &e }
		if :level == m and false
			p return: r, multiplex: m, d: @__dests__.last
			puts Kernel.caller.map {|l| "\t%s" % l }
		end
		r
 	end
end
