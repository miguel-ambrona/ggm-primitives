open Abbrevs

(* ** Groups *)
module type Group = sig
  type t
  val add  : t -> t -> t
  val neg  : t -> t
  val mul  : t -> R.bn -> t
  val gen  : t
  val zero : t
  val samp : unit -> t

  val equal : t -> t -> bool

  val to_string : t -> string
  val of_string : string -> t
  val pp : F.formatter -> t -> unit
end

(* ** Fields *)
module type Field = sig
  type t
  val characteristic  : R.bn
  val add : t -> t -> t
  val neg : t -> t
  val mul : t -> t -> t
  val inv : t -> t
  val one  : t
  val zero : t

  val equal : t -> t -> bool
  val compare : t -> t -> int

  val samp      : unit -> t
  val to_string : t -> string
  val of_string : string -> t
  val of_int : int -> t
  val pp : F.formatter -> t -> unit
end

(* ** Bilinear Groups *)
module type BilinearGroup =
  sig
    module Zp : Field with type t = R.bn
    module G1 : Group
    module G2 : Group
    module Gt : Group
    val e  : G1.t -> G2.t -> Gt.t
end
