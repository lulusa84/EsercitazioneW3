CREATE DATABASE [Pizzeria]

CREATE TABLE Pizza(
[ID_Pizza] [int] IDENTITY(1,1) NOT NULL,  
[Codice_pizza] [int] NOT NULL,  
[Nome_pizza] varchar(20) NOT NULL,  
[Prezzo_pizza]  smallmoney NOT NULL,


CONSTRAINT[PK_Pizza] PRIMARY KEY CLUSTERED (ID_Pizza),

CONSTRAINT [Codice_Pizza] UNIQUE(Codice_Pizza),
CONSTRAINT [Nome_Pizza] UNIQUE(Nome_Pizza)

);

CREATE TABLE Ingrediente(
[ID_Ingrediente] [int] IDENTITY(1,1) NOT NULL,  
[Codice_Ingrediente] varchar(5),
[Nome_Ingrediente] varchar(20) NOT NULL,  
[Costo_pizza]  smallmoney NOT NULL,


CONSTRAINT[PK_Ingrediente] PRIMARY KEY CLUSTERED (ID_Ingrediente),

CONSTRAINT [Codice_Ingrediente] UNIQUE(Codice_Ingrediente),
CONSTRAINT [Nome_Ingrediente] UNIQUE(Nome_Ingrediente)

);

CREATE TABLE Magazzino(
[ID_Magazzino] [int] IDENTITY(1,1) NOT NULL,  
[Codice_Ingrediente] varchar(5) null,  
[scorte_mag] int null,


CONSTRAINT[PK_Magazzino] PRIMARY KEY CLUSTERED (ID_Magazzino),

);

ALTER TABLE Pizza
ADD ID_Ingrediente int
ALTER TABLE Pizza
ADD qta_Ingrediente int

ALTER TABLE Pizza 
ADD CONSTRAINT FK_Ingrediente FOREIGN KEY(ID_Ingrediente)
REFERENCES Ingrediente(ID_Ingrediente)
ON DELETE NO ACTION
ON UPDATE SET DEFAULT

ALTER TABLE Ingrediente
ADD scorte_mag int
ALTER TABLE Ingrediente
ADD ID_Magazzino int

ALTER TABLE Magazzino
ADD ID_Ingrediente int

ALTER TABLE Ingrediente
ADD CONSTRAINT FK_Magazzino FOREIGN KEY(ID_Magazzino)
REFERENCES Magazzino(ID_Magazzino)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE Magazzino
ADD CONSTRAINT FK_Ingrediente_Mag FOREIGN KEY(ID_Ingrediente)
REFERENCES Ingrediente(ID_Ingrediente)
ON DELETE NO ACTION
ON UPDATE CASCADE

CREATE TABLE Pizza_Ingrediente(
[ID_Pizza] [int] IDENTITY(1,1) NOT NULL,  
[ID_Ingrediente] int  

CONSTRAINT[PK_Pizza_Ing] PRIMARY KEY CLUSTERED (ID_Pizza),

); 
-- Avendo necessità di effetuare una selezione sul Codice_Pizza, per evitare di dover costruire un funzione per ricavarne uno di tipo alfanumerico
-- elimino manualmente nell'ordine le chiavi associate ai campi ID_Ingrediente e Codice_Ingrediente di Tipo int  ed i rispettivi campo, 
-- e faccio lo stesso con i seguenti:  ID_Pizza e Codice_Pizza  di tipo varchar(5)
-- Aggiungo un campo ID_Ingrediente all tabella ingrediente  di Tipo int che mi permette di selezionare l'ingrediente, 
-- apartire dal codice senzadover costriuire una funzione apposita
ALTER TABLE [Pizza_Ingrediente]
ADD Codice_pizza int

ALTER TABLE [Pizza_Ingrediente]
ADD Codice_Ingrediente int


ALTER TABLE Pizza_Ingrediente
ADD CONSTRAINT FK_Pizza_Ing FOREIGN KEY(Codice_Ingrediente)
REFERENCES Ingrediente(Codice_Ingrediente)
ON DELETE NO ACTION
ON UPDATE CASCADE

ALTER TABLE Magazzino
ADD CONSTRAINT FK_Ingrediente_Mag FOREIGN KEY(Codice_Ingrediente)
REFERENCES Ingrediente(Codice_Ingrediente)
ON DELETE NO ACTION
ON UPDATE CASCADE

ALTER TABLE [PIZZA]
WITH CHECK ADD CONSTRAINT [prezzo_pizza_ck] 
CHECK ([prezzo_pizza] > 0 AND [Qta_Ingrediente] > 0)


--INDICI
Create INDEX PIZZA_nome_NDX ON Pizza (Nome_Pizza ASC);
CREATE UNIQUE INDEX PIZZA_Ingr_Cod ON Ingrediente(Codice_Ingrediente);

ALTER TABLE Pizza
ADD CONSTRAINT [PK_Pizza] PRIMARY KEY CLUSTERED (ID_Pizza, Codice_Pizza)


--PROCEDURE
CREATE PROCEDURE [InsPizza] 
@Nome_pizza varchar (20),
@Prezzo_pizza smallmoney

AS 
BEGIN
   begin try
   --OPERAZIONI CHE POTREBBERO PROVOCARE ECCEZIONI

   INSERT INTO Pizza values (@Nome_pizza, @Prezzo_pizza)
  
   end try
   begin catch
   --STAMPA ECCEZIONI
   SELECT
   ERROR_LINE(), ERROR_MESSAGE(), ERROR_SEVERITY()
   
   end catch
END

EXECUTE [InsPizza] @Nome_pizza='Caprese', @Prezzo_pizza = 7.50
EXECUTE [InsPizza] @Nome_pizza='Margherita', @Prezzo_pizza = 5.00
EXECUTE [InsPizza] @Nome_pizza='Bufala', @Prezzo_pizza = 7.00
EXECUTE [InsPizza] @Nome_pizza='Diavola', @Prezzo_pizza = 6

CREATE PROCEDURE [AssegnazioneIngredientePizza]
@Codice_pizza int,
@Codice_Ingrediente varchar(5)

AS 
BEGIN
  begin try
   --OPERAZIONI CHE POTREBBERO PROVOCARE ECCEZIONI   
   IF NOT EXISTS (SELECT Codice_Ingrediente = @Codice_Ingrediente
                   FROM Ingrediente 
                     WHERE Codice_Ingrediente = @Codice_Ingrediente)
   INSERT INTO Ingrediente values (@Codice_Ingrediente, 'ing1', 1.5, 0, 1);
   
  IF NOT EXISTS (SELECT Codice_Ingrediente = @Codice_Ingrediente, Codice_pizza =  @Codice_pizza
                   FROM Pizza_Ingrediente 
                    WHERE Codice_Ingrediente = @Codice_Ingrediente AND Codice_pizza = @Codice_pizza)
					
					INSERT INTO Pizza_Ingrediente VALUES(@Codice_pizza, @Codice_Ingrediente, 2)
	
  end try
   begin catch
   --STAMPA ECCEZIONI
    SELECT
   ERROR_LINE(), ERROR_MESSAGE(), ERROR_SEVERITY()
   
   end catch
   END

  
EXECUTE [AssegnazioneIngredientePizza] @Codice_pizza = '3', @Codice_Ingrediente ='1'


 SELECT * FROM Pizza
 SELECT * FROM Ingrediente

 SELECT *FROM Magazzino
 
 SELECT *FROM Pizza_Ingrediente


CREATE PROCEDURE DeleteIngredienteFromPizza
@Codice_pizza int,
@Codice_Ingrediente varchar(5)

AS
BEGIN
--   BEGIN TRANSACTION
begin try
  --operazioni cancellazione 

  UPDATE  Pizza_Ingrediente SET qta_Ingrediente = 0 WHERE
   EXISTS(
   SELECT qta_Ingrediente
   FROM Pizza_Ingrediente pi 
   WHERE pi.Codice_pizza = @Codice_pizza AND pi.Codice_Ingrediente = @Codice_Ingrediente
   )
  
 -- IF @@ERROR > 0
--  ROLLBACK TRANSACTION

--   COMMIT TRANSACTION
 end try

 begin catch
 SELECT
 ERROR_LINE(), ERROR_MESSAGE()

--   ROLLBACK TRANSACTION
 end catch

END


EXEC DeleteIngredienteFromPizza @Codice_pizza = '1', @Codice_Ingrediente ='1'

 SELECT *FROM Pizza_Ingrediente


 CREATE PROCEDURE OneComponentPizzaPriceIncrese
 @Codice_Ingrediente int

AS
BEGIN
--   BEGIN TRANSACTION
begin try
  --operazioni cancellazione 

  UPDATE Pizza SET Prezzo_Pizza = Prezzo_pizza *(1.10) WHERE Codice_Pizza
   IN(
   SELECT pi.Codice_Pizza
   FROM Pizza_Ingrediente pi 
   WHERE pi.Codice_Ingrediente = 1 
   GROUP BY pi.Codice_pizza, pi.Codice_Ingrediente HAVING COUNT(pi.Codice_Ingrediente) = 1 )
  
 -- IF @@ERROR > 0
--  ROLLBACK TRANSACTION
--   COMMIT TRANSACTION

 end try

 begin catch
 SELECT
 ERROR_LINE(), ERROR_MESSAGE()

--   ROLLBACK TRANSACTION
 end catch

END


EXEC OneComponentPizzaPriceIncrese @Codice_Ingrediente = '1'

 SELECT * FROM Pizza



--FUNZIONE LISTA PIZZE ORDINATA ALFABETICAMENTE(ASC)
 CREATE FUNCTION Listino_Pizze_Alfabetico()

RETURNS TABLE 
AS
  RETURN 
  SELECT P.Nome_pizza, P.Prezzo_pizza
  FROM  Pizza as P
  

SELECT *
FROM Listino_Pizze_Alfabetico()
ORDER BY  Nome_pizza asc


--FUNZIONE LISTINO PIZZE(Nom e prezzo) CONTENTI UN INGREDIENTE(Codice Ingrediente)
CREATE FUNCTION Listino_Pizze_Ingrediente(
@Codice_Ingrediente int  
)

RETURNS TABLE 
  AS
  RETURN 
   SELECT P.Nome_pizza, P.Prezzo_pizza
   FROM  Pizza as P
   JOIN Pizza_Ingrediente AS PI
   ON P.Codice_pizza = PI.Codice_pizza
   WHERE P.Codice_pizza IN(
   SELECT pi.Codice_Pizza
   FROM Pizza_Ingrediente pi 
   WHERE pi.Codice_Ingrediente = @Codice_Ingrediente  AND pi.qta_Ingrediente > 0)

  
SELECT Nome_pizza, Prezzo_pizza
FROM Listino_Pizze_Ingrediente(1)



--FUNZIONE LISTINO PIZZE(Nom e prezzo) CHE NON CONTENGANO COTENTI UN CERTO INGREDIENTE(Codice Ingrediente) EXCEPT, NOT IN
CREATE FUNCTION Listino_Pizze_Ingrediente_Escluso(
@Codice_Ingrediente int 
)

 RETURNS TABLE 
 AS
  RETURN 
SELECT P.Nome_pizza, P.Prezzo_pizza
   FROM  Pizza as P
   WHERE NOT P.Codice_pizza IN(
   SELECT pi.Codice_Pizza
   FROM Pizza_Ingrediente pi 
   WHERE pi.Codice_Ingrediente = @Codice_Ingrediente)


SELECT Nome_pizza, Prezzo_pizza
FROM Listino_Pizze_Ingrediente_Escluso(1)


--FUNZIONE CALCOLO NUMERO PIZZE CONTENTI UN INGREDIENTE(Codice Ingrediente)
  CREATE FUNCTION Numero_Pizze_Ingrediente(@Codice_Ingrediente int)
  RETURNS INT 
  AS
  BEGIN
  DECLARE @result int
  SELECT @result = Count(P.Codice_pizza)  
    FROM  Pizza as P
    JOIN Pizza_Ingrediente AS PI
    ON P.Codice_pizza = PI.Codice_pizza
    WHERE P.Codice_pizza IN(
    SELECT pi.Codice_Pizza
    FROM Pizza_Ingrediente pi 
    WHERE pi.Codice_Ingrediente = @Codice_Ingrediente  AND pi.qta_Ingrediente > 0)
  RETURN @result
  END

  SELECT dbo.Numero_Pizze_Ingrediente(1) as value
  SELECT * FROM Pizza_Ingrediente

--FUNZIONE CALCOLO NUMERO PIZZE CHE NON CONTENGANO COTENTI UN CERTO INGREDIENTE(Codice Ingrediente) EXCEPT, NOT IN
CREATE FUNCTION Numero_Pizza_Ing_Escluso(@Codice_Ingrediente int)
 RETURNS INT 
  AS
  BEGIN
  DECLARE @result int
  SELECT @result = Count(P.Codice_Pizza)
   FROM  Pizza AS P
   WHERE NOT P.Codice_pizza IN(
   SELECT pi.Codice_Pizza
   FROM Pizza_Ingrediente pi 
   WHERE (P.Codice_pizza = pi.Codice_pizza AND Codice_Ingrediente = @Codice_Ingrediente )
   or  pi.qta_Ingrediente > 0)
RETURN @result
END

SELECT dbo.Numero_Pizza_Ing_Escluso(1) as value


--FUNZIONE CALCOLO NUMROR INGREDEINTI IN UNA PIZZA(CODICE PIZZA)
 CREATE FUNCTION Numero_Ingredienti_Pizza(@Codice_Pizza int)
   RETURNS INT 
   AS
   BEGIN
   DECLARE @result int
   SELECT @result = Count(PI.Codice_Ingrediente)
   FROM  Pizza_Ingrediente as PI
   WHERE PI.Codice_pizza = @Codice_pizza AND qta_Ingrediente > 0
   
RETURN @result
END

SELECT dbo.Numero_Ingredienti_Pizza(3) as value
 
 SELECT * FROM Pizza_Ingrediente

--SELECT PER FUNZIONE CHE RETITUISCE UNA TABLE
--SELECT *
--FROM dbo.Elenco_Studenti_Raggruppati('1')
--SELECT *
--FROM dbo.Elenco_Studenti_Raggruppati(null)



--SELECT PER FUNZIONE CHE RETITUISCE UN VALORE
--SELECT  dbo.Numero_Studenti_Sezione('C') as value

--SELECT * 
--FROM Classe c
--WHERE Sezione = 'C' AND dbo.Numero_Studenti_Sezione('C') > 1



-- CREATE VIEW [MenùPizzeria] AS
--(
--SELECT distinct 

--FROM Pizze as P
--JOIN Pizza_Ingrediente as PI
--ON
--JOIN Ingrediente as I
--ON 
--);

