/* Manually generated from x86tso.cat, with
   bug in definitions of "i1" and "i2" fixed */

module x86tso[E]
open exec_x86[E]

pred GHB[x : Exec_H] {
  // ppo  
  let po_ghb = (x.W -> x.W) & x.sb + (x.R -> x.(R+W)) & x.sb |

  // mfence
  let mfence = ((x.sb) & (x.ev -> x.F)) . (x.sb) |

  // implied barriers
  let poWR = (x.W -> x.R) & (x.sb) |
  let i1 = (x.ev -> x.locked) & poWR |
  let i2 = (x.locked -> x.ev) & poWR |
  let implied = i1 + i2 |
            
  let ghb = mfence + implied + po_ghb + rfe[x] + fr[x] + x.co |
  is_acyclic[ghb]
}

fun ppo[x : Exec_H] : E->E {
  (x.W -> x.W) & x.sb + (x.R -> x.(R+W)) & x.sb
}

pred consistent[x : Exec_H] {
  Uniproc[x]
  Atomic[x]
  GHB[x]
}

run {
  some x : Exec_H | storebuffering_H[x] && consistent[x] 
} for exactly 1 Exec, 4 E

run {
  some x : Exec_H | iriw_H1[x] && not (consistent[x])
} for exactly 1 Exec, 6 E

