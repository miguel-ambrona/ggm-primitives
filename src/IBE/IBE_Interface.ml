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
