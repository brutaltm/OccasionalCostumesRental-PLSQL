CREATE OR REPLACE PACKAGE BODY wypozyczalnia AS


PROCEDURE wyswietl_dostepne_ubrania(ZczyMeskie NUMBER, Zkategoria VARCHAR DEFAULT 'WSZYSTKIE')
IS
BEGIN
    IF Zkategoria = 'WSZYSTKIE' THEN
        FOR rek IN (SELECT * FROM ubrania WHERE dostepne = 1 AND czyMeskie = ZczyMeskie ORDER BY kategoria,ubranieID) LOOP
            DBMS_OUTPUT.PUT_LINE(rek.ubranieID||' - '||rek.nazwa||'('||rek.rozmiar||') w stanie '||rek.stan);
        END LOOP;
    ELSE
        FOR rek IN (SELECT * FROM ubrania WHERE dostepne = 1 AND czyMeskie = ZczyMeskie AND kategoria = Zkategoria ORDER BY kategoria,ubranieID) LOOP
            DBMS_OUTPUT.PUT_LINE(rek.ubranieID||' - '||rek.nazwa||'('||rek.rozmiar||') w stanie '||rek.stan);
        END LOOP;
    END IF;
END wyswietl_dostepne_ubrania;


PROCEDURE register(Zlogin VARCHAR,haslo VARCHAR,imie VARCHAR,nazwisko VARCHAR,data_ur DATE)
IS
    u NUMBER;
    LoginZajetyException EXCEPTION;
    PRAGMA EXCEPTION_INIT(LoginZajetyException, -20001);
BEGIN
    BEGIN
        SELECT userID INTO u FROM users WHERE login = Zlogin;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN u := NULL; 
    END;
    IF u is not null THEN RAISE_APPLICATION_ERROR(-20001,'Wyjątek: Login jest już zajęty.'); END IF;
    INSERT INTO users VALUES (users_seq.nextval,Zlogin,haslo,imie,nazwisko,data_ur,'USER',NULL);
	COMMIT;
    DBMS_OUTPUT.PUT_LINE('Pomyślnie zarejestrowano.');
END register;


FUNCTION login(Zlogin VARCHAR, Zhaslo VARCHAR)
RETURN NUMBER
IS
    u users%ROWTYPE;
    BledneDaneUzytkownikaException EXCEPTION;
    PRAGMA EXCEPTION_INIT(BledneDaneUzytkownikaException, -20002);
BEGIN
    BEGIN
        SELECT * INTO u FROM users WHERE login = Zlogin AND haslo = Zhaslo;
    EXCEPTION WHEN NO_DATA_FOUND THEN u.login := NULL; 
    END;
    
    IF u.login is null THEN
        RAISE_APPLICATION_ERROR(-20002,'Wyjątek: Nieprawidłowe dane logowania.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Pomyślnie zalogowano jako '||u.login||'.');
        userIDz := u.userID;
        rola := u.typ_konta;
        RETURN u.userID;
    END IF;
END login;


PROCEDURE wykupAbonament(ile_miesiecy NUMBER DEFAULT 1)
IS
    abonDo DATE;
BEGIN
    IF userIDz IS NOT NULL AND rola = 'USER' THEN
        SELECT abonament_do INTO abonDo FROM users WHERE userID = userIDz;
        IF abonDo is NULL OR abonDo < SYSDATE THEN
            UPDATE users SET abonament_do = ADD_Months(SYSDATE,ile_miesiecy) WHERE userID = userIDz; 
            DBMS_OUTPUT.PUT_LINE('Przedłużono abonament do '||ADD_Months(SYSDATE,ile_miesiecy)||'.');
			COMMIT;
        ELSE
            UPDATE users SET abonament_do = ADD_Months(abonament_do,ile_miesiecy) WHERE userID = userIDz;
            DBMS_OUTPUT.PUT_LINE('Przedłużono abonament do '||ADD_Months(abonDo,ile_miesiecy)||'.');
			COMMIT;
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Zaloguj się. Brak odpowiednich uprawnień.');
    END IF;
    
END wykupAbonament;


FUNCTION stworzZamowienie(kurier NUMBER, adresIDz NUMBER DEFAULT NULL)
RETURN NUMBER
IS
    noweZamID NUMBER;
	nowaDostID NUMBER;
    zamowien NUMBER;
    abonamentDo DATE;
    zamowienieNiezakonczone EXCEPTION;
    abonamentNieOplacony EXCEPTION;
	adresDostawyEx EXCEPTION;
	adresIstnieje NUMBER;
    PRAGMA EXCEPTION_INIT(zamowienieNiezakonczone, -20003);
    PRAGMA EXCEPTION_INIT(abonamentNieOplacony, -20004);
	PRAGMA EXCEPTION_INIT(adresDostawyEx, -20005);
BEGIN
    IF userIDz IS NOT NULL THEN
        SELECT abonament_do INTO abonamentDo FROM users WHERE userID = userIDz;
        SELECT COUNT(zamowienieID) INTO zamowien FROM zamowienia WHERE userID = userIDz AND status != 'ZAKONCZONE';
        IF abonamentDo IS NULL OR abonamentDo < SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20004,'Wyjątek: Abonament nie opłacony.');
        ELSIF zamowien != 0 THEN
            RAISE_APPLICATION_ERROR(-20003,'Wyjątek: Posiadasz nie zakończone zamówienie.');
        ELSE
			CASE kurier
				WHEN 1 THEN
					IF adresIDz is NULL 
						THEN RAISE_APPLICATION_ERROR(-20005,'Wyjątek: Nie podano adresu dostawy.');
					ELSE
						SELECT COUNT(adresID) INTO adresIstnieje FROM adresy WHERE adresID = adresIDz AND userID = userIDz;
						IF adresIstnieje = 0 THEN RAISE_APPLICATION_ERROR(-20005,'Wyjątek: Podano nieprawidłowy adres dostawy.');
						ELSE 
							noweZamID := zamowienia_seq.nextval;
							nowaDostID := dostawy_seq.nextval;
							INSERT INTO zamowienia VALUES (noweZamID,userIDz,kurier,'ZLOZONE',SYSDATE,SYSDATE+5);
							INSERT INTO dostawy VALUES (nowaDostID,'ASD543FDS'||nowaDostID,noweZamID,SYSDATE+2,adresIDz,0);
							COMMIT;
							DBMS_OUTPUT.PUT_LINE('Zamówienie stworzone.');
							RETURN noweZamID;
						END IF;
					END IF;
				ELSE
					noweZamID := zamowienia_seq.nextval;
					INSERT INTO zamowienia VALUES (noweZamID,userIDz,kurier,'ZLOZONE',SYSDATE,SYSDATE+5);
					COMMIT;
					DBMS_OUTPUT.PUT_LINE('Zamówienie stworzone.');
					RETURN noweZamID;
			END CASE;
            
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Zaloguj się. Brak odpowiednich uprawnień.');
        RETURN NULL;
    END IF;
END stworzZamowienie;


PROCEDURE dodajDoZamowienia(zamowienieIDz NUMBER, ZubranieID NUMBER)
IS
    czyIstnieje NUMBER;
    czyDostepne NUMBER;
BEGIN
    IF userIDz IS NOT NULL THEN
        BEGIN
            SELECT zamowienieID INTO czyIstnieje FROM zamowienia WHERE zamowienieID = zamowienieIDz AND userID = userIDz AND status = 'ZLOZONE';
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN czyIstnieje := 0; 
        END;
        IF czyIstnieje != 0 THEN
            BEGIN
                SELECT dostepne INTO czyDostepne FROM ubrania WHERE ubranieID = ZubranieID;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN czyDostepne := 0; 
            END;
            IF czyDostepne = 1 THEN
                INSERT INTO zam_ubrania VALUES (zamowienieIDz,ZubranieID);
                UPDATE ubrania SET dostepne = 0 WHERE ubranieID = ZubranieID;
				COMMIT;
                DBMS_OUTPUT.PUT_LINE('Produkt dodany do zamówienia.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Produkt nie mógł być dodany do zamówienia - nie jest dostępny, bądź nie istnieje.');
            END IF;
        ELSE 
            DBMS_OUTPUT.PUT_LINE('Brak zamówienia lub zamówienie nie zrobione przez Ciebie.');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Zaloguj się. Brak odpowiednich uprawnień.');
    END IF;
END dodajDoZamowienia;


PROCEDURE wyswietl_zamowienia(odKiedy DATE DEFAULT TO_DATE('2000-01-01','YYYY-MM-DD'), doKiedy DATE DEFAULT SYSDATE)
IS
BEGIN
    --CASE rola
        --WHEN 'USER' THEN
        IF rola='USER' THEN
            FOR rek IN (SELECT * FROM zamowienia WHERE userID = userIDz AND terminRozp >= odKiedy AND terminRozp <= SYSDATE) LOOP
                DBMS_OUTPUT.PUT_LINE(rek.zamowienieID||' - '||rek.terminRozp||' '||rek.status||', kurierem: '||rek.czyKurier);
                FOR ubr IN (SELECT z.ubranieID,u.nazwa,u.rozmiar,u.stan FROM zam_ubrania z INNER JOIN ubrania u ON (z.ubranieID = u.ubranieID) WHERE zamowienieID = rek.zamowienieID) LOOP
                    DBMS_OUTPUT.PUT_LINE('  '||ubr.ubranieID||' - '||ubr.nazwa||'('||ubr.rozmiar||') w stanie '||ubr.stan);
                END LOOP;
            END LOOP;
        ELSIF rola='PRAC' OR rola='ADMIN' THEN
        --WHEN 'PRAC' OR 'ADMIN' THEN
            FOR rek IN (SELECT * FROM zamowienia WHERE terminRozp >= odKiedy AND terminRozp <= SYSDATE) LOOP
                DBMS_OUTPUT.PUT_LINE(rek.zamowienieID||' przez '||rek.userID||' '||rek.terminRozp||' '||rek.status||', kurierem: '||rek.czyKurier);
            END LOOP;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Zaloguj się. Brak odpowiednich uprawnień.');
        END IF;
    --END CASE;
END wyswietl_zamowienia;


PROCEDURE wyswietl_szczegoly_zam(zamID NUMBER)
IS
	zam zamowienia%ROWTYPE;
BEGIN
	IF rola='USER' THEN
		BEGIN
			SELECT * INTO zam FROM zamowienia WHERE zamowienieID = zamID AND userID = userIDz;
		EXCEPTION 
			WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak takiego zamówienia.'); RETURN;
		END;
	ELSIF rola='PRAC' OR rola='ADMIN' THEN
		BEGIN
			SELECT * INTO zam FROM zamowienia WHERE zamowienieID = zamID;
		EXCEPTION 
			WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak takiego zamówienia.'); RETURN;
		END;
	ELSE
		DBMS_OUTPUT.PUT_LINE('Zaloguj się. Brak odpowiednich uprawnień.');
		RETURN;
	END IF;
	
	DBMS_OUTPUT.PUT_LINE(zam.zamowienieID||' - '||zam.terminRozp||' '||zam.status||', kurierem: '||zam.czyKurier);
	FOR ubr IN (SELECT z.ubranieID,u.nazwa,u.rozmiar,u.stan FROM zam_ubrania z INNER JOIN ubrania u ON (z.ubranieID = u.ubranieID) WHERE z.zamowienieID = zam.zamowienieID) LOOP
		DBMS_OUTPUT.PUT_LINE('  '||ubr.ubranieID||' - '||ubr.nazwa||'('||ubr.rozmiar||') w stanie '||ubr.stan);
	END LOOP;
	IF zam.czyKurier = 0 THEN DBMS_OUTPUT.PUT_LINE('Dostawa: Odbiór osobisty');
	ELSE 
		DBMS_OUTPUT.PUT_LINE('Dostawa: ');
		FOR dost IN (SELECT d.nr_listu, d.przew_data, d.dostarczono, a.ulica, a.numer, a.kod_pocztowy,a.miasto FROM dostawy d INNER JOIN adresy a ON (d.adresID = a.adresID) WHERE d.zamowienieID = zamID) LOOP
			DBMS_OUTPUT.PUT_LINE('Nr listu: '||dost.nr_listu||', odbiór: '||dost.przew_data||', na adres: '||dost.ulica||' '||dost.numer||', '||dost.kod_pocztowy||' '||dost.miasto||' - odebrano: '||dost.dostarczono);
		END LOOP;
	END IF;
	
END;


PROCEDURE wyswietlAdresyDostawy(usID NUMBER DEFAULT NULL)
IS
BEGIN
	IF rola = 'ADMIN' OR rola = 'PRAC' THEN
		IF userIDz IS NULL THEN
			DBMS_OUTPUT.PUT_LINE('Nie podano ID użytkownika.');
		ELSE
			DBMS_OUTPUT.PUT_LINE('Adresy dostawy uzytkownika '||usID||': ');
			FOR a IN (SELECT * FROM adresy WHERE userID = userIDz) LOOP
				DBMS_OUTPUT.PUT_LINE(a.adresID||'. '||a.ulica||' '||a.numer||', '||a.kod_pocztowy||' '||a.miasto);
			END LOOP;
		END IF;
	ELSIF rola = 'USER' THEN
		DBMS_OUTPUT.PUT_LINE('Twoje adresy dostawy: ');
		FOR a IN (SELECT * FROM adresy WHERE userID = userIDz) LOOP
			DBMS_OUTPUT.PUT_LINE(a.adresID||'. '||a.ulica||' '||a.numer||', '||a.kod_pocztowy||' '||a.miasto);
		END LOOP;
	ELSE 
		DBMS_OUTPUT.PUT_LINE('Zaloguj się. Brak odpowiednich uprawnień.');
	END IF;
END;


FUNCTION dodajAdresDostawy(ulica VARCHAR,numer VARCHAR,kod_pocztowy VARCHAR,miasto VARCHAR)
RETURN NUMBER
IS
	nowyAdresID NUMBER;
BEGIN
	IF rola IS NOT NULL THEN
		nowyAdresID := adresy_seq.nextval;
		INSERT INTO adresy VALUES (nowyAdresID,userIDz,ulica,numer,kod_pocztowy,miasto);
		COMMIT;
		RETURN nowyAdresID;
	ELSE
		DBMS_OUTPUT.PUT_LINE('Zaloguj się. Brak odpowiednich uprawnień.');
        RETURN NULL;
	END IF;
END;


PROCEDURE zamowKurieraDoZwrotu(zamID NUMBER)
IS
	nowaDostID NUMBER;
	zam zamowienia%ROWTYPE;
BEGIN
	IF rola = 'ADMIN' OR rola = 'PRAC' THEN
		SELECT * INTO zam FROM zamowienia WHERE zamowienieID = zamID;
	ELSIF rola = 'USER' THEN
		SELECT * INTO zam FROM zamowienia WHERE zamowienieID = zamID AND userID = userIDz;
	ELSE
		DBMS_OUTPUT.PUT_LINE('Zaloguj się. Brak odpowiednich uprawnień.');
		RETURN;
	END IF;
	
	IF zam.status = 'ODEBRANEKLIENT' THEN
		nowaDostID := dostawy_seq.nextval;
		INSERT INTO dostawy VALUES (nowaDostID,'ASD543FDS'||nowaDostID,zamID,SYSDATE+2,1,0);
		UPDATE zamowienia SET status = 'KURIERKLIENT' WHERE zamowienieID = zamID;
		COMMIT;
		DBMS_OUTPUT.PUT_LINE('Kurier do zamówienia '||zamID||' umówiony.');
	ELSE 
		DBMS_OUTPUT.PUT_LINE('Do zamówienia '||zamID|| ' nie może być umówiony kurier.');
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak takiego zamówienia.');
END;


PROCEDURE wyswietlKlientow
IS
BEGIN
	IF rola = 'ADMIN' OR rola = 'PRAC' THEN
		FOR prac IN (SELECT * FROM users WHERE typ_konta = 'USER') LOOP
			DBMS_OUTPUT.PUT_LINE(prac.userID||'. '||prac.imie||' '||prac.nazwisko||' ur. '||prac.data_ur||' ('||prac.login||')');
		END LOOP;
	ELSE
		DBMS_OUTPUT.PUT_LINE('Brak odpowiednich uprawnień.');
	END IF;
END wyswietlKlientow;


PROCEDURE przedluzAbonament(ZuserID NUMBER, ile_miesiecy NUMBER DEFAULT 1)
IS
    abonDo DATE;
BEGIN
    IF rola = 'ADMIN' OR rola = 'PRAC' THEN
        SELECT abonament_do INTO abonDo FROM users WHERE userID = userIDz;
        IF abonDo is NULL OR abonDo < SYSDATE THEN
            UPDATE users SET abonament_do = ADD_Months(SYSDATE,ile_miesiecy) WHERE userID = ZuserID; 
            DBMS_OUTPUT.PUT_LINE('Przedłużono abonament do '||ADD_Months(SYSDATE,ile_miesiecy)||'.');
        ELSE
            UPDATE users SET abonament_do = ADD_Months(abonament_do,ile_miesiecy) WHERE userID = ZuserID;
            DBMS_OUTPUT.PUT_LINE('Przedłużono abonament do '||ADD_Months(abonDo,ile_miesiecy)||'.');
        END IF;
		COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Brak odpowiednich uprawnień.');
    END IF;
    
END przedluzAbonament;


PROCEDURE dodaj_ubranie(nazwa VARCHAR,rozmiar VARCHAR,stan VARCHAR,czyMeskie NUMBER,dostepne NUMBER,kategoria VARCHAR)
IS
BEGIN
    IF rola = 'ADMIN' OR rola = 'PRAC' THEN
        INSERT INTO ubrania VALUES (ubrania_seq.nextval,nazwa,rozmiar,stan,czyMeskie,dostepne,kategoria);
		COMMIT;
        DBMS_OUTPUT.PUT_LINE('Dodano nowe ubranie - '||nazwa||'.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Brak odpowiednich uprawnień.');
    END IF;
END dodaj_ubranie;


PROCEDURE dodaj_kategorie(nazwa VARCHAR, opis VARCHAR)
IS
BEGIN
    IF rola = 'ADMIN' OR rola = 'PRAC' THEN
        INSERT INTO kategorie VALUES (nazwa,opis);
		DBMS_OUTPUT.PUT_LINE('Dodano nową kategorię - '||nazwa||'.');
		COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Brak odpowiednich uprawnień.');
    END IF;
END dodaj_kategorie;


PROCEDURE oddaj_do_utylizacji(ubranieIDz NUMBER)
IS
    zam_id NUMBER := 0;
    dostepne NUMBER;
    zam zamowienia%ROWTYPE;
BEGIN
    IF rola = 'ADMIN' OR rola = 'PRAC' THEN
        BEGIN 
            SELECT dostepne INTO dostepne FROM ubrania WHERE ubranieID = ubranieIDz;
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            DBMS_OUTPUT.PUT_LINE('Brak ubrania o podanym ID.');
            RETURN;
        END;
        
        UPDATE ubrania SET dostepne = 0, stan = 'UTYLIZACJA' WHERE ubranieID = ubranieIDz;
        DBMS_OUTPUT.PUT_LINE('Ubranie oznaczone do utylizacji.');
		COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Brak odpowiednich uprawnień.');
    END IF;
END oddaj_do_utylizacji;


PROCEDURE zmien_status(zamowienieIDz NUMBER, statusZ VARCHAR)
IS
BEGIN
    IF rola = 'ADMIN' OR rola = 'PRAC' THEN
        UPDATE zamowienia SET status = statusZ WHERE zamowienieID = zamowienieIDz;
		IF statusZ = 'ZAKONCZONE' THEN
			FOR ubr IN (SELECT * FROM zam_ubrania WHERE zamowienieID = zamowienieIDz) LOOP
				UPDATE ubrania SET dostepne = 1 WHERE ubranieID = ubr.ubranieID AND stan != 'UTYLIZACJA';
			END LOOP;
		ELSIF statusZ = 'ODEBRANEKLIENT' OR statusZ = 'ODEBRANEPLACOWKA' THEN
			UPDATE dostawy SET dostarczono = 1 WHERE zamowienieID = zamowienieIDz;
		END IF;
		COMMIT;
        DBMS_OUTPUT.PUT_LINE('Status zamówienia zmieniony.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Brak odpowiednich uprawnień.');
    END IF;
END zmien_status;


PROCEDURE aktualizuj_stan_ubrania(ubranieIDz NUMBER, Zstan VARCHAR)
IS
BEGIN
	IF rola = 'ADMIN' OR rola = 'PRAC' THEN
		UPDATE ubrania SET stan = Zstan WHERE ubranieID = ubranieIDz;
		COMMIT;
		DBMS_OUTPUT.PUT_LINE('Status ubrania zmieniony na '||Zstan||'.');
	ELSE
		DBMS_OUTPUT.PUT_LINE('Brak odpowiednich uprawnień.');
	END IF;
END aktualizuj_stan_ubrania;

PROCEDURE dodaj_pracownika(Zlogin VARCHAR,haslo VARCHAR,imie VARCHAR,nazwisko VARCHAR,data_ur DATE)
IS
    u NUMBER;
    LoginZajetyException EXCEPTION;
BEGIN
	IF rola = 'ADMIN' THEN
		BEGIN
			SELECT userID INTO u FROM users WHERE login = Zlogin;
		EXCEPTION 
			WHEN NO_DATA_FOUND THEN u := NULL; 
		END;
		IF u is not null THEN RAISE LoginZajetyException; END IF;
		INSERT INTO users VALUES (users_seq.nextval,Zlogin,haslo,imie,nazwisko,data_ur,'PRAC',NULL);
		COMMIT;
		DBMS_OUTPUT.PUT_LINE('Dodano pracownika.');
	ELSE
		DBMS_OUTPUT.PUT_LINE('Brak odpowiednich uprawnień.');
	END IF;
END dodaj_pracownika;


PROCEDURE wyswietl_pracownikow
IS
BEGIN
	IF rola = 'ADMIN' THEN
		FOR prac IN (SELECT * FROM users WHERE typ_konta = 'PRAC') LOOP
			DBMS_OUTPUT.PUT_LINE(prac.userID||'. '||prac.imie||' '||prac.nazwisko||' ur. '||prac.data_ur||' ('||prac.login||')');
		END LOOP;
	ELSE
		DBMS_OUTPUT.PUT_LINE('Brak odpowiednich uprawnień.');
	END IF;
END wyswietl_pracownikow;


PROCEDURE raport(terminOd DATE, terminDo DATE)
IS
    zam NUMBER := 0;
    ubrania NUMBER := 0;
    ubr NUMBER := 0;
	abon NUMBER := 0;
BEGIN
    IF rola = 'ADMIN' THEN
        FOR z IN (SELECT zamowienieID FROM zamowienia WHERE terminRozp >= terminOd AND terminRozp < terminDo) LOOP
            zam := zam + 1;
            SELECT COUNT(zamowienieID) INTO ubr FROM zam_ubrania WHERE zamowienieID = z.zamowienieID;
            ubrania := ubrania + ubr;
        END LOOP;
		SELECT SUM(ile_miesiecy) INTO abon FROM zakupyAbonamentu WHERE data_zakupu >= terminOd AND data_zakupu < terminDo;
		DBMS_OUTPUT.PUT_LINE('Okres czasu '||terminOd||' - '||terminDo||': ');
        DBMS_OUTPUT.PUT_LINE('Zamówień: '||zam||', zamówionych ubrań: '||ubrania);
		DBMS_OUTPUT.PUT_LINE('Kupionych abonamentów: '||abon);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Brak odpowiednich uprawnień.');
    END IF;
END raport;


END wypozyczalnia;