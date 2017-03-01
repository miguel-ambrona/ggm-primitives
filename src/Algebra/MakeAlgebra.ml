open Core_kernel.Std
open Abbrevs
open Util

let prime = ref None

let get_prime() =
  init_relic();
  match !prime with
  | None ->
     let p = R.g1_ord () in
     assert ((R.bn_equal p (R.g2_ord ())) && (R.bn_equal p (R.gt_ord ())));
     prime := Some p;
     p
  | Some p -> p

module Zp = struct
  type t = R.bn
  let p = get_prime()
  let characteristic = p
  let add a b = R.bn_mod (R.bn_add a b) p
  let neg a = R.bn_mod (R.bn_neg a) p
  let mul a b = R.bn_mod (R.bn_mul a b) p
  let inv a =
    let (d,u,_v) = R.bn_gcd_ext a p in
    if R.bn_equal d (R.bn_one ()) then R.bn_mod u p
    else failwith ("Inverse of " ^ (R.bn_write_str a ~radix:10)  ^
                     " mod " ^ (R.bn_write_str p ~radix:10) ^ " does not exist")
  let one = R.bn_one ()
  let zero = R.bn_zero ()

  let equal = R.bn_equal
  let compare = R.bn_cmp

  let samp () = R.bn_rand_mod p
  let to_string t = R.bn_write_str (R.bn_mod t p) ~radix:10
  let of_string str = R.bn_mod (R.bn_read_str str ~radix:10) p
  let of_int i = R.bn_mod (R.bn_read_str (string_of_int i) ~radix:10) p
  let pp fmt a = F.fprintf fmt "%s" (R.bn_write_str a ~radix:10)
end

module G1 = struct
  type t = R.g1

  let add  = R.g1_add
  let neg  = R.g1_neg
  let mul  = R.g1_mul
  let gen  = R.g1_gen ()
  let zero = R.g1_infty ()
  let samp = R.g1_rand

  let equal = R.g1_equal

  let to_string a = R.g1_write_bin ~compress:false a |> to_base64
  let of_string str = R.g1_read_bin (from_base64 str)
  let pp fmt a = F.fprintf fmt "%s" (to_string a)
end

module G2 = struct
  type t = R.g2

  let add  = R.g2_add
  let neg  = R.g2_neg
  let mul  = R.g2_mul
  let gen  = R.g2_gen ()
  let zero = R.g2_infty ()
  let samp = R.g2_rand

  let equal = R.g2_equal

  let to_string a = R.g2_write_bin ~compress:false a |> to_base64
  let of_string str = R.g2_read_bin (from_base64 str)
  let pp fmt a = F.fprintf fmt "%s" (to_string a)
end

module Gt = struct
  type t = R.gt
  let add  = R.gt_mul
  let neg  = R.gt_inv
  let mul  = R.gt_exp
  let gen  = R.gt_unity ()
  let zero = R.gt_zero ()
  let samp = R.gt_rand

  let equal = R.gt_equal

  let to_string a = R.gt_write_bin ~compress:false a |> to_base64
  let of_string str = R.gt_read_bin (from_base64 str)
  let pp fmt a = F.fprintf fmt "%s" (to_string a)
end
             
module MyBilinearGroup = struct
  module Zp = Zp
  module G1 = G1
  module G2 = G2
  module Gt = Gt
  let e = R.e_pairing
end
