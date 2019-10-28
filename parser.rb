def validate_start(array) #validates length of input for filename and key, in that order key should be -s or -p
  if array.length != 2
    puts "INPUT ERROR SIZE"
    return false
  end
  if array [1] == "-s"
    return true
  end
  if array[1] == "-p"
    return true
  end
  puts "ERROR NO KEY"
  false
end

def read_file(file, array) #open file if DNE then close, read line by line somehow make into one big line in array[0] for parsing and lexing
  _text = ""
  begin
    #_text = File.read(file, chomp: true)
    array = File.readlines(file)
  rescue => e
    puts "File does not exist!"
    puts e
    return false
  end

  array.each do |item|
    item.gsub!(/\s+/, '')
    end
  if array.length != 3
    return false
  end
  array #return array with [0] as one long string with no whitespace
end


#////////////////////////////////////////////VARS///////////////////////////////////////////////////#
input_array = ARGV #takes in command line as arguments
#input_array = %w(test1.cpl -p) #***DEBUGGING w/out commandline input***#
_chars = [] #array to make it easier to format input for lexing
input_as_string = String.new #holds formatted input for lexing (one big string)
_key = String.new
file_name = String.new
#////////////////////////////VARS//////////////////////////////////////////////////////////////////#


# validate starting input
if validate_start(input_array) #if method returns true
  file_name = input_array[0] #initalize file name from ARGV
  _key = input_array[1] #key should be -s or -p
end
  puts "Processing Input File #{file_name}"

if _key == "-s"
  if read_file(input_array[0], _chars) != false #read file and store chars into an array
    input_as_string = read_file(input_array[0], _chars).join #calling method twice feels redundant...?IDK
    print input_as_string #***FOR TESTING***#
  else
  puts "ERROR IN BODY"
  end
end

if _key == "-p"
puts "NOT HERE YET"
end
