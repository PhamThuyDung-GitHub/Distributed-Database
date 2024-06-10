---------------------------clean all current object-----------------------------

BEGIN
    FOR CUR_REC IN (
        SELECT
            OBJECT_NAME,
            OBJECT_TYPE
        FROM
            USER_OBJECTS
        WHERE
            OBJECT_TYPE IN ( 'TABLE', 'VIEW', 'MATERIALIZED VIEW', 'PACKAGE', 'PROCEDURE', 'FUNCTION', 'SEQUENCE', 'SYNONYM', 'PACKAGE BODY' )
    ) LOOP
        BEGIN
            IF CUR_REC.OBJECT_TYPE = 'TABLE' THEN
                EXECUTE IMMEDIATE 'DROP '
                                  || CUR_REC.OBJECT_TYPE
                                  || ' "'
                                  || CUR_REC.OBJECT_NAME
                                  || '" CASCADE CONSTRAINTS';
            ELSE
                EXECUTE IMMEDIATE 'DROP '
                                  || CUR_REC.OBJECT_TYPE
                                  || ' "'
                                  || CUR_REC.OBJECT_NAME
                                  || '"';
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE ( 'FAILED: DROP '
                                       || CUR_REC.OBJECT_TYPE
                                       || ' "'
                                       || CUR_REC.OBJECT_NAME
                                       || '"' );
        END;
    END LOOP;

    FOR CUR_REC IN (
        SELECT
            *
        FROM
            ALL_SYNONYMS
        WHERE
            TABLE_OWNER IN (
                SELECT
                    USER
                FROM
                    DUAL
            )
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM '
                              || CUR_REC.SYNONYM_NAME;
        END;
    END LOOP;
END;

--------------------------------------------------------------------------------


-----------------run sql plus to connect m2-------------------------------------


connect system/meo123;

DROP USER C##M2 CASCADE;

DROP ROLE C##ROLE_USER_GUEST2;

DROP USER C##GUEST2 CASCADE;

CREATE USER C##M2 IDENTIFIED BY a123;

GRANT CONNECT, RESOURCE, CREATE DATABASE LINK, CREATE ROLE, UNLIMITED TABLESPACE TO C##M2;

connect c##m2/a123;




--------create table for m2 ----------------------------------------------------


CREATE TABLE STOCK(
    STOCK_ID NUMBER,
    STOCK_NAME VARCHAR2(255),
    PRIMARY KEY(STOCK_ID)
);

INSERT INTO STOCK (STOCK_ID, STOCK_NAME) VALUES (3, 'Stock 3');
INSERT INTO STOCK (STOCK_ID, STOCK_NAME) VALUES (4, 'Stock 4');

select * from stock;

CREATE TABLE PEN(
    PEN_ID NUMBER,
    PEN_TITLE VARCHAR2(255),
    PEN_PRICE NUMBER,
    PRIMARY KEY(PEN_ID)
);


INSERT INTO PEN (PEN_ID, PEN_TITLE, PEN_PRICE) VALUES (1, 'Pen 1', 10.00);
INSERT INTO PEN (PEN_ID, PEN_TITLE, PEN_PRICE) VALUES (2, 'Pen 2', 12.00);
INSERT INTO PEN (PEN_ID, PEN_TITLE, PEN_PRICE) VALUES (3, 'Pen 3', 9.50);
INSERT INTO PEN (PEN_ID, PEN_TITLE, PEN_PRICE) VALUES (4, 'Pen 4', 11.00);
INSERT INTO PEN (PEN_ID, PEN_TITLE, PEN_PRICE) VALUES (5, 'Pen 5', 10.50);


CREATE TABLE STOCK_DETAIL(
    PEN_ID NUMBER,
    STOCK_ID NUMBER,
    STOCK_AVAILABLE NUMBER,
    PRIMARY KEY(PEN_ID, STOCK_ID),
    FOREIGN KEY (STOCK_ID) REFERENCES STOCK(STOCK_ID),
    FOREIGN KEY (PEN_ID) REFERENCES PEN(PEN_ID)
);

INSERT INTO STOCK_DETAIL (PEN_ID, STOCK_ID, STOCK_AVAILABLE) VALUES (1, 3, 100);
INSERT INTO STOCK_DETAIL (PEN_ID, STOCK_ID, STOCK_AVAILABLE) VALUES (2, 3, 100);
INSERT INTO STOCK_DETAIL (PEN_ID, STOCK_ID, STOCK_AVAILABLE) VALUES (3, 3, 100);
INSERT INTO STOCK_DETAIL (PEN_ID, STOCK_ID, STOCK_AVAILABLE) VALUES (4, 3, 100);
INSERT INTO STOCK_DETAIL (PEN_ID, STOCK_ID, STOCK_AVAILABLE) VALUES (5, 3, 100);

INSERT INTO STOCK_DETAIL (PEN_ID, STOCK_ID, STOCK_AVAILABLE) VALUES (1, 4, 100);
INSERT INTO STOCK_DETAIL (PEN_ID, STOCK_ID, STOCK_AVAILABLE) VALUES (2, 4, 100);
INSERT INTO STOCK_DETAIL (PEN_ID, STOCK_ID, STOCK_AVAILABLE) VALUES (3, 4, 100);
INSERT INTO STOCK_DETAIL (PEN_ID, STOCK_ID, STOCK_AVAILABLE) VALUES (4, 4, 100);
INSERT INTO STOCK_DETAIL (PEN_ID, STOCK_ID, STOCK_AVAILABLE) VALUES (5, 4, 100);

select * from stock_detail;

CREATE TABLE CUSTOMER (
    CUST_ID NUMBER,
    CUST_NAME VARCHAR2(255),
    CUST_NUMBER_PHONE VARCHAR2(15),
    PRIMARY KEY(CUST_ID)
);

CREATE TABLE ORDERS(
    ORDER_ID NUMBER,
    STOCK_ID NUMBER,
    CUST_ID NUMBER,
    TOTAL NUMBER,
    ORDER_DATE DATE DEFAULT SYSDATE NOT NULL,
    PRIMARY KEY(ORDER_ID),
    FOREIGN KEY (STOCK_ID) REFERENCES STOCK(STOCK_ID),
    FOREIGN KEY (CUST_ID) REFERENCES CUSTOMER(CUST_ID)
);

CREATE TABLE ORDERS_DETAILS(
    ORDER_ID NUMBER,
    PEN_ID NUMBER,
    QUATITY NUMBER,
    PRICE NUMBER,
    PRIMARY KEY(ORDER_ID, PEN_ID),
    FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ORDER_ID),
    FOREIGN KEY (PEN_ID) REFERENCES PEN(PEN_ID)
);


------------------------create database link------------------------------------

drop database link db_m1;
drop database link db_m2;


          
CREATE DATABASE LINK DB_M1

    CONNECT TO c##m1 IDENTIFIED BY a123

USING '(DESCRIPTION=

         (ADDRESS=(PROTOCOL=TCP)(HOST=26.19.140.194)(PORT=1521))

          (CONNECT_DATA=(SERVICE_NAME=orcl))

          )';

select * from pen@db_m1;


CREATE DATABASE LINK DB_M2

    CONNECT TO c##m2 IDENTIFIED BY a123

USING '(DESCRIPTION=

         (ADDRESS=(PROTOCOL=TCP)(HOST=26.252.104.218)(PORT=1521))

          (CONNECT_DATA=(SERVICE_NAME=orcl))

          )'; 
          
select * from pen@db_m2;



---------create role name for m2 -----------------------------------------------

connect system/meo 123;
 
CREATE ROLE C##ROLE_USER_GUEST2 NOT IDENTIFIED;

GRANT SELECT, INSERT, UPDATE, DELETE ON C##M2.STOCK TO C##ROLE_USER_GUEST2;

GRANT SELECT, INSERT, UPDATE, DELETE ON C##M2.PEN TO C##ROLE_USER_GUEST2;

GRANT SELECT, INSERT, UPDATE, DELETE ON C##M2.STOCK_DETAIL TO C##ROLE_USER_GUEST2;

GRANT SELECT, INSERT, UPDATE, DELETE ON C##M2.IMPORT_PEN TO C##ROLE_USER_GUEST2;

GRANT SELECT, INSERT, UPDATE, DELETE ON C##M2.IMPORT_PEN_DETAIL TO C##ROLE_USER_GUEST2;

GRANT SELECT, INSERT, UPDATE, DELETE ON C##M2.CUSTOMER TO C##ROLE_USER_GUEST2;

GRANT SELECT, INSERT, UPDATE, DELETE ON C##M2.ORDERS TO C##ROLE_USER_GUEST2;

GRANT SELECT, INSERT, UPDATE, DELETE ON C##M2.ORDERS_DETAILS TO C##ROLE_USER_GUEST2;

CREATE USER C##GUEST2 IDENTIFIED BY GUEST;

GRANT CONNECT TO C##GUEST2;

GRANT C##ROLE_USER_GUEST2 TO C##GUEST2;

--------------------------------------------------------------------------------




---------------------trigger delete---------------------------------------------

CREATE OR REPLACE TRIGGER ORDERS_DETAILS_AFTER_DELETE AFTER
DELETE ON ORDERS_DETAILS FOR EACH ROW
DECLARE
    CURR_STOCK_ID NUMBER;
BEGIN
    SELECT STOCK_ID INTO CURR_STOCK_ID FROM ORDERS WHERE ORDER_ID = :OLD.ORDER_ID;

    -- Update total amount of the order
    UPDATE ORDERS
    SET TOTAL = TOTAL - :OLD.QUATITY * :OLD.PRICE
    WHERE ORDER_ID = :OLD.ORDER_ID;

    -- Update stock availability
    UPDATE STOCK_DETAIL
    SET STOCK_AVAILABLE = STOCK_AVAILABLE + :OLD.QUATITY
    WHERE PEN_ID = :OLD.PEN_ID AND STOCK_ID = CURR_STOCK_ID;
END;
/


CREATE OR REPLACE TRIGGER ORDERS_BEFORE_DELETE BEFORE
DELETE ON ORDERS FOR EACH ROW
BEGIN
    DELETE FROM ORDERS_DETAILS WHERE ORDER_ID = :OLD.ORDER_ID;
END;
/

--------------------------------------------------------------------------------


--------------------------------trigger insert----------------------------------


 --cập nhật giá trước khi lưu thông tin sản phẩm vào đơn hàng
CREATE OR REPLACE TRIGGER ORDERS_DETAILS_BEFORE_INSERT BEFORE INSERT ON ORDERS_DETAILS FOR EACH ROW DECLARE O_PRICE VARCHAR2(
    10
);
STOCK_AVAILABLE_PEN INT;
CURR_STOCK_ID INT;
BEGIN
    SELECT
        PEN_PRICE INTO O_PRICE
    FROM
        PEN
    WHERE
        PEN_ID=:NEW.PEN_ID;
    :NEW.PRICE := O_PRICE;
END;


 --cập nhật tổng đơn hàng sau khi thêm sản phẩm vào đơn hàng
CREATE OR REPLACE TRIGGER ORDERS_DETAILS_AFTER_INSTERT AFTER INSERT ON ORDERS_DETAILS FOR EACH ROW DECLARE CURR_STOCK_ID NUMBER;
BEGIN
    SELECT
        STOCK_ID INTO CURR_STOCK_ID
    FROM
        ORDERS
    WHERE
        ORDER_ID=:NEW.ORDER_ID;
 -- cập nhật tổng tiền của đơn hàng
    UPDATE ORDERS
    SET
        TOTAL = TOTAL + :NEW.QUATITY * :NEW.PRICE
    WHERE
        ORDERS.ORDER_ID = :NEW.ORDER_ID;
 --cập nhật số lượng pen có trong kho
    UPDATE STOCK_DETAIL
    SET
        STOCK_DETAIL.STOCK_AVAILABLE = STOCK_DETAIL.STOCK_AVAILABLE - :NEW.QUATITY
    WHERE
        STOCK_DETAIL.PEN_ID = :NEW.PEN_ID
        AND STOCK_DETAIL.STOCK_ID=CURR_STOCK_ID;
END;


--------------------------------------------------------------------------------


-----------------------trigger update-------------------------------------------



 --cập nhật số lượng pen sau khi cập nhật chi tiết đơn hàng xuất kho
CREATE OR REPLACE TRIGGER ORDERS_DETAILS_AFTER_UPDATE AFTER
UPDATE OF QUATITY ON ORDERS_DETAILS FOR EACH ROW DECLARE SUBTOTAL INT;
CURR_STOCK_ID INT;
BEGIN
    SELECT
        STOCK_ID INTO CURR_STOCK_ID
    FROM
        ORDERS
    WHERE
        ORDER_ID=:OLD.ORDER_ID;
 -- cập nhật tổng tiền của đơn hàng
    UPDATE ORDERS
    SET
        TOTAL = TOTAL+ :NEW.QUATITY * :OLD.PRICE -:OLD.QUATITY * :OLD.PRICE
    WHERE
        ORDER_ID = :OLD.ORDER_ID;
 --cập nhật số lượng pen có trong kho
    UPDATE STOCK_DETAIL
    SET
        STOCK_AVAILABLE = STOCK_AVAILABLE + :OLD.QUATITY- :NEW.QUATITY
    WHERE
        PEN_ID = :OLD.PEN_ID
        AND STOCK_ID=CURR_STOCK_ID;
END;


--------------------------------------------------------------------------------



--------------------------------------------------------------------------------

------------------create procedure----------------------------------------------


------------------------create procedure insert_customer----------------------------------------

create or replace procedure insert_customer(n_cust_id in number ,n_cust_name in varchar2,n_cust_number_phone varchar2)
as
begin
    if(0<n_cust_id and n_cust_id<=100) then
        insert into C##M1.customer@DB_M1(cust_id,cust_name,cust_number_phone) values(n_cust_id,n_cust_name,n_cust_number_phone);
    ELSIF(100<n_cust_id and n_cust_id<=200) then
        insert into   C##M2.customer@DB_M2(cust_id,cust_name,cust_number_phone)  values(n_cust_id,n_cust_name,n_cust_number_phone);
    else
         dbms_output.put_line('Id customer in range [1..200].');
    end if;
    commit;
end;


 ------------ start test procedure insert_customer -----------------------------
  
begin
    insert_customer(101 ,'Hoa','0231-111-889');
end;
 
begin
    insert_customer(102 ,'Hoong','0231-111-123');
end; 

begin
    insert_customer(103 ,'Giau','0231-111-129');
end;


 
select * from C##M2.customer@DB_M2; 
 
 
----------------------- end test procedure insert_customer----------------------


-----------------create procedure for insert_order------------------------------
 
 
CREATE OR REPLACE PROCEDURE insert_order(
    n_order_id IN NUMBER,
    n_stock_id IN NUMBER,
    n_cust_id IN NUMBER
) AS
    count_cust NUMBER;
    count_stock NUMBER;
BEGIN
    -- Check if cust_id exists in C##M1.customer@DB_M1
    SELECT COUNT(cust_id) INTO count_cust
    FROM C##M1.customer@DB_M1
    WHERE cust_id = n_cust_id;

    IF count_cust = 1 THEN
        -- Check if stock_id exists in C##M1.stock@DB_M1
        SELECT COUNT(stock_id) INTO count_stock
        FROM C##M1.stock@DB_M1
        WHERE stock_id = n_stock_id;

        IF count_stock = 1 THEN
            -- Check the range for n_order_id
            IF n_order_id > 0 AND n_order_id <= 100 THEN
                -- Insert into C##M1.orders@DB_M1
                INSERT INTO C##M1.orders@DB_M1 (order_id, stock_id, cust_id, total)
                VALUES (n_order_id, n_stock_id, n_cust_id, 0);
            ELSE
                DBMS_OUTPUT.PUT_LINE('Id order in range [1..100]');
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Id stock invalid');
        END IF;
    ELSE
        -- Check if cust_id exists in C##M2.customer@DB_M2
        SELECT COUNT(cust_id) INTO count_cust
        FROM C##M2.customer@DB_M2
        WHERE cust_id = n_cust_id;

        IF count_cust = 1 THEN
            -- Check if stock_id exists in C##M2.stock@DB_M2
            SELECT COUNT(stock_id) INTO count_stock
            FROM C##M2.stock@DB_M2
            WHERE stock_id = n_stock_id;

            IF count_stock = 1 THEN
                -- Check the range for n_order_id
                IF n_order_id > 100 AND n_order_id <= 200 THEN
                    -- Insert into C##M2.orders@DB_M2
                    INSERT INTO C##M2.orders@DB_M2 (order_id, stock_id, cust_id, total)
                    VALUES (n_order_id, n_stock_id, n_cust_id, 0);
                ELSE
                    DBMS_OUTPUT.PUT_LINE('Id order in range [100..200]');
                END IF;
            ELSE
                DBMS_OUTPUT.PUT_LINE('Id stock invalid');
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Id cust does not exist');
        END IF;
    END IF;

    COMMIT;
END;






----------------- start test procedure insert_order-----------------------------

begin
    --insert_order(n_order_id,n_stock_id, n_cust_id );
    insert_order(101,3, 101);
end;

begin
    --insert_order(n_order_id,n_stock_id, n_cust_id );
    insert_order(102,3, 102);
end;

begin
    --insert_order(n_order_id,n_stock_id, n_cust_id );
    insert_order(103,4, 103);
end;


select * from c##m2.orders@DB_M2;
 
---------------------- end test procedure insert_order--------------------------

----------------------create procedure for insert order detail------------------

 
CREATE OR REPLACE PROCEDURE INSERT_ORDER_DETAILS(n_order_id IN NUMBER, n_pen_id IN NUMBER, n_quatity IN NUMBER)
AS
    v_count INT;
    n_price INT;
    curr_stock_available INT;
    curr_stock_id INT;
BEGIN
    SAVEPOINT save_insert_order_details;

    -- Check if order exists in DB_M1
    SELECT COUNT(order_id) INTO v_count FROM C##M1.orders@DB_M1 WHERE order_id = n_order_id;
    IF v_count = 1 THEN
        SELECT NVL(MIN(pen_price), -1) INTO n_price FROM C##M1.pen@DB_M1 WHERE pen_id = n_pen_id;
        IF n_price > 0 THEN
            INSERT INTO C##M1.orders_details@DB_M1 (order_id, pen_id, quatity, price) VALUES (n_order_id, n_pen_id, n_quatity, n_price);
            SELECT stock_id INTO curr_stock_id FROM C##M1.orders@DB_M1 WHERE order_id = n_order_id;
            SELECT stock_available INTO curr_stock_available FROM C##M1.stock_detail@DB_M1 WHERE pen_id = n_pen_id AND stock_id = curr_stock_id;
            IF curr_stock_available >= 0 THEN
                COMMIT;
            ELSE 
                ROLLBACK TO save_insert_order_details;
            END IF;
        ELSE    
            dbms_output.put_line('Pen ID does not exist');
        END IF;
    ELSE
        -- Check if order exists in DB_M2
        SELECT COUNT(order_id) INTO v_count FROM C##M2.orders@DB_M2 WHERE order_id = n_order_id;
        IF v_count = 1 THEN
            SELECT NVL(MIN(pen_price), -1) INTO n_price FROM C##M2.pen@DB_M2 WHERE pen_id = n_pen_id;
            IF n_price > 0 THEN
                INSERT INTO C##M2.orders_details@DB_M2 (order_id, pen_id, quatity, price) VALUES (n_order_id, n_pen_id, n_quatity, n_price);
                SELECT stock_id INTO curr_stock_id FROM C##M2.orders@DB_M2 WHERE order_id = n_order_id;
                SELECT stock_available INTO curr_stock_available FROM C##M2.stock_detail@DB_M2 WHERE pen_id = n_pen_id AND stock_id = curr_stock_id;
                IF curr_stock_available >= 0 THEN
                    COMMIT;
                ELSE 
                    ROLLBACK TO save_insert_order_details;
            END IF;
        ELSE    
            dbms_output.put_line('Pen ID does not exist');
        END IF;
    ELSE
        dbms_output.put_line('Order ID does not exist');
    END IF;
  END IF;
END;
/


begin
--insert_order_details (n_order_id, n_pen_id, n_quatity)
insert_order_details (101, 2, 1);
end;

begin
--insert_order_details (n_order_id, n_pen_id, n_quatity)
insert_order_details (102, 3, 3);
end;

begin
--insert_order_details (n_order_id, n_pen_id, n_quatity)
insert_order_details (103, 2, 1);
end;


select * from C##M2.orders@DB_M2;
select * from C##M2.orders_details@DB_M2;
select * from C##M2.stock_detail@DB_M2;

select * from C##M1.orders@DB_M1;



------------------------procedure of orders details update----------------------
CREATE OR REPLACE PROCEDURE update_quatity_order_details (
    n_order_id IN NUMBER,
    n_pen_id IN NUMBER,
    n_quatity IN NUMBER
) AS
    count_rows NUMBER;
    curr_stock_available NUMBER;
    curr_stock_id NUMBER;
BEGIN
    SAVEPOINT save_update_quatity_order_details;

    -- Check in C##M1.orders_details@DB_M1
    SELECT COUNT(*)
    INTO count_rows
    FROM C##M1.orders_details@DB_M1
    WHERE order_id = n_order_id AND pen_id = n_pen_id;

    IF count_rows = 1 THEN
        -- Process for DB_M1
        SELECT stock_id INTO curr_stock_id FROM C##M1.orders@DB_M1 WHERE order_id = n_order_id;
        UPDATE C##M1.orders_details@DB_M1 SET quatity = n_quatity WHERE order_id = n_order_id AND pen_id = n_pen_id;
    ELSE
        -- Process for DB_M2
        SELECT COUNT(*) INTO count_rows FROM C##M2.orders_details@DB_M2 WHERE order_id = n_order_id AND pen_id = n_pen_id;
        IF count_rows = 1 THEN
            SELECT stock_id INTO curr_stock_id FROM C##M2.orders@DB_M2 WHERE order_id = n_order_id;
            UPDATE C##M2.orders_details@DB_M2 SET quatity = n_quatity WHERE order_id = n_order_id AND pen_id = n_pen_id;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Order detail does not exist.');
        END IF;
    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO save_update_quatity_order_details;
        RAISE;
END;
/

------------ start test procedure update_quatity_order_details------------------

begin
--update_quatity_order_details (n_order_id, n_pen_id, n_quatity)
update_quatity_order_details (101,2, 5);
end;
 
select * from C##M2.orders@DB_M2;
select * from C##M2.orders_details@DB_M2;
select * from C##M2.stock_detail@DB_M2;
select * from C##M2.pen@DB_M2;



 
 
 ------------------create procedure for delete_orders_details--------------------



------------------create procedure for delete_orders_details--------------------

CREATE OR REPLACE PROCEDURE delete_orders_details (
    n_order_id IN NUMBER,
    n_pen_id IN NUMBER
) AS
    l_count NUMBER;
BEGIN
    -- Use a variable to store the count
    SELECT COUNT(order_id)
    INTO l_count
    FROM c##M1.orders_details@db_m1
    WHERE order_id = n_order_id AND pen_id = n_pen_id;

    IF l_count = 1 THEN
        DELETE FROM c##m1.orders_details@db_m1
        WHERE order_id = n_order_id AND pen_id = n_pen_id;
        COMMIT; -- Commit only when the deletion is successful
    ELSE
        -- Reset the count variable for the second query
        l_count := 0;

        SELECT COUNT(order_id)
        INTO l_count
        FROM c##M2.orders_details@db_m2
        WHERE order_id = n_order_id AND pen_id = n_pen_id;

        IF l_count = 1 THEN
            DELETE FROM c##M2.orders_details@db_m2
            WHERE order_id = n_order_id AND pen_id = n_pen_id;
            COMMIT; -- Commit only when the deletion is successful
        ELSE
            DBMS_OUTPUT.PUT_LINE('Order detail does not exist.');
        END IF;
    END IF;
END;
/



-- start test procedure delete_orders_details

begin
delete_orders_details (101, 2);
end;

select * from orders;
select * from orders_details;
select * from stock_detail;


-- end test procedure delete_orders_details-------------------------------------

-----------------create procedure for delete_order------------------------------


CREATE OR REPLACE PROCEDURE delete_order (
    n_order_id IN NUMBER
) AS
    l_count NUMBER;
BEGIN
    -- Check if the order_id exists in C##M1.orders@db_m1
    SELECT COUNT(order_id) INTO l_count
    FROM c##M1.orders@db_m1
    WHERE order_id = n_order_id;

    IF l_count = 1 THEN
        -- Delete order details
        DELETE FROM c##M1.orders_details@db_m1
        WHERE order_id = n_order_id;
        COMMIT; -- Commit only when the deletion is successful

        -- Delete order
        DELETE FROM c##M1.orders@db_m1
        WHERE order_id = n_order_id;
        COMMIT; -- Commit only when the deletion is successful
    ELSE
        -- Reset the count variable for the second query
        l_count := 0;

        -- Check if the order_id exists in C##M2.orders@db_m2
        SELECT COUNT(order_id) INTO l_count
        FROM c##M2.orders@db_m2
        WHERE order_id = n_order_id;

        IF l_count = 1 THEN
            -- Delete order details
            DELETE FROM c##M2.orders_details@db_m2
            WHERE order_id = n_order_id;
            COMMIT; -- Commit only when the deletion is successful

            -- Delete order
            DELETE FROM c##M2.orders@db_m2
            WHERE order_id = n_order_id;
            COMMIT; -- Commit only when the deletion is successful
        ELSE
            DBMS_OUTPUT.PUT_LINE('Order ID does not exist.');
        END IF;
    END IF;
END;
/


begin 
    delete_order(101);
end;

select * from orders;
select * from orders_details;
select * from stock_detail;




CREATE OR REPLACE PROCEDURE find_total_price_all_orders AS
    total_price_m1 NUMBER := 0;
    total_price_m2 NUMBER := 0;
    grand_total_price NUMBER;
BEGIN
    -- Calculate total price from db_m1
    SELECT SUM(price * quatity) INTO total_price_m1
    FROM C##M1.ORDERS_DETAILS@db_m1;

    -- Calculate total price from db_m2
    SELECT SUM(price * quatity) INTO total_price_m2
    FROM C##M2.ORDERS_DETAILS@db_m2;

    -- Calculate grand total
    grand_total_price := total_price_m1 + total_price_m2;

    -- Output the result
    DBMS_OUTPUT.PUT_LINE('Total Price from DB_M1: ' || total_price_m1);
    DBMS_OUTPUT.PUT_LINE('Total Price from DB_M2: ' || total_price_m2);
    DBMS_OUTPUT.PUT_LINE('Grand Total Price: ' || grand_total_price);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


BEGIN
    find_total_price_all_orders;
END;
