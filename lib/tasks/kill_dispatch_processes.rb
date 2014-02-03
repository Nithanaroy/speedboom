processes = (`ps -e | grep "node dispatch.j[s]"`).split(/\r?\n/).collect{ |p| p.split(' ').first.to_i }
processes.each{ |p| `sudo kill -9 #{p}` }