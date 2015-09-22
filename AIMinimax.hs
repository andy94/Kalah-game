module AIMinimax where

import Board
import Consecutive
import Interactive

{-
   Tipul 'Tree s a', al arborilor minimax, unde 's' reprezintă
   tipul stărilor (pentru joc, Board), iar 'a', tipul acțiunilor (în cazul de 
   față, al mutărilor - pentru joc House).
-}

data Tree s a = Tree s [(a, Tree s a)] deriving Show

{-
    Întoarce casa aleasă de o euristică în contextul minimax, alături
    de configurația rezultată.
-}
step :: Board -> (House, Board)
step b = let tree = prune 4 (expand successors b); -- arbore de inaltime 4
			 eval = (fromIntegral . snd . scores)  -- functia de evaluare
		 in pick eval tree; -- calculeaza mutarea

{-
    Construiește un arbore minimax (eventual infinit), pornind de la funcția
    de generare a succesorilor unui nod și de la rădăcină.
-}
expand :: (s -> [(a, s)]) -> s -> Tree s a
expand succf b = let actionConf = succf b
				 in Tree b (map (\ entry -> (fst entry, expand succf (snd entry)) ) 
								actionConf )

{-
    Limitează un arbore la numărul de niveluri dat ca parametru.
-}
prune :: Int -> Tree s a -> Tree s a
prune h (Tree b succ) = if h <= 0 -- cazul de baza (radacina)
						then (Tree b [])
						else (Tree b (map (\ entry -> (fst entry, prune (h-1) (snd entry))) 
										  succ) )

{-
    Determină valoarea minimax a unui nod MAX. Funcția de evaluare statică
    este dată ca parametru.
-}
maximize :: Consecutive s => (s -> Float) -> Tree s a -> Float
maximize eval (Tree b succ) = if length succ == 0 -- daca nu are copii
							  then eval b -- atunci evalueaza
							  else 
							  let maxs = map (\ entry -> 
										  let (Tree newb newsucc) = snd entry 
										  in if newb >< b -- daca sunt consecutive
										  then maximize eval (snd entry)
										  else minimize eval (snd entry) ) succ
							  in maximum maxs; -- preia maxmul

{-
    Determină valoarea minimax a unui nod MIN. Funcția de evaluare statică
    este dată ca parametru.
-}
								   
minimize :: Consecutive s => (s -> Float) -> Tree s a -> Float
minimize eval (Tree b succ) = if length succ == 0 -- daca nu are copii
							  then eval b -- atunci evalueaza
							  else 
							  let mins = map (\ entry -> 
										  let (Tree newb newsucc) = snd entry 
										  in if newb >< b -- daca sunt consecutive
										  then minimize eval (snd entry)
										  else maximize eval (snd entry) ) succ
							  in minimum mins; -- preia minimul

{-
    Întoarce cheia copilului rădăcinii arborelui minimax, ales în conformitate
    cu principiul algoritmului. Funcția de evaluare statică este dată
    ca parametru.
-}
pick :: Consecutive s => (s -> Float) -> Tree s a -> (a, s)
pick eval (Tree b succ) =  let scores = map (\ entry -> 
						   -- creeaza perechi de tipul (scor, (mutare,tabla))
										  let newA = fst entry;
										      Tree newB _ = snd entry in
										  if b >< newB 
										  then (maximize eval (snd entry),(newA,newB)) 
										  else (minimize eval (snd entry),(newA,newB))) 
										succ;
						   -- extrage maximul:		
							   max = foldl (\ res entry -> if fst res > fst entry 
														   then res 
														   else entry) (-1,snd (head scores)) scores
						  in snd max;

{-
    Urmărește pas cu pas evoluția jocului, conform strategiei implementate.
-}
userMode :: IO ()
userMode = humanVsAI step

