# Cryptogram sources: "Best of Ruby Quiz" book & One Across website (http://www.oneacross.com/cryptograms)

require 'benchmark'

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

# 19 solutions found in 0.7328958511352539 seconds.
# Best phrase: "genius is one per cent inspiration ninety nine per cent perspiration t.o.as a..a e.ison"
# Correct phrase: "Genius is one percent inspiration, ninety-nine percent perspiration. Thomas Alva Edison"
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

# ? solutions found!
# Best phrase: "mark had a little lamb mother goose"
# Correct phrase: "Mary had a little lamb. Mother Goose"
# @cryptogram = %w(
#   gebo
#   tev
#   e
#   cwaack
#   cegn
#   gsatkb
#   ussyk
# )

# ? solutions found!
# Best phrase: "the difference between the almost right word and the right word is the difference between the lightning bug and the lightning mark twain"
# Correct phrase: "The difference between the right word and the almost right word is the difference between lightning and a lightning bug. Mark Twain"
# @cryptogram = %w(
#   mkr
#   ideerqruhr
#   nrmsrru
#   mkr
#   ozgcym
#   qdakm
#   scqi
#   oui
#   mkr
#   qdakm
#   scqi
#   dy
#   mkr
#   ideerqruhr
#   nrmsrru
#   mkr
#   zdakmudua
#   nja
#   oui
#   mkr
#   zdakmudua
#   goqb
#   msodu
# )

# ? solutions found!
# Best phrase: "psychotherapy is the theory that the patient will probably get well anyhow and is certainly a damn fool h l menc.en"
# Correct phrase: "Psychotherapy is the theory that the patient will probably get well anyhow and is certainly a damn fool. H L Mencken"
# @cryptogram = %w(
#   vidkrqbrnfzvd
#   wi
#   brn
#   brnqfd
#   brzb
#   brn
#   vzbwnhb
#   ywee
#   vfqjzjed
#   tnb
#   ynee
#   zhdrqy
#   zhp
#   wi
#   knfbzwhed
#   z
#   pzch
#   sqqe
#   r
#   e
#   cnhkanh
# )

# ? solutions found!
# Best phrase: ".ucharme s precept opportunity always knocks at the least opportune moment"
# Correct phrase: "Ducharme's Precept: Opportunity Always Knocks At The Least Opportune Moment."
# @cryptogram = %w(
#   vkoxcenh 
#   i 
#   qehohqp           
#   fqqfepkbzpr 
#   cgdcri  
#   mbfomi  
#   cp  
#   pxh 
#   ghcip 
#   fqqfepkbh
#   nfnhbp
# )

# ? solutions found! (hard one)
# Best phrase: "?"
# Correct phrase: "?"
# @cryptogram = %w(
#   rbl 
#   jfnzlopl  
#   xvlp  
#   fvr 
#   bezl  
#   segp
#   nr  
#   bep 
#   beknrp  
#   efx 
#   beknrp  
#   ief 
#   kl  
#   kovwlf
# )

# ? solutions found! (hard one)
# Best phrase: "?"
# Correct phrase: "?"
# @cryptogram = %w(
#   ftyw
#   uwmb
#   yw
#   ilwwv
#   qvb
#   bjtvi
#   fupxiu
#   t
#   dqvi
#   tv
#   yj
#   huqtvd
#   mtrw
#   fuw
#   dwq
#   bjmqv
#   fupyqd
# )

@debug = false

puts Benchmark.realtime { @translations = find_cryptogram_solutions(@cryptogram) }
