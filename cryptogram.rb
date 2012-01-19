def group_words(words)
  words.inject(Hash.new []) do |memo, w| 
    w = w[0..-2] if w[-1] == '%'
    
    memo.tap do
      memo[w.length] += [w]
    end
  end
end

def mapping(translations)
  alphabet = ('a'..'z').to_a.join
  
  (map = [alphabet, '.' * alphabet.length]).tap do
    translations.each do |k, v| 
      k.split('').each_with_index do |c, i| 
        key_char_alphabet_index = map[0].index(c)
        current_value           = map[1][key_char_alphabet_index]
        
        if current_value == '.'
          map[1][key_char_alphabet_index] = v[i]
        elsif current_value != v[i]
          raise "Conflicting values #{current_value} and #{v[i]} for index #{key_char_alphabet_index} in map #{map.inspect}"
        end
      end
    end
  end
end

def find_candidates(cryptographic_word, translations)
  word_re = cryptographic_word.tr(*mapping(translations))
  
  if word_re.include?('.')
    [word_re, @grouped_words[cryptographic_word.length].grep(/#{word_re}/)]
  else
    [word_re, [word_re]]
  end
end

def find_cryptogram_solutions(cryptogram, translations = {}, level = 0)
  return translations if cryptogram.empty?
  
  sorted_cryptogram = cryptogram.sort { |a, b| b.length <=> a.length }
  
  sorted_cryptogram.each do |cryptographic_word|
    puts ">>> Looking for solutions for word '#{cryptographic_word}'..." if @debug
    
    matches = find_candidates(cryptographic_word, translations)
    
    puts "#{matches[1].length} matches found for #{cryptographic_word} and level #{level}" if @debug
    
    solutions = matches[1].map { |cm|
      find_cryptogram_solutions(sorted_cryptogram[1..-1], translations.merge(cryptographic_word => cm), level + 1) rescue nil
    }.compact.flatten
    
    if !solutions.empty?
      puts "Solutions found: #{solutions.inspect}" if @debug
      
      return solutions
    end
  end
  
  nil
end

def build_phrases
  @phrases = @translations.map { |t| 
    [
      map = mapping(t), 
      @cryptogram.map { |w| w.tr(*map) }.join(' ')
    ] 
  }.sort do |a, b| 
    (cmp = b[1].size <=> a[1].size) != 0 ? cmp : (a[1] <=> b[1])
  end
end

def print_phrases
  build_phrases
  
  puts @phrases.map { |p| p[1] }.join("\n")
end

@words          ||= File.read('./12dicts-4.0/2of12inf.txt').split
@grouped_words  ||= group_words(@words)

@cryptogram = %w(
  zfsbhd
  bd
  lsf
  xfe
  ofsr
  bsdxbejrbls
  sbsfra
  sbsf
  xfe
  ofsr
  xfedxbejrbls
  rqlujd
  jvwj
  fpbdls
)

@debug = false

@translations = find_cryptogram_solutions(@cryptogram)
