EXEC DBMS_OUTPUT.PUT_LINE('Zalogowany. Twoje ID: '||wypozyczalnia.login('admin','haslo'));
EXEC DBMS_OUTPUT.PUT_LINE('Wyswietlenie wszystkich pracownikow: ');
EXEC wypozyczalnia.wyswietl_pracownikow();
EXEC wypozyczalnia.dodaj_pracownika('pracTest','haslo','Adam','Testowy',TO_DATE('2000-07-07','YYYY-MM-DD'));
EXEC DBMS_OUTPUT.PUT_LINE('Wyswietlenie wszystkich pracownikow po dodaniu pracownika: ');
EXEC wypozyczalnia.wyswietl_pracownikow();

EXEC DBMS_OUTPUT.PUT_LINE('Wyswietlenie raportu sprzedazy w 2021 roku: ');
EXEC wypozyczalnia.raport(TO_DATE('2021-01-01','YYYY-MM-DD'), SYSDATE);