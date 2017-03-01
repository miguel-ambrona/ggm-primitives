open Abbrevs
open IBE
open MakeAlgebra

(* ** Test *)

module B = MyBilinearGroup
module IBE = PetitIBE (B)

let test () =
  let t1 = Unix.gettimeofday() in
  let mpk, msk = IBE.setup () in
  let id = B.Zp.samp () in
  let msg = IBE.rand_msg () in  
  let ct = IBE.enc mpk id msg in
  let sk  = IBE.keygen mpk msk id in
  let sk' = IBE.keygen mpk msk B.Zp.(add id one) in
  
  let dec  = IBE.dec mpk sk  ct in
  let dec' = IBE.dec mpk sk' ct in
  let t2 = Unix.gettimeofday() in

  if (B.Gt.equal msg dec) && not (B.Gt.equal msg dec') then
    F.printf "IBE test succedded!\t Time: \027[32m%F\027[0m seconds\n"
      (Pervasives.ceil ((100.0 *. (t2 -. t1))) /. 100.0)
  else failwith "IBE test failed"
