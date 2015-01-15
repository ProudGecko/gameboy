def convert_map_file_to_c_header(map_file)
    File.open(map_file, "r") do |map_file_text|
        map_file_text.each do |line|
            if match = line.match(/\$([0-9A-F]*) = (.*)/)
                address, section = match.captures

                if !(match = section.match(/(.*)\.(.*)/))
                    puts("#define " + section + " 0x" + address)
                end
            end
        end
    end
end

puts "usage: ruby #{__FILE__} <.map file path>" if (!ARGV[0])

if ARGV[0] =~ /(.*)\.map/
    convert_map_file_to_c_header(ARGV[0])
else
    $stderr.puts "Invalid input file " + ARGV[0] + ".  File must have a .map extension"
end

