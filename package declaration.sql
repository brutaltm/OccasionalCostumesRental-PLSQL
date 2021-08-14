/* Procedury i funkcje aplikacji */
DROP PACKAGE wypozyczalnia;
CREATE OR REPLACE PACKAGE wypozyczalnia IS
    rola VARCHAR(5) := NULL;
    userIDz NUMBER := NULL;
    PROCEDURE wyswietl_dostepne_ubrania(ZczyMeskie NUMBER, Zkategoria VARCHAR DEFAULT 'WSZYSTKIE');
    /* USER */
    PROCEDURE register(Zlogin VARCHAR,haslo VARCHAR,imie VARCHAR,nazwisko VARCHAR,data_ur DATE);
    FUNCTION login(Zlogin VARCHAR, Zhaslo VARCHAR) RETURN NUMBER;
    PROCEDURE wykupAbonament(ile_miesiecy NUMBER DEFAULT 1);
    FUNCTION stworzZamowienie(kurier NUMBER, adresIDz NUMBER DEFAULT NULL) RETURN NUMBER;
    PROCEDURE dodajDoZamowienia(zamowienieIDz NUMBER, ZubranieID NUMBER);
    PROCEDURE wyswietl_zamowienia(odKiedy DATE DEFAULT TO_DATE('2000-01-01','YYYY-MM-DD'),doKiedy DATE DEFAULT SYSDATE);
	PROCEDURE wyswietl_szczegoly_zam(zamID NUMBER);
	PROCEDURE wyswietlAdresyDostawy(usID NUMBER DEFAULT NULL);
	FUNCTION dodajAdresDostawy(ulica VARCHAR,numer VARCHAR,kod_pocztowy VARCHAR,miasto VARCHAR) RETURN NUMBER;
	PROCEDURE zamowKurieraDoZwrotu(zamID NUMBER);
    /* PRAC */
	PROCEDURE wyswietlKlientow;
    PROCEDURE przedluzAbonament(ZuserID NUMBER,ile_miesiecy NUMBER DEFAULT 1);
    PROCEDURE dodaj_ubranie(nazwa VARCHAR,rozmiar VARCHAR,stan VARCHAR,czyMeskie NUMBER,dostepne NUMBER,kategoria VARCHAR);
    PROCEDURE dodaj_kategorie(nazwa VARCHAR, opis VARCHAR);
    PROCEDURE oddaj_do_utylizacji(ubranieIDz NUMBER);
    PROCEDURE zmien_status(zamowienieIDz NUMBER, statusZ VARCHAR);
	PROCEDURE aktualizuj_stan_ubrania(ubranieIDz NUMBER, Zstan VARCHAR);
    /* ADMIN */
    PROCEDURE dodaj_pracownika(Zlogin VARCHAR,haslo VARCHAR,imie VARCHAR,nazwisko VARCHAR,data_ur DATE);
	PROCEDURE wyswietl_pracownikow;
    PROCEDURE raport(terminOd DATE, terminDo DATE);
END wypozyczalnia;