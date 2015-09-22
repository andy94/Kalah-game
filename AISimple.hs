-- Ursache Andrei - 322CA - 24 aprilie 2015
module AISimple where

import Board
import Interactive
{-
  Întoarce tabla rezultată din aplicarea acelei mutări care maximizează
    scorul adversarului.
	Calculez scorul maxim ce se poate obtine pentru o mutare posibila:
-}

step :: Board -> (House, Board)
step board = let max = head $ successors board;
			 scoreGet = if who board == You then fst else snd
			 -- se extrage perechea ce are tabla cu scorul cel mai mare:
			 in foldl (\ max current ->
						 if scoreGet (scores (snd current)) > 
							scoreGet (scores (snd max))
						 then current 
						 else max ) 
					   max 
					   (successors board)


{-
    Urmărește pas cu pas evoluția jocului, conform strategiei implementate.
-}
userMode :: IO ()
userMode = humanVsAI step
