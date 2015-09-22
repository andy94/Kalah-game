    Ursache Andrei - 322CA - 24 aprilie 2015

	----------------------------------------------------------------------------
	Proiect anul 2, semestrul al doilea, Paradigme de programare
	Limbaj ales: Prolog
	
	############################     ATENTIE !!!    ############################
	Temele sunt verificate pe VMChecker. Nu incercati sa copiati codul, deoarece
	VMChecker verifica si sursele existente pe GitHub. In plus, fiecare tema va 
	ajuta foarte mult daca incercati sa o realizati singuri. Asa ca, daca ai
	ajuns aici pentru a cauta o tema, iti recomand calduros sa inchizi tab-ul cu 
	GitHub si sa te apuci singur de ea. Spor!
	----------------------------------------------------------------------------

  
    Aspecte generale:
	
		In realizarea temei nu am utilizat recursivitatea explicita, ci de 
	de fiecare data am utilizat functionale (acolo unde era evident).
    
    Ideea generala:
	
		Pentru tabla de joc am creat un tip inregistrare care cuprinde 
	urmatoarele elemente:
		playerSeeds 	= o pereche ce are pe prima pozitie lista de houses a
						  jucatorului ("You")
		opponentSeeds	= analog, playerSeeds
		next 			= jucatorul a carui rand urmeaza
		score			= pereche in care se retine scorul
		finished		= boolean care indica daca jocul s-a terminat
		
		In momentul in care se creeaza o tabla de joc, verific mai intai daca
	jocul este terminat (unul dintre jucatori nu mai are seeds in houses) dupa
	care se calculeaza scorul corespunzator (daca jocul este terminat, 
	jucatorului care mai are inca seeds in houses, acestea i se adauga la scor).
		
		Pentru realizarea unei mutari am incercat sa gasesc o modalitate
	prin care nu sunt nevoit sa duplic codul pentru cei doi jucatori. Astfel, 
	am creeat o lista cu toate casutele in modul urmator:
	[casutele jucatorului curent] ++ [store jucator curent] ++ [casutele 
	celuilalt jucator]. Cu observatia ca, pentru "Opponent", casutele se retin
	in ordine inversa.
		In acest mod, am calculat ultima casuta la care se ajunge cu depunerea
	seed-urilor si am adaugat tuturor casutelor (inclusiv store-ului 
	corespunzator care se afla la mijloc) atatea seeds cate rotatii putem sa 
	facem cu numarul de seeds din casuta de start (adica numar_seeds_initial 
	impartit la 13). Apoi, au mai ramas de completat casutele intre start si 
	ultima casuta (tratat pe cele doua cazuri in care pot sa apara). 
		Astfel, printr-o singura parcurgere a listei de casute s-a realizat 
	gestionarea seed-urilor.
		Apoi, se realizeaza si depunerea in ultima casuta si se trateaza 
	cazurile de captura si de obtinere a unei noi runde a aceluias jucator.
		
		Pentru functia successors am creat o lista in care am adugat numai
	acele mutari posibile luand la rand casutele jucatorului.
		
		Algoritmul simplu returneaza mutarea prin care jucatorul obtine 
	cel mai mare scor dintre toate mutarile.
	
		Bonus:
		
		Chiar daca a fost o implementare generica a algoritmului minimax, am 
	abordat intreaga rezolvare gandindu-ma la tot timpul la jocul Kalah. Astfel,
	pentru tipul de date prametric "Tree s a" (unde s va fi reprezentat de 
	Board, iar a de Houses), am ales ca fiecare nod sa contina o valoare s
	(tabla curenta) si o lista de perechi de forma (a,Tree s a), unde pe
	prima pozitie va fi casa (mutarea), iar pe a doua, recursiv, arborele
	ce se obtine in urma mutarii.
		Avand in vedere ca extend va genera la infinit arborele, functia prune
	am implementa-o sa ia (asemanator lui take) doar primele n nivele din arbore.
	Acest lucru l-am realizat prin parcurgerea listelor de copii pe atatea 
	nivele cate se primesc la input.
		Functiile maximize si minimize sunt simetrice si ele calculeaza minimul 
	/ maximul pentru un arbore asupra caruia se aplica recursiv (in functie de
	succesiunea jucatorilor), pana la frunze, unde se evalueaza. Pentru 
	implementarea algoritmului am consultat http://en.wikipedia.org/wiki/Minimax
	si laboratorul de Minimax de la PA.
		Functia pick va alege dintre toti copii, pe cel care are scorul maxim 
	in urm evaluarii cu ajutorul functiilor anterioare.
 
    (!!!)   Alte detalii referitoare la implementarea temei se gasesc in 
            fisierul sursa.
    
    Andrei Ursache
