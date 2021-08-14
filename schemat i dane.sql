-- Tworzenie struktury tabel
DROP TRIGGER kupnoAbonamentu;
DROP TABLE dostawy;
DROP TABLE adresy;
DROP TABLE zam_ubrania;
DROP TABLE zamowienia;
DROP TABLE ubrania;   
DROP TABLE zakupyAbonamentu;
DROP TABLE users;
CREATE TABLE users(
    userID NUMBER PRIMARY KEY,
    login VARCHAR(32),
    haslo VARCHAR(32),
    imie VARCHAR(32),
    nazwisko VARCHAR(32),
    data_ur DATE,
    typ_konta VARCHAR(5),
    abonament_do DATE);
    
DROP TABLE kategorie;
CREATE TABLE kategorie(
    nazwa VARCHAR(10) PRIMARY KEY,
    opis VARCHAR(64));
    
CREATE TABLE ubrania(
    ubranieID NUMBER PRIMARY KEY,
    nazwa VARCHAR(64),
    rozmiar VARCHAR(3),
    stan VARCHAR(16),
    czyMeskie NUMBER(1),
    dostepne NUMBER(1),
    kategoria VARCHAR(10),
    CONSTRAINT fk_kategoria FOREIGN KEY(kategoria) REFERENCES kategorie(nazwa));
    
DROP TABLE statusy;   
CREATE TABLE statusy(
    status VARCHAR(16) PRIMARY KEY,
    opis VARCHAR(64));
    
CREATE TABLE zamowienia(
    zamowienieID NUMBER PRIMARY KEY,
    userID NUMBER,
    czyKurier NUMBER(1),
    status VARCHAR(16),
    terminRozp DATE,
    terminZak DATE,
    CONSTRAINT fk_userID FOREIGN KEY(userID) REFERENCES users(userID),
    CONSTRAINT fk_status FOREIGN KEY(status) REFERENCES statusy(status));
    
CREATE TABLE zam_ubrania(
    zamowienieID NUMBER,
    ubranieID NUMBER,
    CONSTRAINT zam_ubrania_pk PRIMARY KEY (zamowienieID, ubranieID),
    CONSTRAINT fk_zamowienieID FOREIGN KEY(zamowienieID) REFERENCES zamowienia(zamowienieID),
    CONSTRAINT fk_ubranieID FOREIGN KEY(ubranieID) REFERENCES ubrania(ubranieID));
	
CREATE TABLE adresy(
	adresID NUMBER PRIMARY KEY,
	userID NUMBER,
	ulica VARCHAR(16),
	numer VARCHAR(8),
	kod_pocztowy VARCHAR(6),
	miasto VARCHAR(20),
	CONSTRAINT fk_adresy_userID FOREIGN KEY(userID) REFERENCES users(userID));
	
CREATE TABLE dostawy(
	dostawaID NUMBER PRIMARY KEY,
	nr_listu VARCHAR(16),
	zamowienieID NUMBER,
	przew_data DATE,
	adresID NUMBER,
	dostarczono NUMBER(1),
	CONSTRAINT fk_dostawa_zamID FOREIGN KEY(zamowienieID) REFERENCES zamowienia(zamowienieID),
	CONSTRAINT fk_dostawa_adresID FOREIGN KEY(adresID) REFERENCES adresy(adresID));
    
CREATE TABLE zakupyAbonamentu(
	zakupID NUMBER PRIMARY KEY,
	data_zakupu DATE,
	userID NUMBER,
	ile_miesiecy NUMBER,
	CONSTRAINT fk_abonament_userID FOREIGN KEY (userID) REFERENCES users(userID));
	
-- Dodanie przykładowych danych 
DROP SEQUENCE users_seq;
CREATE SEQUENCE users_seq MINVALUE 1 START WITH 1 INCREMENT BY 1 CACHE 20;
DROP SEQUENCE kategorie_seq;
CREATE SEQUENCE kategorie_seq START WITH 1;
DROP SEQUENCE ubrania_seq;
CREATE SEQUENCE ubrania_seq START WITH 1;
DROP SEQUENCE zamowienia_seq;
CREATE SEQUENCE zamowienia_seq START WITH 1;
DROP SEQUENCE zakupAb_seq;
CREATE SEQUENCE zakupAb_seq START WITH 1;
DROP SEQUENCE adresy_seq;
CREATE SEQUENCE adresy_seq START WITH 101;
DROP SEQUENCE dostawy_seq;
CREATE SEQUENCE dostawy_seq START WITH 1;

INSERT INTO statusy VALUES ('ZLOZONE','Zamówienie złożone przez klienta.');
INSERT INTO statusy VALUES ('PRZYGOTOWYWANE','Zamówienie przygotowywane w placówce.');
INSERT INTO statusy VALUES ('KURIERPLACOWKA','Zamówienie czeka na odbiór kuriera w placówce.');
INSERT INTO statusy VALUES ('WDRODZEKLIENT','Zamówienie w drodze do klienta.');
INSERT INTO statusy VALUES ('CZEKANAODBIOR','Zamówienie oczekuje na odbiór przez klienta.');
INSERT INTO statusy VALUES ('ODEBRANEKLIENT','Zamówienie odebrane przez klienta.');
INSERT INTO statusy VALUES ('KURIERKLIENT','Zamówienie czeka na odbiór kuriera u klienta.');
INSERT INTO statusy VALUES ('WDRODZEPLACOWKA','Zamówienie w drodze do placówki');
INSERT INTO statusy VALUES ('ODEBRANEPLACOWKA','Zamówienie odebrane przez nas.');
INSERT INTO statusy VALUES ('SPRAWDZANE','Zamówione produkty są sprawdzane.');
INSERT INTO statusy VALUES ('PIELEGNACJA','Zamówione produkty w trakcie pielęgnacji.');
INSERT INTO statusy VALUES ('ZAKONCZONE','Zamówienie zostało zakończone.');

INSERT INTO users VALUES (users_seq.nextval,'admin','haslo','Jan','Admin',TO_DATE('1990-01-01','YYYY-MM-DD'),'ADMIN',NULL);
INSERT INTO users VALUES (users_seq.nextval,'pracownik','haslo','Anna','Pracownik',TO_DATE('1995-10-15','YYYY-MM-DD'),'PRAC',NULL);
INSERT INTO users VALUES (users_seq.nextval,'user1','haslo','Norbert','Gierczak',TO_DATE('1997-07-07','YYYY-MM-DD'),'USER',NULL);
INSERT INTO users VALUES (users_seq.nextval,'user2','haslo','Karol','Gierczak',TO_DATE('1998-07-07','YYYY-MM-DD'),'USER',NULL);
INSERT INTO users VALUES (users_seq.nextval,'user3','haslo','Karolina','Gierczak',TO_DATE('1996-07-07','YYYY-MM-DD'),'USER',NULL);

INSERT INTO adresy VALUES (1,NULL,'Firmowa','100A','05-450','Mińsk Maz');
INSERT INTO adresy VALUES (adresy_seq.nextval,3,'Warszawska','185 m.2','00-010','Warszawa');
INSERT INTO adresy VALUES (adresy_seq.nextval,4,'Warszawska','185 m.2','00-010','Warszawa');
INSERT INTO adresy VALUES (adresy_seq.nextval,5,'Warszawska','185 m.2','00-010','Warszawa');

INSERT INTO kategorie VALUES ('GARNITURY','Wszelkiego rodzaju garnitury.');
INSERT INTO kategorie VALUES ('SUKIENKI','Wszelkiego rodzaju sukienki.');
INSERT INTO kategorie VALUES ('SPODNIE','Wszelkiego rodzaju spodnie.');
INSERT INTO kategorie VALUES ('KOSTIUMY','Wszelkiego rodzaje pełne kostiumy.');
INSERT INTO kategorie VALUES ('KOMPLETY','Wszelkiego rodzaje pełne zestawy.');
INSERT INTO kategorie VALUES ('KOSZULE','Wszelkiego rodzaju koszule.');
INSERT INTO kategorie VALUES ('BUTY','Wszelkiego rodzaju buty.');
INSERT INTO kategorie VALUES ('KRAWATY','Wszelkiego rodzaju krawaty.');

INSERT INTO ubrania VALUES (ubrania_seq.nextval,'Garnitur ABC','XXL','IDEALNY',1,1,'GARNITURY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'Garnitur ABC','XL','DOBRY',1,1,'GARNITURY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'Garnitur ABC','L','BARDZO DOBRY',1,1,'GARNITURY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'Garnitur EFG','M','DOBRY',1,1,'GARNITURY');

INSERT INTO ubrania VALUES (ubrania_seq.nextval,'SUKIENKA ABC','L','DOBRY',0,1,'SUKIENKI');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'SUKIENKA ABC','M','BARDZO DOBRY',0,1,'SUKIENKI');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'SUKIENKA ABC','XL','IDEALNY',0,1,'SUKIENKI');

INSERT INTO ubrania VALUES (ubrania_seq.nextval,'SPODNIE EFG','L','DOBRY',1,1,'SPODNIE');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'SPODNIE ABC','M','BARDZO DOBRY',0,1,'SPODNIE');

INSERT INTO ubrania VALUES (ubrania_seq.nextval,'KOSTIUM ABC','L','IDEALNY',0,1,'KOSTIUMY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'KOSTIUM EFG','M','IDEALNY',0,1,'KOSTIUMY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'KOSTIUM HIJ','S','IDEALNY',0,1,'KOSTIUMY');

INSERT INTO ubrania VALUES (ubrania_seq.nextval,'KOMPLET ABC','L','BARDZO DOBRY',0,1,'KOMPLETY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'KOMPLET EFG','M','IDEALNY',0,1,'KOMPLETY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'KOMPLET HIJ','S','DOBRY',0,1,'KOMPLETY');

INSERT INTO ubrania VALUES (ubrania_seq.nextval,'KOSZULA ABC','L','BARDZO DOBRY',1,1,'KOSZULE');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'KOSZULA ABC','XL','BARDZO DOBRY',1,1,'KOSZULE');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'KOSZULA ABC','M','IDEALNY',1,1,'KOSZULE');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'KOSZULA DEF','M','BARDZO DOBRY',0,1,'KOSZULE');

INSERT INTO ubrania VALUES (ubrania_seq.nextval,'DERBY ABC','44','BARDZO DOBRY',1,1,'BUTY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'DERBY ABC','45','IDEALNY',1,1,'BUTY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'OXFORDY DEF','43','IDEALNY',1,1,'BUTY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'SZPILKI ABC','39','BARDZO DOBRY',0,1,'BUTY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'SZPILKI ABC','38','IDEALNY',0,1,'BUTY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'SZPILKI DEF','37','IDEALNY',0,1,'BUTY');

INSERT INTO ubrania VALUES (ubrania_seq.nextval,'KRAWAT A','-','IDEALNY',1,1,'KRAWATY');
INSERT INTO ubrania VALUES (ubrania_seq.nextval,'KRAWAT B','-','IDEALNY',1,1,'KRAWATY');

INSERT INTO zamowienia VALUES (zamowienia_seq.nextval,3,1,'ZAKONCZONE',TO_DATE('2021-04-05','YYYY-MM-DD'),TO_DATE('2021-04-08','YYYY-MM-DD'));
INSERT INTO zamowienia VALUES (zamowienia_seq.nextval,4,0,'ZAKONCZONE',TO_DATE('2021-05-18','YYYY-MM-DD'),TO_DATE('2021-05-21','YYYY-MM-DD'));
INSERT INTO zamowienia VALUES (zamowienia_seq.nextval,5,0,'ZAKONCZONE',TO_DATE('2021-05-17','YYYY-MM-DD'),TO_DATE('2021-05-20','YYYY-MM-DD'));

INSERT INTO zam_ubrania VALUES (1,1);
INSERT INTO zam_ubrania VALUES (2,2);
INSERT INTO zam_ubrania VALUES (2,8);
INSERT INTO zam_ubrania VALUES (3,3);

INSERT INTO dostawy VALUES (dostawy_seq.nextval,'ASD543FDS6',1,TO_DATE('2021-04-06','YYYY-MM-DD'),101,1);
INSERT INTO dostawy VALUES (dostawy_seq.nextval,'ASD543FDS7',1,TO_DATE('2021-04-08','YYYY-MM-DD'),1,1);

COMMIT;

CREATE OR REPLACE TRIGGER kupnoAbonamentu
    AFTER UPDATE OF abonament_do ON users
    FOR EACH ROW
	DECLARE
		pocz DATE;
		roznica NUMBER;
    BEGIN
        IF :OLD.abonament_do IS NULL THEN pocz:= SYSDATE;
		ELSE pocz:= :OLD.abonament_do; END IF;
		roznica := MONTHS_BETWEEN(:NEW.abonament_do,pocz);
		INSERT INTO zakupyAbonamentu VALUES (zakupAb_seq.nextval,SYSDATE,:OLD.userID,roznica);
    END;
