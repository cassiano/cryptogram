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
      # Get rid of trailing '%'s.
      token = token[0..-2] if token[-1] == '%'

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
              raise "Duplicate value #{v[i]} in map #{map.inspect}"
            end
          elsif current_value != v[i]
            raise "Conflicting values #{current_value} and #{v[i]} for index #{key_char_alphabet_index} in map #{map.inspect}"
          end
        end
      end
    end
  end

  attr_reader :tokens, :known_translations, :solutions

  def initialize(tokens, known_translations = {})
    @tokens             = tokens
    @known_translations = known_translations
  end

  def solve!(level = 0)
    return self.known_translations if self.tokens.empty?

    sorted_tokens = self.tokens.sort { |b, a| a.length <=> b.length }

    sorted_tokens.each do |token|
      puts ">>> Looking for solutions for token '#{token}' and known translations #{self.known_translations.inspect}..." if @debug

      matches = self.find_candidates(token)

      puts "#{matches[1].length} matches found for #{token} and level #{level}" if @debug

      @solutions = matches[1].map { |cm|
        Cryptogram.new(sorted_tokens[1..-1], self.known_translations.merge(token => cm)).solve!(level + 1) rescue nil
      }.compact.flatten

      if !self.solutions.empty?
        puts "Solutions found: #{self.solutions.inspect}" if @debug

        return self.solutions
      end
    end

    nil
  end

  def mapping
    self.class.generate_mapping(self.known_translations)
  end

  def phrases
    self.solutions.map { |translations| 
      [
        map = self.class.generate_mapping(translations), 
        self.tokens.map { |w| w.tr(*map) }.join(' ')
      ] 
    }.sort do |a, b| 
      (cmp = b[1].size <=> a[1].size) != 0 ? cmp : (a[1] <=> b[1])
    end
  end

  def print_phrases
    self.phrases.each { |p| puts "\"#{p[1]}\" (#{p[0][1]})" }

    nil
  end

  protected

  def find_candidates(token)
    token_re = token.tr(*self.mapping)

    if token_re.include?('.')
      [token_re, self.class.optimized_dictionary[token.signature[0]].grep(/#{token_re}/)]
    else
      [token_re, [token_re]]
    end
  end
end
