-- Ursache Andrei - 322CA - 24 aprilie 2015

{-
    Tabla de joc și mutările posibile.
-}
module Board
    ( Board
    , Player (..)  -- Exportăm și constructorii de date 'You' și 'Opponent'.
    , House
    , build
    , yourSeeds
    , oppsSeeds
    , who
    , isOver
    , initialBoard
    , move
    , scores
    , successors
    ) where

import Consecutive

{-
    Jucătorul care urmează să mute.
-}
data Player = You | Opponent deriving (Eq, Show)

{-
    Tipul caselor, definit pentru lizibilitate.
-}
type House = Int

-------------------------------------------------------------------------- Board
{-
   Tabla de joc
-}
data Board = Board
	{
	 -- continutul caselor si al depozitului jucatorului "You":
	 playerSeeds :: ([Int], Int)
	 -- continutul caselor si al depozitului jucatorului "Opponent":
	,opponentSeeds :: ([Int], Int) 	
	 -- jucatorul a carui rand urmeaza:
	,next :: Player	
	 -- scorul actual:
	,score :: (Int,Int)
	 -- True = Finished , False Playing:
	,finished :: Bool 				
	} deriving Eq

--------------------------------------------------------------------------- Show
-- Returneaza suma seed-urilor din houses:
toStringHouses :: ([Int], Int) -> String
toStringHouses ps =  foldl (\str elem  -> str ++ "\t" ++(show elem)) "" (fst ps)

-- Returneaza store:
toStringStore :: ([Int], Int) -> String
toStringStore ps = show $  snd ps

{-
	Afisare:
				4	4	4	4	4	4
			0							0
				4	4	4	4	4	4
			Next: You | Score: (0,0) | Playing
-}
instance Show Board where
    show (Board playerSeeds opponentSeeds next score finished) = 
						   toStringHouses  opponentSeeds ++ "\n" 
						++ toStringStore opponentSeeds ++ "\t\t\t\t\t\t\t"
						++ toStringStore playerSeeds ++ "\n"
						++ toStringHouses playerSeeds ++ "\n"
						++ "Next: " ++ (show next) 
						++ " | Score: " ++ (show score) ++ " | "
						++(if finished then "Finished" else "Playing" )
																
																
{-
    Instantierea clasei 'Consecutive':
-}
instance Consecutive Board where
    b1 >< b2 = (who b1) == (who b2)

	
-------------------------------------------------------------------------- Build

getSeedsInHousesNo :: ([Int], Int) -> Int
getSeedsInHousesNo ps = foldl (+) 0 (fst ps)

build :: ([Int], Int)  -- Conținutul caselor și al depozitului utilizatorului
      -> ([Int], Int)  -- Conținutul caselor și al depozitului adversarului
      -> Player        -- Jucătorul aflat la rând
      -> Board         -- Tabla construită
	  
build pS oS nxt = (Board pS oS nxt score finished)
	where
	-- se verifica daca este vreun jucator fara seeds in houses:
	finished =  getSeedsInHousesNo pS == 0 || (getSeedsInHousesNo oS == 0)
	score = if finished -- daca jocul s-a terminat
			then 	-- retine scorul total (seed-urie ramase se aduna la scor)
					((getSeedsInHousesNo pS) + (snd pS),  
					(getSeedsInHousesNo oS) + (snd oS))
			else 	(snd pS, snd oS)

---------------------------------------------------------------------- Auxiliare

{-
    Întoarce conținutul caselor și al depozitului utilizatorului.
-}
yourSeeds :: Board -> ([Int], Int)
yourSeeds = playerSeeds;

{-
    Întoarce conținutul caselor și al depozitului adversarului.
-}
oppsSeeds :: Board -> ([Int], Int)
oppsSeeds = opponentSeeds

{-
    Întoarce jucătorul aflat la rând.
-}
who :: Board -> Player
who = next

{-
    Întoarce 'True' dacă jocul s-a încheiat.
-}
isOver :: Board -> Bool
isOver = finished

{-
    Tabla inițială:
		4	4	4	4	4	4
	0							0
		4	4	4	4	4	4
	Next: You | Score: (0,0) | Playing
-}
initialBoard :: Board
initialBoard = build ([4,4,4,4,4,4],0) ([4,4,4,4,4,4],0) You

--------------------------------------------------------------------------- Move

{-
  Realizarea unei mutari:
-}

-- Numarul de seeds din casa "house" a jucatorului curent:
getSeedsInHouseNo :: House -> Board -> Int 
getSeedsInHouseNo house board = 
	if (who board) == You then (fst $ yourSeeds board ) !! (house-1)
	else (fst $ oppsSeeds board ) !! (house-1)

-- Returneaza urmatorul jucator (alternativ)
getNextPlayer :: Player -> Player
getNextPlayer player = 
	if player == You then Opponent
	else You

-- Returneaza o pereche: 
--   pe prima pozitie se afla lista totala de houses cu seed-urile impartine;
--   pe a doua pozitie este  indexul ultimei casute la care s-a ajuns, dar care
--   nu a fost procesata.
processUntilLast :: [Int] -> Int -> Int -> ([Int],Int)
processUntilLast housesList startingPos seedsNo = 
	let cyclesNo = seedsNo `div` 13; -- numarul de rotatii complete pe tabla
		indexes = take 13 [0..]; -- indecsii casutelor
		lastPos = (seedsNo + startingPos) `mod` 13; -- indexul ultimei casute
													-- la care se ajunge
		-- cat se adauga la fiecare casuta (pe index):
		adds = map (\ index -> cyclesNo +
			   -- se adauga numarul de rotatii complete care se fac si restul
			   -- ramas de seeds dintre casa de start si ultima casa
			   -- sunt doua cazuri in care se pot gasi start si last
						(if lastPos > startingPos 
						then (if  index >= startingPos && 
								  index < lastPos 
							  then 1 -- pune seed  1
							  else 0) 
						else (if lastPos < startingPos
							  then (if index < lastPos || index >= startingPos 
									then 1 -- pune seed
									else 0)
							   else 0 )))
					indexes;
		-- Se goleste casuta de la care se ia:
		housesAfterTake = (take startingPos housesList) ++ [-1] ++ 
						  (drop (startingPos + 1) housesList);
		-- Se aduna la casutele initiale:
		result = zipWith (+) adds housesAfterTake;
		
	in	(result,lastPos)

-- Retuneaza o pereche:
-- 		pe prima pozitie se afla o pereche cu informatiile despre celi doi
-- 			jucatori in format standard de dupa efectuarea mutarii
--		pe a doua pozitie se afla jucatorul urmator
processMove :: House -> Board -> ((([Int], Int),([Int], Int)),Player)
processMove house board = 

	-- Este lista completa a casutelor (pentru a putea fi parcursa circular);
	-- Ea este particularizata in functie de jucator:
	-- Are urmatorul format: [houses jucator curent] ++ [store jucator curent]
	-- [houses jucator advers], cu mentiunea ca jucatorul Opponent are casutele
	-- in ordine inversa;
	-- Am facut asta pentru a nu realiza de doua ori gestionarea seed-urilor;
	let housesList = if who board == You 
					 then ( fst (yourSeeds board) ) ++ [snd (yourSeeds board) ] 
						  ++ (reverse $ ( fst (oppsSeeds board) ))
					 else (reverse ( fst (oppsSeeds board) )) ++ 
						  [ snd (oppsSeeds board) ] ++ (fst (yourSeeds board) );
						  
		-- casuta din care se iau seed-urile:
		startingPos = if (who board == You) then (house - 1) else (6 - house);
		
		-- numarul de seeds:
		seedsNo = housesList !! startingPos;
		
		-- rezultatul gestionarii si indexul ultimei casute (in care nu s-a pus)
		(resultList, lastHouse) = processUntilLast housesList 
												   startingPos 
												   seedsNo;
		
		-- Calcularea urmatorului jucator:
		player = if(lastHouse == 6) then who board else getNextPlayer $ who board;
		
		-- Calcularea modificarilor aduse de punerea unltimului seed
		finalHouses = if lastHouse < 6 && -- daca este o situatie de capturare:
						(resultList !! lastHouse) == 0 && 
						( resultList !! (12 - lastHouse) ) /= 0
					  -- se iau seed-urile din casuta omoloaga
					  then (take 6 resultList) ++
							[(resultList !! 6) + 1 +
							( resultList !! (12 - lastHouse) ) ] ++ 
						   (take (5 - lastHouse ) (drop 7 resultList)) ++ [0] ++
						   (drop (13 - lastHouse)  resultList)
					  -- altfel, doar se pune in ultima casuta
					  else	(take lastHouse resultList) ++
							[(resultList !! lastHouse) + 1] ++ 
							(drop (lastHouse + 1) resultList) ;
		-- Extragerea seed-urilor in formatul standard pentru cei doi jucatori:
		pSeeds = if who board == You then ((take 6 finalHouses), 
											finalHouses !! 6)
									 else ((drop 7 finalHouses), 
											snd $ yourSeeds board);
		oSeeds = if who board == Opponent then ( reverse (take 6 finalHouses), 
												 finalHouses !! 6)
										  else (reverse (drop 7 finalHouses), 
												snd $ oppsSeeds board);			
		-- Return:
	in  ((pSeeds,oSeeds), player)

-- Verifica daca e o mutare valida:
isPossibleMove :: House -> Board -> Bool
isPossibleMove house board =  not (house > 6 || house < 1 || 
								   isOver board || 
								   (getSeedsInHouseNo house board) == 0) 

-- Functia caracteristica unei mutari:
move :: House -> Board -> Board
move house board = if not $ isPossibleMove house board 
				   then board
				   else build newYourSeeds newOppsSeeds nextPlayer
						where
						result = processMove house board
						newYourSeeds = fst $ fst result
						newOppsSeeds = snd $ fst result
						nextPlayer = snd result

{-
    Întoarce scorurile (utilizator, adversar).
-}
scores :: Board -> (Int, Int)
scores = score

---------------------------------------------------------------- Mutari Posibile
{-
    Întoarce perechile casă-configurație, reprezentând mutările care pot fi
    făcute într-un singur pas, pornind de la configurația actuală.
	Se retin doar mutarile posibile:
-}
successors :: Board -> [(House, Board)]
successors board = foldl (\ rez house -> 
							if isPossibleMove house board 
							then rez ++ [(house, move house board)] 
							else rez ) 
						[] 
						[1..6]