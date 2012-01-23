require 'irb'
require 'wirble'

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

class Cryptogram
  def self.dictionary
    @@dictionary ||= File.read('./12dicts-4.0/2of12inf.txt').split
  end
  
  def self.optimized_dictionary
    @@optimized_dictionary ||= self.dictionary.inject Hash.new([]) do |memo, token| 
      # Get rid of non-alphabetic characters.
      token.gsub!(/[^a-zA-Z]/, '')

      memo.tap do
        memo[token.signature[0]] += [token]
      end
    end
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

  def self.print_word(word)
    color = 
        word.include?('.') ?
          :yellow :
          self.optimized_dictionary[word.signature[0]].map(&:downcase).include?(word) ?
            :green :
            :red
    
    Wirble::Colorize.colorize_string(word, color)
  end

  attr_reader :tokens, :initial_translations, :solutions

  # Constructor.
  def initialize(tokens, initial_translations = {})
    @tokens               = tokens
    @initial_translations = initial_translations
  end

  def solve!(options = {})
    options = {
      :level  => 0,
      :debug  => false
    }.merge(options)
    
    if self.tokens.empty? 
      return self.has_valid_mapping? ? self.initial_translations : nil
    end

    sorted_tokens = self.tokens.sort do |a, b|
      if (cmp = b.length <=> a.length) != 0
        cmp
      elsif (cmp = a.signature[1].length <=> b.signature[1].length) != 0
        cmp
      else
        self.class.optimized_dictionary[a.signature[0]].size <=> self.class.optimized_dictionary[b.signature[0]].size
      end
    end
    
    sorted_tokens.each do |token|
      puts ">>> Looking for solutions for token '#{token}' and initial translations #{self.initial_translations.inspect}..." if options[:debug]

      if (candidates = self.find_candidates(token))
        puts "#{candidates[1].length} candidates found (#{candidates[1].join(', ')}) for #{token} and level #{options[:level]}" if options[:debug]

        @solutions = candidates[1].inject([]) { |memo, candidate|
          memo.tap do
            cryptogram = Cryptogram.new(sorted_tokens[1..-1], self.initial_translations.merge(token => candidate))
          
            memo << cryptogram.solve!(:level => options[:level] + 1, :debug => options[:debug])
          end
        }.compact.flatten

        if !@solutions.empty?
          puts "Solutions found: #{@solutions.inspect}" if options[:debug]

          return @solutions
        end
      end
    end

    nil
  end

  def print_phrases
    self.phrases.each_with_index { |phrase, i| puts "(#{'%04d' % (i+1)}) #{phrase[1]} [#{phrase[0][1]}]" }
    nil
  end

  protected

  def find_candidates(token)
    return nil unless self.has_valid_mapping?
    
    token_re = token.tr(*self.mapping)

    if token_re.include?('.')
      # token_optimized_re = (tmp = token_re.gsub('.', '')).empty? ?
      #   token_re :
      #   token_re.gsub('.', "[^#{tmp.signature[1]}]")
      # 
      # [token_re, self.class.optimized_dictionary[token.signature[0]].grep(/#{token_optimized_re}/i).map(&:downcase).uniq]

      [token_re, self.class.optimized_dictionary[token.signature[0]].grep(/#{token_re}/i).map(&:downcase).uniq]
    else
      [token_re, [token_re]]
    end
  end

  def mapping
    @mapping ||= (self.class.generate_mapping(self.initial_translations) rescue nil)
  end

  def has_valid_mapping?
    !!self.mapping
  end
  
  def phrases
    raise "Please call :solve! to find all possible solutions!" unless self.solutions
    
    @phrases ||= self.solutions.map { |translations| 
      [
        map = self.class.generate_mapping(translations), 
        self.tokens.map { |w| self.class.print_word(w.tr(*map)) }.join(' ')
      ] 
    }.sort { |a, b| a[1] <=> b[1] }
  end
end
