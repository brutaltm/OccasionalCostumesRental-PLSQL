EXEC wypozyczalnia.register('testUser','haslo','Test','Testowy',TO_DATE('1999-09-09','YYYY-MM-DD'));
EXEC DBMS_OUTPUT.PUT_LINE('Zalogowany. Twoje ID: '||wypozyczalnia.login('testUser','haslo'));

EXEC wypozyczalnia.wyswietlAdresyDostawy();
EXEC DBMS_OUTPUT.PUT_LINE(wypozyczalnia.dodajAdresDostawy('Prosta','15B','05-300','Minsk Maz'));
EXEC wypozyczalnia.wyswietlAdresyDostawy();
EXEC wypozyczalnia.wykupAbonament();
EXEC DBMS_OUTPUT.PUT_LINE('Nr zamowienia: '||wypozyczalnia.stworzZamowienie(1,104));
EXEC wypozyczalnia.wyswietl_dostepne_ubrania(1,'BUTY');
EXEC wypozyczalnia.dodajDoZamowienia(4,20);
EXEC wypozyczalnia.wyswietl_dostepne_ubrania(1,'BUTY');
EXEC wypozyczalnia.wyswietl_zamowienia();
EXEC wypozyczalnia.wyswietl_szczegoly_zam(4);
EXEC wypozyczalnia.zamowKurieraDoZwrotu(4);