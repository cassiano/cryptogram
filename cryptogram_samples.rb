# Cryptogram sources: "Best of Ruby Quiz" book & One Across website (http://www.oneacross.com/cryptograms)

require 'benchmark'
require 'cryptogram'

def avg_time(iterations = 10, &block)
  total_time = 0.0
  iterations.times { total_time += Benchmark.realtime(&block) }
  total_time / iterations
end

@cryptograms = {}

# 279 solutions found in 0.7061140537261963 sec.
# Best phrase: "(0170) mark had a little lamb mother goose (trl.a.m...e..bk...ohgdi.s.)"
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

# 19 solutions found in 0.049610137939453125 sec.
# Best phrase: "(0014) genius is one per cent inspiration ninety nine per cent perspiration t.o.as a..a e.ison (yi.sre.u.a.o..c..tn....p.g)"
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

# 1 solution found in 0.01794576644897461 sec.
# Best phrase: "(0001) the difference between the almost right word and the right word is the difference between the lightning bug and the lightning mark twain (gkoif.mcduh.tba.rew.n...sl)"
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

# 7 solutions found in 0.029677152633666992 sec.
# Best phrase: "(0002) psychotherapy is the theory that the patient will probably get well anyhow and is certainly a damn fool h l menc.en (.tmylr.nsbc..e.dohfg.pi.wa)"
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

# 1 solution found in 0.008978843688964844 sec.
# Best phrase: "(0001) .ucharme s precept opportunity always knocks at the least opportune moment (.nawroles.u.kmctpy.....h.i)"
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

# 6 solutions found in 0.03467893600463867 sec.
# Best phrase: "(0006) in any world menu canada must be considered the vichyssoise of nations it s cold half french and difficult to stir stuart .eate (.suhcomief...lyt.avw.nbd.r)"
# Correct phrase: "In any world menu, Canada must be considered the vichyssoise of nations, it's cold, half-French, and difficult to stir. Stuart Keate"
@cryptograms[:canada] = Cryptogram.new %w(
  hv	
  rvo	
  tfznx	
  givc	
  ervrxr	
  gcbp	
  wi	
  efvbhxizix	
  pdi						
  shedobbfhbi	
  fj	
  vrphfvb
  hp
  b	
  efnx	
  drnj
  jzived
  rvx	
  xhjjhecnp	
  pf	
  bphz
  bpcrzp	
  uirpi
)

# 495 solutions found in 1.317655086517334 sec.
# Best phrase: "(0176) attack the enemy (c.....a.....e..t.k...nhm.y)"
# Correct phrase: "Attack the enemy!"
@cryptograms[:attack] = Cryptogram.new %w(
  gppgar 
  pwm 
  mvmxz
)

# ? solutions found! (hard one)
# Best phrase: "?"
# Correct phrase: "?"
@cryptograms[:unknown0] = Cryptogram.new %w(
  oky	
  bgdoiujy	
  gr	
  khtwj	
  yfhwquoc	
  iyxgaya	
  gj	
  okua							
  okwo	
  okyiy	
  ua	
  jg	
  twj	
  iywqqc	
  dqyzyi	
  nkg	
  kwa	
  jgo				
  rghjb	
  okwo	
  ky	
  ua	
  aohxub		
  puqmyio	
  l
  dkyaoyiagj
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

# Preload the dictionary and its optimized version.
Cryptogram.optimized_dictionary

@cryptograms.each do |(k, v)|
  puts "\n------------------- #{k} -------------------"
  puts avg_time(1) { v.solve! :debug => false }
  v.print_phrases
end
