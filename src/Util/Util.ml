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
