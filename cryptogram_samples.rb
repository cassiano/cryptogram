# Cryptogram sources: "Best of Ruby Quiz" book & One Across website (http://www.oneacross.com/@cryptograms)

require 'benchmark'
require 'cryptogram'

def avg_time(iterations = 10, &block)
  total_time = 0.0
  iterations.times { total_time += Benchmark.realtime(&block) }
  total_time / iterations
end

@cryptograms = {}

# 279 solutions found in 0.5403711080551148 seconds.
# Best phrase: "mark had a little lamb mother goose"
# Correct phrase: "Mary had a little lamb. Mother Goose"
@cryptograms[:mary] = Cryptogram.new %w(
  gebo
  tev
  e
  cwaack
  cegn
  gsatkb
  ussyk
)

# 19 solutions found in 0.07852108836174011 seconds
# Best phrase: "genius is one per cent inspiration ninety nine per cent perspiration t.o.as a..a e.ison"
# Correct phrase: "Genius is one percent inspiration, ninety-nine percent perspiration. Thomas Alva Edison"
@cryptograms[:genius] = Cryptogram.new %w(
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

# 1 solution found in 0.019197819232940675 seconds
# Best phrase: "the difference between the almost right word and the right word is the difference between the lightning bug and the lightning mark twain"
# Correct phrase: "The difference between the right word and the almost right word is the difference between lightning and a lightning bug. Mark Twain"
@cryptograms[:right_word] = Cryptogram.new %w(
  mkr
  ideerqruhr
  nrmsrru
  mkr
  ozgcym
  qdakm
  scqi
  oui
  mkr
  qdakm
  scqi
  dy
  mkr
  ideerqruhr
  nrmsrru
  mkr
  zdakmudua
  nja
  oui
  mkr
  zdakmudua
  goqb
  msodu
)

# 7 solutions found in 0.03635883331298828 seconds
# Best phrase: "psychotherapy is the theory that the patient will probably get well anyhow and is certainly a damn fool h l menc.en"
# Correct phrase: "Psychotherapy is the theory that the patient will probably get well anyhow and is certainly a damn fool. H L Mencken"
@cryptograms[:psychotherapy] = Cryptogram.new %w(
  vidkrqbrnfzvd
  wi
  brn
  brnqfd
  brzb
  brn
  vzbwnhb
  ywee
  vfqjzjed
  tnb
  ynee
  zhdrqy
  zhp
  wi
  knfbzwhed
  z
  pzch
  sqqe
  r
  e
  cnhkanh
)

# 1 solution found in 0.006327975034713745 seconds
# Best phrase: ".ucharme s precept opportunity always knocks at the least opportune moment"
# Correct phrase: "Ducharme's Precept: Opportunity Always Knocks At The Least Opportune Moment."
@cryptograms[:opportunity] = Cryptogram.new %w(
  vkoxcenh 
  i 
  qehohqp           
  fqqfepkbzpr 
  cgdcri  
  mbfomi  
  cp  
  pxh 
  ghcip 
  fqqfepkbh
  nfnhbp
)

# ? solutions found! (hard one)
# Best phrase: "?"
# Correct phrase: "?"
@cryptograms[:unknown1] = Cryptogram.new %w(
  rbl 
  jfnzlopl  
  xvlp  
  fvr 
  bezl  
  segp
  nr  
  bep 
  beknrp  
  efx 
  beknrp  
  ief 
  kl  
  kovwlf
)

# ? solutions found! (hard one)
# Best phrase: "?"
# Correct phrase: "?"
@cryptograms[:unknown2] = Cryptogram.new %w(
  ftyw
  uwmb
  yw
  ilwwv
  qvb
  bjtvi
  fupxiu
  t
  dqvi
  tv
  yj
  huqtvd
  mtrw
  fuw
  dwq
  bjmqv
  fupyqd
)

# Preload the optimized dictionary.
Cryptogram.optimized_dictionary

puts avg_time(1) { @cryptograms[:right_word].solve! }

@cryptograms[:right_word].print_phrases
