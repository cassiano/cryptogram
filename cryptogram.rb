require 'irb'
require 'wirble'
require 'forwardable'

Wirble.init
Wirble.colorize

class String
  def signature
    @signature ||= self.split('').inject ['', ''] do |memo, char| 
      memo.tap do
        if (i = memo[1].index(char))
          memo[0] << (i+1).to_s
        else
          memo[1] << char
          memo[0] << memo[1].size.to_s
        end
      end
    end
  end
end

class Dictionary
  extend Forwardable
  
  def initialize(filename)
    @words = File.read(filename).split.inject Hash.new([]) do |memo, word| 
      # Get rid of non-alphabetic characters.
      word.gsub!(/[^a-zA-Z]/, '')

      memo.tap do
        memo[word.signature[0]] += [word]
      end
    end
  end
  
  def_delegator :@words, :[], :lookup

  def print_word(word)
    color = 
        word.include?('.') ?
          :yellow :
          self.lookup(word.signature[0]).map(&:downcase).include?(word) ?
            :green :
            :red
    
    Wirble::Colorize.colorize_string(word, color)
  end
end

class Cryptogram
  attr_reader :solutions

  def initialize(dictionary, tokens, initial_translations = {})
    @dictionary           = dictionary
    @tokens               = tokens
    @initial_translations = initial_translations
  end

  def solve!(options = {})
    options = {
      :level  => 0,
      :debug  => false
    }.merge(options)
    
    if @tokens.empty? 
      self.mapping    # If the current mapping is invalid this will raise an exception.

      puts ">>> Partial solution found: #{@initial_translations.inspect}"

      return @initial_translations
    end

    sorted_tokens = @tokens.sort do |a, b|
      if (cmp = b.length <=> a.length) != 0
        cmp
      elsif (cmp = a.signature[1].length <=> b.signature[1].length) != 0
        cmp
      else
        @dictionary.lookup(a.signature[0]).size <=> @dictionary.lookup(b.signature[0]).size
      end
    end
    
    sorted_tokens.each do |token|
      puts ">>> Looking for solutions for token '#{token}' and initial translations #{@initial_translations.inspect}..." if options[:debug]

      candidates = self.find_candidates(token)

      puts "#{candidates[1].length} candidates found (#{candidates[1].join(', ')}) for #{token} and level #{options[:level]}" if options[:debug]

      @solutions = candidates[1].inject([]) { |memo, candidate|
        memo.tap do
          begin
            cryptogram = Cryptogram.new(@dictionary, sorted_tokens[1..-1], @initial_translations.merge(token => candidate))
            
            memo << cryptogram.solve!(:level => options[:level] + 1, :debug => options[:debug])
          rescue StandardError => e
            puts e.message if options[:debug]
          end
        end
      }.compact.flatten

      if !@solutions.empty?
        puts "Solutions found: #{@solutions.inspect}" if options[:debug]

        return @solutions
      end
    end

    nil
  end

  def print_phrases
    self.phrases.each_with_index { |phrase, i| puts "(#{'%04d' % (i+1)}) #{phrase[1]} [#{phrase[0][1]}]" }
    nil
  end

  def self.generate_mapping(translations)
    alphabet = ('a'..'z').to_a.join

    # Using a '.' for unmapped letters seems a great idea, since it can be later reused in the RegExp search (see :find_candidates method).
    (map = [alphabet, '.' * alphabet.length]).tap do
      translations.each do |k, v| 
        k.split('').each_with_index do |c, i| 
          key_char_alphabet_index = map[0].index(c)
          current_value           = map[1][key_char_alphabet_index]

          if current_value == '.'
            if !map[1].include?(v[i])
              map[1][key_char_alphabet_index] = v[i]
            else
              raise "Duplicate value '#{v[i]}' in map #{map.inspect} with translations #{translations.inspect}"
            end
          elsif current_value != v[i]
            raise "Conflicting values '#{current_value}' and '#{v[i]}' for index #{key_char_alphabet_index} in map #{map.inspect} with translations #{translations.inspect}"
          end
        end
      end
    end
  end

  protected

  def find_candidates(token)
    token_re = token.tr(*self.mapping)

    if token_re.include?('.')
      # token_optimized_re = (tmp = token_re.gsub('.', '')).empty? ?
      #   token_re :
      #   token_re.gsub('.', "[^#{tmp.signature[1]}]")
      # 
      # [token_re, @dictionary.lookup(token.signature[0]).grep(/#{token_optimized_re}/i).map(&:downcase).uniq]

      [token_re, @dictionary.lookup(token.signature[0]).grep(/#{token_re}/i).map(&:downcase).uniq]
    else
      [token_re, [token_re]]
    end
  end

  def mapping
    @mapping ||= self.class.generate_mapping(@initial_translations)
  end
  
  def phrases
    raise "Please call :solve! to find all possible solutions!" unless @solutions
    
    @phrases ||= @solutions.map { |translations| 
      [
        map = self.class.generate_mapping(translations), 
        @tokens.map { |word| @dictionary.print_word(word.tr(*map)) }.join(' ')
      ] 
    }.sort { |a, b| a[1] <=> b[1] }
  end
end
