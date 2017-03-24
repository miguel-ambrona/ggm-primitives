open Abbrevs
open IBE_Interface
open IBE
open MakeAlgebra
       
(* ** Test *)

module B = MyBilinearGroup
module IBE1 = PetitIBE (B)
module IBE2 = BonehBoyen (B)

let get_ibe = function
  | 1 -> (module PetitIBE (B) : IBE)
  | 2 -> (module BonehBoyen (B) : IBE)
  | 3 -> (module BonehFranklin (B) : IBE)
  | _ -> failwith "Unknown IBE"

let get_name = function
  | 1 -> "Petit-IBE"
  | 2 -> "Boneh-Boyen"
  | 3 -> "Boneh-Franklin"
  | _ -> "Unknown IBE"
                  
let test_iteration ~print k =
  let module IBE = (val get_ibe k) in
  
  let t1 = Unix.gettimeofday() in
  let mpk, msk = IBE.setup () in
  let id_number = B.Zp.samp () in
  let id = IBE.id_of_string (B.Zp.to_string id_number) in
  let id' = IBE.id_of_string (B.Zp.to_string B.Zp.(add id_number one)) in
  let msg = IBE.rand_msg () in  
  let ct = IBE.enc mpk id msg in
  let sk  = IBE.keygen mpk msk id in
  let sk' = IBE.keygen mpk msk id' in
  
  let dec  = IBE.dec mpk sk  ct in
  let dec' = IBE.dec mpk sk' ct in
  let t2 = Unix.gettimeofday() in

  if print then
    if ((IBE.string_of_msg msg) = (IBE.string_of_msg dec) &&
          not ((IBE.string_of_msg msg) = (IBE.string_of_msg dec'))) then
      F.printf "%s test succedded!\t Time: \027[32m%F\027[0m seconds\n"
               (get_name k) (Pervasives.ceil ((100.0 *. (t2 -. t1))) /. 100.0)
    else
      (F.printf "%s IBE test failed" (get_name k);
       F.print_flush ();
       assert false
      )
  else
    ()

let test () =
  let n_schemes = 3 in
  let rec loop k =
    if k > n_schemes then ()
    else
      let t1 = Unix.gettimeofday() in
      (for _i = 1 to 10 do test_iteration ~print:false k; done);
      let t2 = Unix.gettimeofday() in
      F.printf "Time %s: \t %F s\n" (get_name k) (Pervasives.ceil ((100.0 *. (t2 -. t1))) /. 100.0);
      F.print_flush ();
      loop (k+1)
  in
  loop 1

       
