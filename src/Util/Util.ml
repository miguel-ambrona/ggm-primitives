open Abbrevs


let g1_write = R.g1_write_bin ~compress:false
let g2_write = R.g2_write_bin ~compress:false
let gt_write = R.gt_write_bin ~compress:false

let mk_list el n =
  let rec aux output n =
    if n <= 0 then output
    else aux (el :: output) (n-1)
  in
  aux [] n

let to_base64 ?(split = false) string =
  let string64 = B64.encode string in
  let n = S.length string64 in
  let rec go output k =
    if (n - k < 64) then
      output ^ (S.slice string64 k n)
    else
      go (output ^ (S.slice string64 k (k+64)) ^ "\n") (k+64)
  in
  if not split then string64
  else go "" 0

let from_base64 string64 =
  let string = S.strip string64 in
  F.print_flush();
  B64.decode string

let pp_string fmt s = F.fprintf fmt "%s" s

let pp_int fmt i = F.fprintf fmt "%i" i

let is_initialized = ref false

let init_relic () =
  if !is_initialized then ()
  else
    (assert (R.core_init () = R.sts_ok);
     assert (R.pc_param_set_any () = R.sts_ok);
     is_initialized := true
    )

let ascii_of_hex hex =
  let explode s =
    let rec exp i l =
      if i < 0 then l else exp (i - 1) (s.[i] :: l) in
    exp (String.length s - 1) []
  in

  let convert = function
    | '0' -> 0 | '1' -> 1 | '2' -> 2  | '3' -> 3  | '4' -> 4  | '5' -> 5  | '6' -> 6  | '7' -> 7
    | '8' -> 8 | '9' -> 9 | 'a' -> 10 | 'b' -> 11 | 'c' -> 12 | 'd' -> 13 | 'e' -> 14 | 'f' -> 15
    | _ -> assert false
  in
  let rec aux output = function
    | [] -> output
    | a :: b :: rest -> aux (Char.(to_string (of_int_exn (16*(convert a)+(convert b)))) ^ output) rest
    | _ -> failwith "input must have an even number of characters"
  in
  aux "" (explode hex)
