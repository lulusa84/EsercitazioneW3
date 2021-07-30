CREATE DATABASE [Pizzeria]

CREATE TABLE Pizza(
[ID_Pizza] [int] IDENTITY(1,1) NOT NULL,  
[Codice_pizza] [int] NOT NULL,  
[Nome_pizza] varchar(20) NOT NULL,  
[Prezzo_pizza]  smallmoney NOT NULL,


CONSTRAINT[PK_Pizza] PRIMARY KEY CLUSTERED (ID_Pizza),

CONSTRAINT [Codice_Aula] UNIQUE(Codice_Pizza),
CONSTRAINT [Nome_Pizza] UNIQUE(Nome_Pizza)

);

CREATE TABLE Ingrediente(
[ID_Ingrediente] [int] IDENTITY(1,1) NOT NULL,  
[Codice_Ingrediente] varchar(5) NOT NULL,  
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

ALTER TABLE [Pizza_Ingrediente]
ADD Codice_pizza int
ALTER TABLE [Pizza_Ingrediente]
ADD Codice_Ingrediente int

ALTER TABLE Pizza_Ingrediente
ADD CONSTRAINT FK_Pizza_Ing FOREIGN KEY(Codice_Ingrediente)
REFERENCES Ingrediente(Codice_Ingrediente)
ON DELETE NO ACTION
ON UPDATE CASCADE



ALTER TABLE [PIZZA]
WITH CHECK ADD CONSTRAINT [prezzo_pizza_ck] 
CHECK ([prezzo_pizza] > 0 AND [Qta_Ingrediente] > 0)


--INDICI
Create INDEX PIZZA_nome_NDX ON Pizza (Nome_Pizza ASC);
CREATE UNIQUE INDEX PIZZA_Ingr_Cod ON Ingrediente(Codice_Ingrediente, Nome_Ingrediente, ID_Ingrediente);

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

EXECUTE [InsPizza]
@Nome_pizza='Caprese', @Prezzo_pizza = 7.50


--CREATE PROCEDURE [InserimentoOpera]
--@codice_opera varchar (10),
--@titolo varchar (70),
-- @NomeMuseo varchar(50),
-- @NomeArtista varchar(50)
--AS 
--BEGIN
--   begin try
--   --OPERAZIONI CHE POTREBBERO PROVOCARE ECCEZIONI
    
--	DECLARE @ID_MUSEO int
--	DECLARE @ID_ARTISTA int

--    SELECT  @ID_MUSEO = m.ID_Museo
--    FROM  Museo m
--    WHERE m.Nome = @NomeMuseo 
--	SELECT @ID_Artista = a.ID_Artista
--    FROM  Artista a
--    WHERE a.Nome = @NomeArtista 

--   INSERT INTO Opera values (@codice_opera, @ID_Museo, @ID_Artista, @titolo)
  
--   end try
--   begin catch
--   --STAMPA ECCEZIONI
--   SELECT
--   ERROR_LINE(), ERROR_MESSAGE(), ERROR_SEVERITY()
   
--   end catch
--END
--EXECUTE [InserimentoOpera] @codice_opera = 'XX01', @titolo ='I Girasoli', @NomeMuseo ='Louvre', @NomeArtista = 'Vincent Vam Gogh'


--CREATE PROCEDURE DeleteArtista
--@nome varchar (50),
--@nazionalità char (3)

--AS
--BEGIN
--   BEGIN TRANSACTION
--   begin try
--   --operazioni cancellazione 

   
--   DELETE FROM Personaggio WHERE ID_Personaggio 
--   IN(
--   SELECT p.ID_Personaggio 
--   FROM Opera o
--   JOIN Personaggio p
--   ON p.ID_Opera = o.ID_Opera
--   JOIN Artista a
--   ON a.ID_Artista = o.ID_Artista
--   WHERE a.Nome = @nome AND a.Nazionalità = @Nazionalità
--   )
--   DELETE FROM Opera WHERE ID_Opera 
--    IN(
--   SELECT o.ID_Opera 
--   FROM Artista a
--   JOIN Opera o
--   ON o.ID_Artista = a.ID_Artista
--   WHERE a.Nome = @nome AND a.Nazionalità = @Nazionalità
--   )

--   DELETE FROM Artista WHERE Nome = @nome AND Nazionalità = @nazionalità 

--   IF @@ERROR > 0
--          ROLLBACK TRANSACTION

--   COMMIT TRANSACTION
--   end try

--   begin catch
--   SELECT
--   ERROR_LINE(), ERROR_MESSAGE()

--   ROLLBACK TRANSACTION
--   end catch

--END


--EXEC DeleteArtista @nome = 'Vincent Vam Gogh', @nazionalità = 'Nth'