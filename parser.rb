def validate_start(array) #validates length of input for filename and key, in that order key should be -s or -p
  if array.length != 2
    puts "Wrong parameters"
    puts "Usage:"
    puts "ruby parser.rb filename [-p | -s]"
    puts "Use -p to generate Prolog Queries"
    puts "Use -s to generate Scheme function call"
    return false
  end
  if array [1] == "-s"
    return true
  end
  if array[1] == "-p"
    return true
  end
  puts "Wrong parameters"
  puts "Usage:"
  puts "ruby parser.rb filename [-p | -s]"
  puts "Use -p to generate Prolog Queries"
  puts "Use -s to generate Scheme function call"
  false
end

def read_file(file, array) #open file if DNE then close, read line by line
  begin
    array = File.readlines(file)
  rescue => e
    puts "File does not exist!"
    puts e
    return false
  end
#strip out all whitespace (space, tabs and enters)
  array.each do |item|
    item.gsub!(/\s+/, '')
    end
  if array.length == 0
    puts "No data in file!"
    return false
  end
  array
end

def print_tokens(ar1, ar2)
  arr = ar1.zip(ar2) #combine tokens and lexemes
  arr.each do |i|
    if ar1[arr.find_index(i)] == "ID" || ar1[arr.find_index(i)] == "NUM" #if we have ID or NUM token print associating data
      puts i.join(" ")
    else
      puts ar1[arr.find_index(i)]
    end
  end
end

def tokenize(str, key = -1)
  point = /"point"/#expecting L(
  id = /[a-zA-z]/ #start expecting = || more of the id
  num = /\d+\.?\djk
*/ #expecting COMMA || R || more of the num)
  semicolon = /;/ #expecting ID
  comma = /,/ #expecting NUM
  period = /\./ #end
  lparen = /\(/#expecting NUM
  rparen = /\)/#expecting PERIOD || SEMI
  equal = /=/ #expecting POINT
#_______________________VARS FOR MOVING AND STORAGE_______________________________________
  token_array = Array.new
  lexeme_array = Array.new
  str_array = str.chars
  id_flag = 0 #so we dont confuse a point as ID
  i = 0
  char = str_array[i]
  next_char = str_array[i+1]
#_______________________________________________________________
  while next_char != nil
    if id_flag == 0
      if !!char.match(id) && !!next_char.match(equal)#best-case
          token_array << "ID" << "EQUAL"
          lexeme_array << char << next_char
          i+=2
          char = str_array[i]
          next_char = str_array[i+1]
          id_flag = 1 #so point dosent enter this condition
      elsif !!next_char.match(id) #worst-case
        temp_char = String.new
        while !!next_char.match(id) #move up one by one
          i+=1
          next_char = str_array[i]
          if !!next_char.match(id)
            temp_char << next_char
          end
        end
        token_array << "ID"
        lexeme_array << (char.concat temp_char)
        if !!next_char.match(equal)
          token_array << "EQUAL"
          lexeme_array << next_char
          i+=1
          char = str_array[i]
          next_char = str_array[i+1]
          id_flag = 1 #so point dosent enter this condition
        else
          return false
        end
      end
    end
    if id_flag == 1 #looking for point
      if char == 'p' #only-case
        if next_char == 'o'
          i += 2
          char = str_array[i]
          next_char = str_array[i+1]
          if char == 'i'
            if next_char == 'n'
              i += 2
              char = str_array[i]
              next_char = str_array[i+1]
              if char == 't'
                if !!next_char.match(lparen)
                  token_array << "point" << "LPAREN"
                  lexeme_array << "point" << next_char
                  id_flag = 0 #now that we have point we can be ready for next ID
                  i += 2
                  char = str_array[i]
                  next_char = str_array[i+1]
                end
              end
            end
          end
        end
      end
    end
    if !!char.match(num) && !!next_char.match(comma) #best-case
        token_array << "NUM" << "COMMA"
        lexeme_array << char << next_char
        i += 2
        char = str_array[i]
        next_char = str_array[i+1]
    elsif !!next_char.match(rparen) #best-case
      token_array << "NUM" << "RPAREN"
      lexeme_array << char << next_char
      i += 2
      char = str_array[i]
      next_char = str_array[i+1]
    elsif !!char.match(period) && !!next_char.match(num) #handling nums w/ decimal
      temp_num = char
      while !!next_char.match(num) #move up one by one
        i+=1
        next_char = str_array[i]
        if !!next_char.match(num)
          temp_num << next_char
        end
      end
      token_array << "NUM"
      lexeme_array << (char.concat temp_num)
      i+=1
      char = str_array[i]
      next_char = str_array[i+1]
    elsif !!next_char.match(period) #handling nums w/ decimal
      temp_num = next_char
      i+=2
      next_char = str_array[i]
      if !!next_char.match(num)
        while !!next_char.match(num) #move up one by one
          i+=1
          next_char = str_array[i]
          if !!next_char.match(num)
            temp_num << next_char
          end
        end
        token_array << "NUM"
        lexeme_array << (char.concat temp_num)
        i+=1
        char = str_array[i]
        next_char = str_array[i+1]
      else
        return false
      end
    elsif !!next_char.match(num) #worst-case
      temp_num = String.new
      while !!next_char.match(num) #move up one by one
        i+=1
        next_char = str_array[i]
        if !!next_char.match(num)
          temp_num << next_char
        end
        if !!next_char.match(period) #handle the decimal
          i+=1
          next_char = str_array[i]
          temp_num << "." << next_char
          if next_char.match(num) == false
            return false #NUM must come after the decimal
          end
        end
      end
      token_array << "NUM"
      lexeme_array << (char.concat temp_num)
      if !!next_char.match(comma)
        token_array << "COMMA"
        lexeme_array << next_char
        i+=1
        char = str_array[i]
        next_char = str_array[i+1]
      elsif !!next_char.match(rparen)
        token_array << "RPAREN"
        lexeme_array << next_char
        i+=1
        char = str_array[i]
        next_char = str_array[i+1]
      end
      false
    end
    if !!char.match(semicolon) #only-case
      if !!next_char.match(id) #just checking
        token_array << "SEMICOLON"
        lexeme_array << char
        i += 1
        char = str_array[i]
        next_char = str_array[i+1]
      else
        return false #ID has to come after a semicolon but I dont want to tokenize ID here
      end
    end
    if !!char.match(period)
      if next_char == nil #only-case
        token_array << "PERIOD"
        lexeme_array << char
      end
    end
  end
  if token_array.length == 0 #couldnt find any tokens but it didnt fail any tests -- thus we have an uncaught error with data on file
    return false
  end
  num_array = get_nums(token_array.flatten, lexeme_array) #get the 6 nums for printing
  puts "Lexical and Syntax analysis passed" #if syntax is wrong it shouldnt pass the tests above same with lexer
  if key == -1 #if you want to see the tokens processed
    print_tokens(token_array.flatten, lexeme_array)
  elsif key == "-s" #scheme output
    print_s(num_array)
  elsif key == "-p" #prolog output
    print_p(num_array)
  end
  end

def get_nums(ar1, ar2)
  arr = ar1.zip(ar2)
  num_array = Array.new
  arr.each do |i|
    if ar1[arr.find_index(i)] == "NUM"
      num_array << ar2[arr.find_index(i)]
    end
  end
  num_array
end

def print_s(ar1)
  puts "(calculate-triangle (make-point #{ar1[0]} #{ar1[1]}) (make-point #{ar1[2]} #{ar1[3]}) (make-point #{ar1[4]} #{ar1[5]}))"
end

def print_p(ar1)
puts "query(line(point2d(#{ar1[0]}, #{ar1[1]}), point2d(#{ar1[2]}, #{ar1[3]}), point2d(#{ar1[4]} #{ar1[5]})))"
puts "query(triangle(point2d(#{ar1[0]} #{ar1[1]}), point2d(#{ar1[2]} #{ar1[3]}), point2d(#{ar1[4]} #{ar1[5]})))"
puts "query(vertical(point2d(#{ar1[0]} #{ar1[1]}), point2d(#{ar1[2]} #{ar1[3]}), point2d(#{ar1[4]} #{ar1[5]})))"
puts "query(horizontal(point2d(#{ar1[0]} #{ar1[1]}), point2d(#{ar1[2]} #{ar1[3]}), point2d(#{ar1[4]} #{ar1[5]})))"
puts "query(equilateral(point2d(#{ar1[0]} #{ar1[1]}), point2d(#{ar1[2]} #{ar1[3]}), point2d(#{ar1[4]} #{ar1[5]})))"
puts "query(isosceles(point2d(#{ar1[0]} #{ar1[1]}), point2d(#{ar1[2]} #{ar1[3]}), point2d(#{ar1[4]} #{ar1[5]})))"
puts "query(right(point2d(#{ar1[0]} #{ar1[1]}), point2d(#{ar1[2]} #{ar1[3]}), point2d(#{ar1[4]} #{ar1[5]})))"
puts "query(scalene(point2d(#{ar1[0]} #{ar1[1]}), point2d(#{ar1[2]} #{ar1[3]}), point2d(#{ar1[4]} #{ar1[5]})))"
puts "query(acute(point2d(#{ar1[0]} #{ar1[1]}), point2d(#{ar1[2]} #{ar1[3]}), point2d(#{ar1[4]} #{ar1[5]})))"
puts "query(obtuse(point2d(#{ar1[0]} #{ar1[1]}), point2d(#{ar1[2]} #{ar1[3]}), point2d(#{ar1[4]} #{ar1[5]})))"
puts "writeln(T) :- write(T), nl."
puts "main:- forall(query(Q), Q-> (writeln:'yes')) ; writeln('no'))),"
puts "       halt."
end


#////////////////////////////////////////////VARS///////////////////////////////////////////////////#
input_array = ARGV #takes in command line as arguments
#input_array = %w(test1.cpl -s) #***DEBUGGING w/out commandline input***#
_chars = [] #array to make it easier to format input for lexing
input_as_string = String.new #holds formatted input for lexing (one big string)
_key = String.new
file_name = String.new
#////////////////////////////VARS//////////////////////////////////////////////////////////////////#
# validate starting input
if validate_start(input_array) #if method returns true
  file_name = input_array[0] #initalize file name from ARGV
  _key = input_array[1] #key should be -s or -p
  puts "Processing Input File #{file_name}"
end
if read_file(input_array[0], _chars) != false #read file and store chars into an array
  input_as_string = read_file(input_array[0], _chars).join
  if tokenize(input_as_string, _key) == false #lexical and syntax analysis
    puts "ERROR IN LEXER"
  end
end