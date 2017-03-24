open Abbrevs
open AlgStructures
open IBE_Interface

(* ** Identity-Based Encryption *)

(* *** Petit-IBE *)

module PetitIBE (B : BilinearGroup) : IBE = struct

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

(* *** Boneh-Boyen *)

module BonehBoyen (B : BilinearGroup) : IBE = struct

  type id  = B.Zp.t
  type mpk = B.Gt.t * (id -> B.G1.t) (* e(g1,g2)^ab, f(id) = u^id*h, where u = g1^a *)
  type msk = B.G1.t                  (* g1^ab *)
  type sk  = B.G1.t * B.G2.t
  type ct  = B.G2.t * B.G1.t * B.Gt.t
  type msg = B.Gt.t

  let setup () =
    let a = B.Zp.samp () in
    let b = B.Zp.samp () in
    let u = B.G1.(mul gen a) in
    let h = B.G1.samp () in
    let msk = B.G1.(mul u b) in
    let mpk = (B.(e msk B.G2.gen), (fun id -> B.G1.(add (mul u id) h))) in
    (mpk, msk)

  let enc mpk id msg =
    let (gt_ab, f) = mpk in
    let s = B.Zp.samp () in
    let ct1 = B.G2.(mul gen s) in
    let ct2 = B.G1.(mul (f id) s) in
    let ct3 = B.Gt.(add msg (mul gt_ab s)) in
    (ct1, ct2, ct3)

  let keygen mpk msk id =
    let (_, f) = mpk in
    let r = B.Zp.samp () in
    let sk1 = B.G1.(add msk (mul (f id) r)) in
    let sk2 = B.G2.(mul gen r) in
    (sk1, sk2)

  let dec _mpk (sk1,sk2) (ct1,ct2,ct3) =
    B.Gt.(add ct3 (add (neg (B.e sk1 ct1)) (B.e ct2 sk2)))

  let rand_msg = B.Gt.samp

  (* *** String conversions *)

  let sep = "|"

  let string_of_mpk (mpk1,f) =
    let h = f B.Zp.zero in
    let u = B.G1.(add (f B.Zp.one) (neg h)) in
    (B.Gt.to_string mpk1) ^ sep ^ (B.G1.to_string u) ^ (B.G1.to_string h)

  let string_of_msk msk = B.G1.to_string msk
  let string_of_id id = B.Zp.to_string id
  let string_of_sk (sk1,sk2) = (B.G1.to_string sk1) ^ sep ^ (B.G2.to_string sk2)
  let string_of_ct (ct1,ct2,ct3) =
    (B.G2.to_string ct1) ^ sep ^ (B.G1.to_string ct2) ^ sep ^ (B.Gt.to_string ct3)
  let string_of_msg msg = B.Gt.to_string msg

  let from_string f1 f2 str =
    match S.split ~on:(Char.of_string sep) str with
    | a :: b :: [] -> (f1 a, f2 b)
    | _ -> failwith "invalid string"

  let from_string3 f1 f2 f3 str =
    match S.split ~on:(Char.of_string sep) str with
    | a :: b :: c :: [] -> (f1 a, f2 b, f3 c)
    | _ -> failwith "invalid string"

  let mpk_of_string str =
    let mpk1, u, h = from_string3 B.Gt.of_string B.G1.of_string B.G1.of_string str in
    (mpk1, (fun id -> B.G1.(add (mul u id) h)))

  let msk_of_string = B.G1.of_string
  let id_of_string  = B.Zp.of_string
  let sk_of_string  = from_string  B.G1.of_string B.G2.of_string
  let ct_of_string  = from_string3 B.G2.of_string B.G1.of_string B.Gt.of_string
  let msg_of_string = B.Gt.of_string
end


(* *** Boneh-Franklin *)

module BonehFranklin (B : BilinearGroup) : IBE = struct

  type id  = string
  type mpk = B.G2.t
  type msk = B.Zp.t
  type sk  = B.G1.t
  type ct  = B.G2.t * B.Gt.t
  type msg = B.Gt.t

  let h id =
    let s = (SHA.sha256 id) ^ (SHA.sha256 (id ^ "0")) |> Util.ascii_of_hex in
    let s = "\004" ^ (S.slice s 0 64) |> Util.to_base64 in
    B.G1.of_string s

  let setup () =
    let msk = B.Zp.samp () in
    let mpk = B.G2.(mul gen msk) in
    (mpk, msk)

  let enc mpk id msg =
    let r = B.Zp.samp () in
    let ct1 = B.G2.(mul gen r) in
    let ct2 = B.Gt.(add msg (mul (B.e (h id) mpk) r)) in
    (ct1, ct2)

  let keygen _mpk msk id =
    B.G1.mul (h id) msk

  let dec _mpk sk (ct1,ct2) =
    B.Gt.(add ct2 (B.e sk ct1))

  let rand_msg = B.Gt.samp

  (* *** String conversions *)

  let sep = "|"

  let string_of_mpk mpk = B.G2.to_string mpk
  let string_of_msk msk = B.Zp.to_string msk
  let string_of_id id = id
  let string_of_sk sk = B.G1.to_string sk
  let string_of_ct (ct1,ct2) = (B.G2.to_string ct1) ^ sep ^ (B.Gt.to_string ct2)
  let string_of_msg msg = B.Gt.to_string msg

  let from_string f1 f2 str =
    match S.split ~on:(Char.of_string sep) str with
    | a :: b :: [] -> (f1 a, f2 b)
    | _ -> failwith "invalid string"

  let mpk_of_string = B.G2.of_string
  let msk_of_string = B.Zp.of_string
  let id_of_string  = string_of_id
  let sk_of_string  = B.G1.of_string
  let ct_of_string  = from_string B.G2.of_string B.Gt.of_string
  let msg_of_string = B.Gt.of_string
end
