module GradedMonad

//SNIPPET_START: monoid$
class monoid (a:Type) =
{
   op   : a -> a -> a;
   one  : a;
   properties: squash (
     (forall (x:a). op one x == x /\ op x one == x) /\
     (forall (x y z:a). op x (op y z) == op (op x y) z)
   );
}

instance monoid_nat_plus : monoid nat =
{
  op = (fun (x y:nat) -> x + y);
  one = 0;
  properties = ()
}
//SNIPPET_END: monoid$

//SNIPPET_START: graded_monad$
class graded_monad (#index:Type)
                   (m: monoid index -> index -> Type -> Type) = 
{
  return : #a:Type -> #im:monoid index -> x:a -> m im one a;
  
  bind   : #a:Type -> #b:Type -> #ia:index -> #ib:index -> #im:monoid index ->
           m im ia a -> 
           (a -> m im ib b) ->
           m im (op ia ib) b

}
//SNIPPET_END: graded_monad$

//we now have do notation for graded monads

//SNIPPET_START: counting$
let st (s:Type) monoid_nat_plus (count:nat) (a:Type) = s -> a & s
instance st_graded (s:Type) : graded_monad (st s) =
{ 
  return = (fun #a #im (x:a) s -> x, s);
  bind = (fun #a #b #ia #ib #im f g s -> let x, s = f s in g x s)
}

// A write-counting grade monad
let get #s : st s monoid_nat_plus 0 s = fun s -> s, s
let put #s (x:s) : st s monoid_nat_plus 1 unit = fun _ -> (), x
//SNIPPET_END: counting$

//SNIPPET_START: test$
let test #s =
  x <-- get #s ;
  put x

//F* + SMT automatically proves that the index simplifies to 2
let test2 #s : st s monoid_nat_plus 2 unit =
  x <-- get #s;
  put x;;
  put x
//SNIPPET_END: test$
