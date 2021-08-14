EXEC DBMS_OUTPUT.PUT_LINE('Zalogowany. Twoje ID: '||wypozyczalnia.login('pracownik','haslo'));
EXEC wypozyczalnia.wyswietl_zamowienia();
EXEC wypozyczalnia.wyswietl_szczegoly_zam(4);
EXEC wypozyczalnia.zmien_status(4, 'PRZYGOTOWYWANE');
EXEC DBMS_OUTPUT.PUT_LINE('Wyswietlenie zamowien (stworzonych po 20 maja) po zmianie statusu zamowienia nr 4: ');
EXEC wypozyczalnia.wyswietl_zamowienia(TO_DATE('2021-05-20','YYYY-MM-DD'));
EXEC wypozyczalnia.zmien_status(4, 'KURIERPLACOWKA');
EXEC wypozyczalnia.zmien_status(4, 'WDRODZEKLIENT');
EXEC wypozyczalnia.zmien_status(4, 'ODEBRANEKLIENT');
EXEC wypozyczalnia.zmien_status(4, 'WDRODZEPLACOWKA');
EXEC wypozyczalnia.zmien_status(4, 'ODEBRANEPLACOWKA');
EXEC wypozyczalnia.zmien_status(4, 'SPRAWDZANE');
EXEC wypozyczalnia.zmien_status(4, 'PIELEGNACJA');
EXEC wypozyczalnia.zmien_status(4, 'ZAKONCZONE');

EXEC wypozyczalnia.dodaj_kategorie('KAPELUSZE', 'Wszelkiego rodzaju wyjsciowe nakrycia glowy');
EXEC wypozyczalnia.dodaj_ubranie('testowy kapelusz','-','BARDZO DOBRY',1,1,'KAPELUSZE');
EXEC wypozyczalnia.wyswietl_dostepne_ubrania(1);
EXEC wypozyczalnia.oddaj_do_utylizacji(28);
EXEC wypozyczalnia.aktualizuj_stan_ubrania(8,'Swietny');

EXEC DBMS_OUTPUT.PUT_LINE('Wyswietlenie wszystkich uzytkownikow: ');
EXEC wypozyczalnia.wyswietlKlientow();