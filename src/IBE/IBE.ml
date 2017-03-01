open Abbrevs
open AlgStructures

(* ** Identity-Based Encryption *)

module type IBE =
  sig
    type mpk
    type msk
    type id
    type sk
    type ct
    type msg
           
    val setup  : unit -> mpk * msk
    val enc    : mpk -> id -> msg -> ct
    val keygen : mpk -> msk -> id -> sk
    val dec    : mpk -> sk -> ct -> msg

    val rand_msg : unit -> msg
                                      
    val string_of_mpk : mpk -> string
    val string_of_msk : msk -> string
    val string_of_id  : id  -> string
    val string_of_sk  : sk  -> string
    val string_of_ct  : ct  -> string
    val string_of_msg : msg -> string
                                 
    val mpk_of_string : string -> mpk
    val msk_of_string : string -> msk
    val id_of_string  : string -> id
    val sk_of_string  : string -> sk
    val ct_of_string  : string -> ct
    val msg_of_string : string -> msg
end
    
module PetitIBE (B : BilinearGroup) = struct

  type mpk = B.G1.t * B.Gt.t
  type msk = B.Zp.t * B.G2.t
  type id  = B.Zp.t
  type sk  = B.G2.t
  type ct  = B.G1.t * B.Gt.t
  type msg = B.Gt.t

  let setup () =
    let alpha = B.Zp.samp () in
    let u = B.G2.samp () in
    let msk = (alpha, u) in
    let mpk = (B.G1.(mul gen alpha), B.(e G1.gen u)) in
    (mpk, msk)

  let enc mpk id msg =
    let (g1_a, gt_u) = mpk in
    let s = B.Zp.samp () in
    let ct1 = B.G1.(mul (add g1_a (mul gen id)) s) in
    let ct2 = B.Gt.(add msg (mul gt_u s)) in
    (ct1, ct2)

  let keygen _mpk msk id =
    let (alpha, u) = msk in
    B.(G2.mul u (Zp.(inv (add alpha id))))

  let dec _mpk sk (ct1,ct2) =
    B.Gt.(add (neg (B.e ct1 sk)) ct2)
           
  let rand_msg = B.Gt.samp
              
  (* *** String conversions *)

  let sep = "|"
           
  let string_of_mpk (mpk1,mpkt) = (B.G1.to_string mpk1) ^ sep ^ (B.Gt.to_string mpkt)
  let string_of_msk (alpha, u) = (B.Zp.to_string alpha) ^ sep ^ (B.G2.to_string u)
  let string_of_id id = B.Zp.to_string id
  let string_of_sk sk = B.G2.to_string sk
  let string_of_ct (ct1,ctt) = (B.G1.to_string ct1) ^ sep ^ (B.Gt.to_string ctt)
  let string_of_msg msg = B.Gt.to_string msg

  let from_string f1 f2 str =
    match S.split ~on:(Char.of_string sep) str with
    | a :: b :: [] -> (f1 a, f2 b)
    | _ -> failwith "invalid string"
    
  let mpk_of_string = from_string B.G1.of_string B.Gt.of_string
  let msk_of_string = from_string B.Zp.of_string B.G2.of_string
  let id_of_string  = B.Zp.of_string
  let sk_of_string  = B.G2.of_string
  let ct_of_string  = from_string B.G1.of_string B.Gt.of_string
  let msg_of_string = B.Gt.of_string
end
