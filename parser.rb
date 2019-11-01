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

def read_file(file, array) #open file if DNE then close, read line by line somehow make into one big line in array[0] for parsing and lexing
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
    puts "No data in file!"
    return false
  end
  array #return array with [0] as one long string with no whitespace
end

def print_tokens(ar1, ar2)
  arr = ar1.zip(ar2)
  arr.each do |i|
    if ar1[arr.find_index(i)] == "ID" || ar1[arr.find_index(i)] == "NUM"
      puts i.join(" ")
    else
      puts ar1[arr.find_index(i)]
    end
  end
end

def tokenize(str, key = -1)
  token_array = Array.new
  lexeme_array = Array.new
  str_array = str.chars
  num_array = Array.new
  lexer_array = Array.new #so my lexer can throw flags and tokens
  point_stage = 0
  i = 0
  char = str_array[i] #get beginning of str
  next_char = str_array[i+1]
  lexer = Lexer.new

  while char != (nil)
    point_stage = 0
    lexer_array = lexer.match_chars(char, next_char)
    # if lexer_array != -1 && lexer_array != 1 && lexer_array != 2
    #   lexer_array.flatten
    # end
    if lexer_array == -1
      puts "Lexical error"
      false
    elsif lexer_array == 1
      #keep working on point
      #keep going till lexer gives token or -1 --> then add
      #move up
      i+= 2
      char = str_array[i]
      next_char = str_array[i+1]
      lexer_array = lexer.match_chars(char, next_char,1)
      if lexer_array == 2
        #keep working on point
        #keep going till lexer == 0 --> then add
        #move up
        i+= 2
        char = str_array[i]
        next_char = str_array[i+1]
        lexer_array = lexer.match_chars(char, next_char,2)
        if lexer_array != -1 #confirms we have a complete point
          token_array << lexer_array
          lexeme_array << "point" << next_char
          #move up
          i+= 2
          char = str_array[i]
          next_char = str_array[i+1]
          point_stage = 1
        end
        end
      end
    if lexer_array == %w(SEMICOLON)
      token_array << lexer_array
      lexeme_array << char
      i += 1
      char = str_array[i]
      next_char = str_array[i+1]
    elsif point_stage == 0
      token_array << lexer_array
      lexeme_array << char << next_char
      #move up
      i+= 2
      char = str_array[i]
      next_char = str_array[i+1]
    end
  end
  num_array = get_nums(token_array.flatten, lexeme_array)
  puts "Lexical and Syntax analysis passed"
  if key == -1
    print_tokens(token_array.flatten, lexeme_array)
  elsif key == "-s"
    print_s(num_array)
  elsif key == "-p"
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

end

class Lexer
  def initialize
    @point = /"point"/#expecting L(
    @id = /[a-zA-z]/ #start expecting = || more of the id
    @num = /\d+\.?\d*/ #expecting COMMA || R || more of the num)
    @semicolon = /;/ #expecting ID
    @comma = /,/ #expecting NUM
    @period = /\./ #end
    @lparen = /\(/#expecting NUM
    @rparen = /\)/#expecting PERIOD || SEMI
    @equal = /=/ #expecting POINT
  end
  def match_chars(c1, c2, stage = 0) # takes in two chars (one is the runner/lookahead and a flag for point stages)
    if stage == 0
      if !!c1.match(@id) && !!c2.match(@equal)
        return %w(ID EQUAL)
      end
      if c1 == 'p'
        if c2== 'o'
          return 1
        end
      end
      if !!c1.match(@num) && !!c2.match(@comma)
        return %w(NUM COMMA)
      end
      if !!c1.match(@num) && !!c2.match(@rparen)
        return %w(NUM RPAREN)
      end
      if !!c1.match(@semicolon) && !!c2.match(@id)
        return %w(SEMICOLON)
      end
      if !!c1.match(@period) && c2 == nil
        return %w(PERIOD)
      end
      -1
      elsif stage == 1
        if c1 == 'i' && c2 == 'n'
          return 2
        else
          return -1
        end
      elsif stage == 2
        if c1 == 't' && !!c2.match(@lparen)
          return %w(POINT LPAREN)
        else
          return -1
        end
      end
  end
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
end
  puts "Processing Input File #{file_name}"

#if -s
if _key == "-s"
  if read_file(input_array[0], _chars) != false #read file and store chars into an array
    input_as_string = read_file(input_array[0], _chars).join
    if tokenize(input_as_string, _key) == false
      puts "ERROR IN LEXER"
    end
  end
end

#if -p
# if _key == "-p"
# puts "NOT HERE YET"
