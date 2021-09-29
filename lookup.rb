def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_records = []
  dns_raw.each do |line|
    if !(line[0,1] == '#'|| line =~ /^[[:space:]]*$/)
      array1=line.split(',')
      array2= array1.collect(&:strip)
      new_hash = Hash.new
      new_hash[array2[0]] =array2[1..array2.length]
      dns_records.push(new_hash)
    end
  end
  return dns_records
end

def res(dns_records, lookup_chain, domain)
  dns_records.each do |record|
    record.each do |k,v|
      if(v.include?(domain))
       type = k
       if( type == "A")
          lookup_chain.push(v[1])
          return lookup_chain
       else
          lookup_chain.push(v[1])
          resolve(dns_records, lookup_chain, v[1])
       end
       return lookup_chain
      end
    end
  end
end

def resolve(dns_records, lookup_chain, domain)
  found = false
  dns_records.each do |record|
    record.each do |k,v|
      if(v.include?(domain))
       found = true
      end
    end
  end
  if(!found)
    error_m="Error: record not found for " + domain
    lookup_chain[0]= error_m
    return lookup_chain
  end
  return res(dns_records, lookup_chain, domain)
end


# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
