(**
{9 PRIME1: Prime Generator}

Peter wants to generate some prime numbers for his cryptosystem. Help him! Your task is to generate all prime 
numbers between two given numbers!

{8 Input}

The input begins with the number [t] of test cases in a single line ([t<=10]). In each of the next t lines 
there are two numbers [m] and [n] ([1 <= m <= n <= 1000000000, n-m<=100000]) separated by a space.

{8 Output}

For every test case print all prime numbers [p] such that [m <= p <= n], one number per line, test cases 
separated by an empty line.

{8 Example}

{b Input:}
{[
2
1 10
3 5]}

{b Output:}
{[
2
3
5
7

3
5]}

{b Warning: large Input/Output data, be careful with certain languages (though most should be OK if the 
algorithm is well designed)}
*)

(** Returns [true] if [x] is even, false if it is odd. *)
let even x = x mod 2 = 0;;

(** Returns [true] if [x] is odd, false if it is even. *)
let odd x = x mod 2 = 1;;

(** Calculates [x]{^ n} using the squaring algorithm.
  @see <http://en.wikipedia.org/wiki/Exponentiation_by_squaring#Squaring_algorithm> Description of the algorithm
*)
let rec expt x n = match n with
    0 -> 1
  | p when odd p -> x * expt x (n - 1)
  | p when even p -> let hp = expt x (n / 2) in (hp * hp)
  | _ -> failwith "Internal error";;

(** Calculates the greatest common divisor between [x] and [y] using the binary GCD algorithm.
  @see <http://en.wikipedia.org/wiki/Binary_GCD_algorithm> Description of the algorithm
*)
let gcd x y = 
  let rec loop x y k =
  match x, y with
      0, 0                                 -> failwith "GCD 0 0 is undefined"
    | 0, v                                 -> v
    | u, 0                                 -> 0
    | u, v when u == v                     -> v * expt 2 k
    | u, v when even u && even v           -> loop (u / 2) (v / 2) (k + 1)
    | u, v when even u &&  odd v           -> loop (u / 2) v k
    | u, v when  odd u && even v           -> loop u (v / 2) k
    | u, v when  odd u &&  odd v && u >= v -> loop ((u - v) / 2) v k
    | u, v when  odd u &&  odd v && u <  v -> loop ((v - u) / 2) u k
    | _                                    -> failwith "Internal error"
  in
  loop x y 0;;
  
(** Decomposes a value n into two values s and d, such that [d * 2]{^ s}[ = n] *)
let decompose_s_d n =
  let rec decompose_step s d =
    if odd d then s, d
    else decompose_step (s + 1) (d / 2)
  in decompose_step 0 n;;

(** Determines the value of [b]{^ e}[ % m] using the right-to-left binary method 

    @see <http://en.wikipedia.org/wiki/Modular_exponentiation#Right-to-left_binary_method> Algorithm Description
*)
let mod_expt b e m =
  let next_b b = (b * b) mod m in
  let next_e e = e lsr 1 in
  let rec mod_expt_step b e result =
    if e = 0 then result
    else if odd e then mod_expt_step (next_b b) (next_e e) ((result * b) mod m)
    else mod_expt_step (next_b b) (next_e e) result
  in mod_expt_step b e 1;;
  
(** Evaluates whether a number is prime using a naive method: Loop from [2] to [sqrt(n)], if any number has a 
  gcd with [n] > 1, then it [n] is composite.  If no such numbers are found, [n] is prime.
*)
let naive_prime n =
  let check p = gcd p n = 1 in
  let rec naive_prime_step n p =
    if p = 0 then true
    else if not (check p) then false
    else naive_prime_step n (p - 1)
  in 
  if n < 2 then false
  else naive_prime_step n (int_of_float (sqrt (float_of_int n)));;

(** Returns a list of all values inside the given range (inclusive) for which the predicate is true *)
let filtered_range min_val max_val predicate =
  let rec filtered_range_loop cur_val =
    if cur_val > max_val then []
    else if predicate cur_val then cur_val :: filtered_range_loop (cur_val + 1)
    else filtered_range_loop (cur_val + 1)
  in filtered_range_loop min_val;;
  
(** Small primes, used to check divisibility for larger primes *)
let small_primes = filtered_range 1 257 naive_prime;;

(** Determines whether n is a weak probable prime base a using fermat's little theorem.  In particular, 
  checks whether [a]{^ (n - 1)}[ % n = 1].  If so, it is probable that [n] is prime, but not definite.  If 
  not, n is definitely composite.
*)
let probable_prime n a = mod_expt a (n - 1) n = 1;;

(** Main primality algorithm *)
let prime n =
  if n = 1 then false
  else if n = 2 then true
  else if even n then false
  else if n <= 257 then List.exists (fun x -> n = x) small_primes
  else if not (probable_prime n 3) then false
  else if List.exists (fun x -> n mod x = 0) small_primes then false
  else 
    let list_of_a = 
      match n with
        p when p < 137653 -> [2; 3]
      | p when p < 9080191 -> [31; 73]
      | p -> [2; 3; 5; 7; 11; 13; 17] in
    let s, d = decompose_s_d (n - 1) in
    let rec check_a_loop r x =
      if r = s then true
      else if x = 1 then false
      else if x = (n - 1) then true
      else check_a_loop (r + 1) (mod_expt x 2 n) in
    let check_a a =
      let x = mod_expt a d n in
        if x = 1 || x = (n - 1) then true
        else check_a_loop 1 (mod_expt x 2 n) in
    (List.for_all check_a list_of_a);;

(** Prints all prime values between [min_val] and [max_val] inclusive to stdout. *)
let print_primes min_val max_val =
  for i = min_val to max_val do
    if prime i then (print_int i; print_newline ())
  done;;

(** Main code **)
let num_records = read_int () in
  for i = 1 to num_records do
    Scanf.scanf " %d %d" print_primes;
    print_newline ()
  done;;
