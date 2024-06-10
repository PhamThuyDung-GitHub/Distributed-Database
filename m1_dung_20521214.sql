---------------clean all current object-----------------------------------------

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
 -------------------create role name for m1--------------------------------------
CONNECT SYSTEM/MEO123;
CREATE ROLE C##ROLE_USER_GUEST1 NOT IDENTIFIED;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.STOCK TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.PEN TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.STOCK_DETAIL TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.IMPORT_PEN TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.IMPORT_PEN_DETAIL TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.CUSTOMER TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.ORDERS TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.ORDERS_DETAILS TO C##ROLE_USER_GUEST1;
CREATE USER C##GUEST1 IDENTIFIED BY GUEST;
GRANT C##ROLE_USER_GUEST1 TO C##GUEST1;
 ------------------------run sql plust to connect m1-----------------------------
 --------------------create table for m1-----------------------------------------
CREATE TABLE STOCK( STOCK_ID NUMBER, STOCK_NAME VARCHAR2(255), PRIMARY KEY(STOCK_ID) );
INSERT INTO STOCK (
    STOCK_ID,
    STOCK_NAME
) VALUES (
    1,
    'Stock 1'
);
INSERT INTO STOCK (
    STOCK_ID,
    STOCK_NAME
) VALUES (
    2,
    'Stock 2'
);
CREATE TABLE PEN( PEN_ID NUMBER, PEN_TITLE VARCHAR2(255), PEN_PRICE NUMBER, PRIMARY KEY(PEN_ID) );
INSERT INTO PEN (
    PEN_ID,
    PEN_TITLE,
    PEN_PRICE
) VALUES (
    1,
    'Pen 1',
    10.00
);
INSERT INTO PEN (
    PEN_ID,
    PEN_TITLE,
    PEN_PRICE
) VALUES (
    2,
    'Pen 2',
    12.00
);
INSERT INTO PEN (
    PEN_ID,
    PEN_TITLE,
    PEN_PRICE
) VALUES (
    3,
    'Pen 3',
    9.50
);
INSERT INTO PEN (
    PEN_ID,
    PEN_TITLE,
    PEN_PRICE
) VALUES (
    4,
    'Pen 4',
    11.00
);
INSERT INTO PEN (
    PEN_ID,
    PEN_TITLE,
    PEN_PRICE
) VALUES (
    5,
    'Pen 5',
    10.50
);
CREATE TABLE STOCK_DETAIL( PEN_ID NUMBER, STOCK_ID NUMBER, STOCK_AVAILABLE NUMBER, PRIMARY KEY(PEN_ID, STOCK_ID), FOREIGN KEY (STOCK_ID) REFERENCES STOCK(STOCK_ID), FOREIGN KEY (PEN_ID) REFERENCES PEN(PEN_ID) );
INSERT INTO STOCK_DETAIL (
    PEN_ID,
    STOCK_ID,
    STOCK_AVAILABLE
) VALUES (
    1,
    1,
    100
);
INSERT INTO STOCK_DETAIL (
    PEN_ID,
    STOCK_ID,
    STOCK_AVAILABLE
) VALUES (
    2,
    1,
    100
);
INSERT INTO STOCK_DETAIL (
    PEN_ID,
    STOCK_ID,
    STOCK_AVAILABLE
) VALUES (
    3,
    1,
    100
);
INSERT INTO STOCK_DETAIL (
    PEN_ID,
    STOCK_ID,
    STOCK_AVAILABLE
) VALUES (
    4,
    1,
    100
);
INSERT INTO STOCK_DETAIL (
    PEN_ID,
    STOCK_ID,
    STOCK_AVAILABLE
) VALUES (
    5,
    1,
    100
);
INSERT INTO STOCK_DETAIL (
    PEN_ID,
    STOCK_ID,
    STOCK_AVAILABLE
) VALUES (
    1,
    2,
    100
);
INSERT INTO STOCK_DETAIL (
    PEN_ID,
    STOCK_ID,
    STOCK_AVAILABLE
) VALUES (
    2,
    2,
    100
);
INSERT INTO STOCK_DETAIL (
    PEN_ID,
    STOCK_ID,
    STOCK_AVAILABLE
) VALUES (
    3,
    2,
    100
);
INSERT INTO STOCK_DETAIL (
    PEN_ID,
    STOCK_ID,
    STOCK_AVAILABLE
) VALUES (
    4,
    2,
    100
);
INSERT INTO STOCK_DETAIL (
    PEN_ID,
    STOCK_ID,
    STOCK_AVAILABLE
) VALUES (
    5,
    2,
    100
);
SELECT
    *
FROM
    STOCK_DETAIL;
CREATE TABLE CUSTOMER ( CUST_ID NUMBER, CUST_NAME VARCHAR2(255), CUST_NUMBER_PHONE VARCHAR2(15), PRIMARY KEY(CUST_ID) );
CREATE TABLE ORDERS( ORDER_ID NUMBER, STOCK_ID NUMBER, CUST_ID NUMBER, TOTAL NUMBER, ORDER_DATE DATE DEFAULT SYSDATE NOT NULL, PRIMARY KEY(ORDER_ID), FOREIGN KEY (STOCK_ID) REFERENCES STOCK(STOCK_ID), FOREIGN KEY (CUST_ID) REFERENCES CUSTOMER(CUST_ID) );
CREATE TABLE ORDERS_DETAILS( ORDER_ID NUMBER, PEN_ID NUMBER, QUATITY NUMBER, PRICE NUMBER, PRIMARY KEY(ORDER_ID, PEN_ID), FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ORDER_ID), FOREIGN KEY (PEN_ID) REFERENCES PEN(PEN_ID) );
 ------------------------create database link------------------------------------
DROP DATABASE LINK DB_M1;
DROP DATABASE LINK DB_M2;
CREATE DATABASE LINK DB_M1 CONNECT TO C##M1 IDENTIFIED BY A123 USING '(DESCRIPTION=

         (ADDRESS=(PROTOCOL=TCP)(HOST=26.19.140.194)(PORT=1521))

          (CONNECT_DATA=(SERVICE_NAME=orcl))

          )';
SELECT
    *
FROM
    PEN@DB_M1;
CREATE DATABASE LINK DB_M2 CONNECT TO C##M2 IDENTIFIED BY A123 USING '(DESCRIPTION=

         (ADDRESS=(PROTOCOL=TCP)(HOST=26.252.104.218)(PORT=1521))

          (CONNECT_DATA=(SERVICE_NAME=orcl))

          )';
SELECT
    *
FROM
    PEN@DB_M2;
 -------------------create role name for m1--------------------------------------
CONNECT SYSTEM/MEO123;
CREATE ROLE C##ROLE_USER_GUEST1 NOT IDENTIFIED;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.STOCK TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.PEN TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.STOCK_DETAIL TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.IMPORT_PEN TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.IMPORT_PEN_DETAIL TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.CUSTOMER TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.ORDERS TO C##ROLE_USER_GUEST1;
GRANT
SELECT,
    INSERT,
    UPDATE,
    DELETE
    ON C##M1.ORDERS_DETAILS TO C##ROLE_USER_GUEST1;
CREATE USER C##GUEST1 IDENTIFIED BY GUEST;
GRANT C##ROLE_USER_GUEST1 TO C##GUEST1;
 -------------------------------------------------------------------------------
 ---------------------trigger delete---------------------------------------------
 --------------------------
CREATE OR REPLACE TRIGGER ORDERS_DETAILS_AFTER_DELETE AFTER
DELETE ON ORDERS_DETAILS FOR EACH ROW DECLARE CURR_STOCK_ID NUMBER;
BEGIN
    SELECT
        STOCK_ID INTO CURR_STOCK_ID
    FROM
        ORDERS
    WHERE
        ORDER_ID = :OLD.ORDER_ID;
 -- Update total amount of the order
    UPDATE ORDERS
    SET
        TOTAL = TOTAL - :OLD.QUATITY * :OLD.PRICE
    WHERE
        ORDER_ID = :OLD.ORDER_ID;
 -- Update stock availability
    UPDATE STOCK_DETAIL
    SET
        STOCK_AVAILABLE = STOCK_AVAILABLE + :OLD.QUATITY
    WHERE
        PEN_ID = :OLD.PEN_ID
        AND STOCK_ID = CURR_STOCK_ID;
END;
/

CREATE OR REPLACE TRIGGER ORDERS_BEFORE_DELETE BEFORE
    DELETE ON ORDERS FOR EACH ROW
BEGIN
    DELETE FROM ORDERS_DETAILS
    WHERE
        ORDER_ID = :OLD.ORDER_ID;
END;
/

--------------------------------------------------------------------------------


--------------------------------trigger insert----------------------------------


--cập nhật giá trước khi lưu thông tin sản phẩm vào đơn hàng
CREATE OR REPLACE TRIGGER ORDERS_DETAILS_BEFORE_INSERT BEFORE
    INSERT ON ORDERS_DETAILS FOR EACH ROW
DECLARE
    O_PRICE             VARCHAR2( 10 );
    STOCK_AVAILABLE_PEN INT;
    CURR_STOCK_ID       INT;
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
CREATE OR REPLACE PROCEDURE INSERT_CUSTOMER(N_CUST_ID IN NUMBER, N_CUST_NAME IN VARCHAR2, N_CUST_NUMBER_PHONE VARCHAR2) AS
BEGIN
    IF(0<N_CUST_ID
    AND N_CUST_ID<=100) THEN
        INSERT INTO C##M1.CUSTOMER@DB_M1(
            CUST_ID,
            CUST_NAME,
            CUST_NUMBER_PHONE
        ) VALUES(
            N_CUST_ID,
            N_CUST_NAME,
            N_CUST_NUMBER_PHONE
        );
    ELSIF(100<N_CUST_ID
    AND N_CUST_ID<=200) THEN
        INSERT INTO C##M2.CUSTOMER@DB_M2(
            CUST_ID,
            CUST_NAME,
            CUST_NUMBER_PHONE
        ) VALUES(
            N_CUST_ID,
            N_CUST_NAME,
            N_CUST_NUMBER_PHONE
        );
    ELSE
        DBMS_OUTPUT.PUT_LINE('Id customer in range [1..200].');
    END IF;

    COMMIT;
END;
 ------------ start test procedure insert_customer -----------------------------
BEGIN
    INSERT_CUSTOMER(1, 'Dung', '0123-456-789');
END;

BEGIN
    INSERT_CUSTOMER(2, 'Hao', '0123-456-111');
END;

BEGIN
    INSERT_CUSTOMER(3, 'Duong', '0111-211-333');
END;

SELECT
    *
FROM
    C##M1.CUSTOMER@DB_M1;
 ----------------------- end test procedure insert_customer----------------------
 -----------------create procedure for insert_order------------------------------
CREATE OR REPLACE PROCEDURE INSERT_ORDER( N_ORDER_ID IN NUMBER, N_STOCK_ID IN NUMBER, N_CUST_ID IN NUMBER ) AS COUNT_CUST NUMBER;
COUNT_STOCK NUMBER;
BEGIN
 -- Check if cust_id exists in C##M1.customer@DB_M1
    SELECT
        COUNT(CUST_ID) INTO COUNT_CUST
    FROM
        C##M1.CUSTOMER@DB_M1
    WHERE
        CUST_ID = N_CUST_ID;
    IF COUNT_CUST = 1 THEN
 -- Check if stock_id exists in C##M1.stock@DB_M1
        SELECT
            COUNT(STOCK_ID) INTO COUNT_STOCK
        FROM
            C##M1.STOCK@DB_M1
        WHERE
            STOCK_ID = N_STOCK_ID;
        IF COUNT_STOCK = 1 THEN
 -- Check the range for n_order_id
            IF N_ORDER_ID > 0 AND N_ORDER_ID <= 100 THEN
 -- Insert into C##M1.orders@DB_M1
                INSERT INTO C##M1.ORDERS@DB_M1 (
                    ORDER_ID,
                    STOCK_ID,
                    CUST_ID,
                    TOTAL
                ) VALUES (
                    N_ORDER_ID,
                    N_STOCK_ID,
                    N_CUST_ID,
                    0
                );
            ELSE
                DBMS_OUTPUT.PUT_LINE('Id order in range [1..100]');
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Id stock invalid');
        END IF;
    ELSE
 -- Check if cust_id exists in C##M2.customer@DB_M2
        SELECT
            COUNT(CUST_ID) INTO COUNT_CUST
        FROM
            C##M2.CUSTOMER@DB_M2
        WHERE
            CUST_ID = N_CUST_ID;
        IF COUNT_CUST = 1 THEN
 -- Check if stock_id exists in C##M2.stock@DB_M2
            SELECT
                COUNT(STOCK_ID) INTO COUNT_STOCK
            FROM
                C##M2.STOCK@DB_M2
            WHERE
                STOCK_ID = N_STOCK_ID;
            IF COUNT_STOCK = 1 THEN
 -- Check the range for n_order_id
                IF N_ORDER_ID > 100 AND N_ORDER_ID <= 200 THEN
 -- Insert into C##M2.orders@DB_M2
                    INSERT INTO C##M2.ORDERS@DB_M2 (
                        ORDER_ID,
                        STOCK_ID,
                        CUST_ID,
                        TOTAL
                    ) VALUES (
                        N_ORDER_ID,
                        N_STOCK_ID,
                        N_CUST_ID,
                        0
                    );
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
BEGIN
 --insert_order(n_order_id,n_stock_id, n_cust_id );
    INSERT_ORDER(1, 1, 1);
END;

BEGIN
 --insert_order(n_order_id,n_stock_id, n_cust_id );
    INSERT_ORDER(2, 2, 2);
END;

BEGIN
 --insert_order(n_order_id,n_stock_id, n_cust_id );
    INSERT_ORDER(3, 2, 3);
END;

SELECT
    *
FROM
    C##M1.ORDERS@DB_M1;
 ---------------------- end test procedure insert_order--------------------------
 ----------------------create procedure for insert order detail------------------
CREATE OR REPLACE PROCEDURE INSERT_ORDER_DETAILS(N_ORDER_ID IN NUMBER, N_PEN_ID IN NUMBER, N_QUATITY IN NUMBER) AS V_COUNT INT;
N_PRICE INT;
CURR_STOCK_AVAILABLE INT;
CURR_STOCK_ID INT;
BEGIN
    SAVEPOINT SAVE_INSERT_ORDER_DETAILS;
 -- Check if order exists in DB_M1
    SELECT
        COUNT(ORDER_ID) INTO V_COUNT
    FROM
        C##M1.ORDERS@DB_M1
    WHERE
        ORDER_ID = N_ORDER_ID;
    IF V_COUNT = 1 THEN
        SELECT
            NVL(MIN(PEN_PRICE), -1) INTO N_PRICE
        FROM
            C##M1.PEN@DB_M1
        WHERE
            PEN_ID = N_PEN_ID;
        IF N_PRICE > 0 THEN
            INSERT INTO C##M1.ORDERS_DETAILS@DB_M1 (
                ORDER_ID,
                PEN_ID,
                QUATITY,
                PRICE
            ) VALUES (
                N_ORDER_ID,
                N_PEN_ID,
                N_QUATITY,
                N_PRICE
            );
            SELECT
                STOCK_ID INTO CURR_STOCK_ID
            FROM
                C##M1.ORDERS@DB_M1
            WHERE
                ORDER_ID = N_ORDER_ID;
            SELECT
                STOCK_AVAILABLE INTO CURR_STOCK_AVAILABLE
            FROM
                C##M1.STOCK_DETAIL@DB_M1
            WHERE
                PEN_ID = N_PEN_ID
                AND STOCK_ID = CURR_STOCK_ID;
            IF CURR_STOCK_AVAILABLE >= 0 THEN
                COMMIT;
            ELSE
                ROLLBACK TO SAVE_INSERT_ORDER_DETAILS;
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Pen ID does not exist');
        END IF;
    ELSE
 -- Check if order exists in DB_M2
        SELECT
            COUNT(ORDER_ID) INTO V_COUNT
        FROM
            C##M2.ORDERS@DB_M2
        WHERE
            ORDER_ID = N_ORDER_ID;
        IF V_COUNT = 1 THEN
            SELECT
                NVL(MIN(PEN_PRICE), -1) INTO N_PRICE
            FROM
                C##M2.PEN@DB_M2
            WHERE
                PEN_ID = N_PEN_ID;
            IF N_PRICE > 0 THEN
                INSERT INTO C##M2.ORDERS_DETAILS@DB_M2 (
                    ORDER_ID,
                    PEN_ID,
                    QUATITY,
                    PRICE
                ) VALUES (
                    N_ORDER_ID,
                    N_PEN_ID,
                    N_QUATITY,
                    N_PRICE
                );
                SELECT
                    STOCK_ID INTO CURR_STOCK_ID
                FROM
                    C##M2.ORDERS@DB_M2
                WHERE
                    ORDER_ID = N_ORDER_ID;
                SELECT
                    STOCK_AVAILABLE INTO CURR_STOCK_AVAILABLE
                FROM
                    C##M2.STOCK_DETAIL@DB_M2
                WHERE
                    PEN_ID = N_PEN_ID
                    AND STOCK_ID = CURR_STOCK_ID;
                IF CURR_STOCK_AVAILABLE >= 0 THEN
                    COMMIT;
                ELSE
                    ROLLBACK TO SAVE_INSERT_ORDER_DETAILS;
                END IF;
            ELSE
                DBMS_OUTPUT.PUT_LINE('Pen ID does not exist');
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Order ID does not exist');
        END IF;
    END IF;
END;
/

BEGIN
 --insert_order_details (n_order_id, n_pen_id, n_quatity)
    INSERT_ORDER_DETAILS (1, 1, 1);
END;

BEGIN
 --insert_order_details (n_order_id, n_pen_id, n_quatity)
    INSERT_ORDER_DETAILS (2, 2, 2);
END;

BEGIN
 --insert_order_details (n_order_id, n_pen_id, n_quatity)
    INSERT_ORDER_DETAILS (3, 3, 3);
END;

SELECT
    *
FROM
    C##M1.ORDERS@DB_M1;
SELECT
    *
FROM
    C##M1.ORDERS_DETAILS@DB_M1;
SELECT
    *
FROM
    C##M1.STOCK_DETAIL@DB_M1;
 --------------- end test procedure insert_order_details-------------------------
CREATE OR REPLACE PROCEDURE UPDATE_QUATITY_ORDER_DETAILS ( N_ORDER_ID IN NUMBER, N_PEN_ID IN NUMBER, N_QUATITY IN NUMBER ) AS COUNT_ROWS NUMBER;
CURR_STOCK_AVAILABLE NUMBER;
CURR_STOCK_ID NUMBER;
BEGIN
    SAVEPOINT SAVE_UPDATE_QUATITY_ORDER_DETAILS;
 -- Check in C##M1.orders_details@DB_M1
    SELECT
        COUNT(*) INTO COUNT_ROWS
    FROM
        C##M1.ORDERS_DETAILS@DB_M1
    WHERE
        ORDER_ID = N_ORDER_ID
        AND PEN_ID = N_PEN_ID;
    IF COUNT_ROWS = 1 THEN
 -- Process for DB_M1
        SELECT
            STOCK_ID INTO CURR_STOCK_ID
        FROM
            C##M1.ORDERS@DB_M1
        WHERE
            ORDER_ID = N_ORDER_ID;
        UPDATE C##M1.ORDERS_DETAILS@DB_M1
        SET
            QUATITY = N_QUATITY
        WHERE
            ORDER_ID = N_ORDER_ID
            AND PEN_ID = N_PEN_ID;
    ELSE
 -- Process for DB_M2
        SELECT
            COUNT(*) INTO COUNT_ROWS
        FROM
            C##M2.ORDERS_DETAILS@DB_M2
        WHERE
            ORDER_ID = N_ORDER_ID
            AND PEN_ID = N_PEN_ID;
        IF COUNT_ROWS = 1 THEN
            SELECT
                STOCK_ID INTO CURR_STOCK_ID
            FROM
                C##M2.ORDERS@DB_M2
            WHERE
                ORDER_ID = N_ORDER_ID;
            UPDATE C##M2.ORDERS_DETAILS@DB_M2
            SET
                QUATITY = N_QUATITY
            WHERE
                ORDER_ID = N_ORDER_ID
                AND PEN_ID = N_PEN_ID;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Order detail does not exist.');
        END IF;
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO SAVE_UPDATE_QUATITY_ORDER_DETAILS;
        RAISE;
END;
/

------------ start test procedure update_quatity_order_details------------------

BEGIN
 --update_quatity_order_details (n_order_id, n_pen_id, n_quatity)
    UPDATE_QUATITY_ORDER_DETAILS (1, 1, 5);
END;

SELECT
    *
FROM
    C##M1.ORDERS@DB_M1;
SELECT
    *
FROM
    C##M1.ORDERS_DETAILS@DB_M1;
SELECT
    *
FROM
    C##M1.STOCK_DETAIL@DB_M1;
SELECT
    *
FROM
    C##M1.PEN@DB_M1;
 ------------------create procedure for delete_orders_details--------------------
 ------------------create procedure for delete_orders_details--------------------
CREATE OR REPLACE PROCEDURE DELETE_ORDERS_DETAILS ( N_ORDER_ID IN NUMBER, N_PEN_ID IN NUMBER ) AS L_COUNT NUMBER;
BEGIN
 -- Use a variable to store the count
    SELECT
        COUNT(ORDER_ID) INTO L_COUNT
    FROM
        C##M1.ORDERS_DETAILS@DB_M1
    WHERE
        ORDER_ID = N_ORDER_ID
        AND PEN_ID = N_PEN_ID;
    IF L_COUNT = 1 THEN
        DELETE FROM C##M1.ORDERS_DETAILS@DB_M1
        WHERE
            ORDER_ID = N_ORDER_ID
            AND PEN_ID = N_PEN_ID;
        COMMIT; -- Commit only when the deletion is successful
    ELSE
 -- Reset the count variable for the second query
        L_COUNT := 0;
        SELECT
            COUNT(ORDER_ID) INTO L_COUNT
        FROM
            C##M2.ORDERS_DETAILS@DB_M2
        WHERE
            ORDER_ID = N_ORDER_ID
            AND PEN_ID = N_PEN_ID;
        IF L_COUNT = 1 THEN
            DELETE FROM C##M2.ORDERS_DETAILS@DB_M2
            WHERE
                ORDER_ID = N_ORDER_ID
                AND PEN_ID = N_PEN_ID;
            COMMIT; -- Commit only when the deletion is successful
        ELSE
            DBMS_OUTPUT.PUT_LINE('Order detail does not exist.');
        END IF;
    END IF;
END;
/

-- start test procedure delete_orders_details

BEGIN
    DELETE_ORDERS_DETAILS (1, 1);
END;

SELECT
    *
FROM
    ORDERS;
SELECT
    *
FROM
    ORDERS_DETAILS;
SELECT
    *
FROM
    STOCK_DETAIL;
 -- end test procedure delete_orders_details-------------------------------------
 -----------------create procedure for delete_order------------------------------
CREATE OR REPLACE PROCEDURE DELETE_ORDER ( N_ORDER_ID IN NUMBER ) AS L_COUNT NUMBER;
BEGIN
 -- Check if the order_id exists in C##M1.orders@db_m1
    SELECT
        COUNT(ORDER_ID) INTO L_COUNT
    FROM
        C##M1.ORDERS@DB_M1
    WHERE
        ORDER_ID = N_ORDER_ID;
    IF L_COUNT = 1 THEN
 -- Delete order details
        DELETE FROM C##M1.ORDERS_DETAILS@DB_M1
        WHERE
            ORDER_ID = N_ORDER_ID;
        COMMIT; -- Commit only when the deletion is successful
 -- Delete order
        DELETE FROM C##M1.ORDERS@DB_M1
        WHERE
            ORDER_ID = N_ORDER_ID;
        COMMIT; -- Commit only when the deletion is successful
    ELSE
 -- Reset the count variable for the second query
        L_COUNT := 0;
 -- Check if the order_id exists in C##M2.orders@db_m2
        SELECT
            COUNT(ORDER_ID) INTO L_COUNT
        FROM
            C##M2.ORDERS@DB_M2
        WHERE
            ORDER_ID = N_ORDER_ID;
        IF L_COUNT = 1 THEN
 -- Delete order details
            DELETE FROM C##M2.ORDERS_DETAILS@DB_M2
            WHERE
                ORDER_ID = N_ORDER_ID;
            COMMIT; -- Commit only when the deletion is successful
 -- Delete order
            DELETE FROM C##M2.ORDERS@DB_M2
            WHERE
                ORDER_ID = N_ORDER_ID;
            COMMIT; -- Commit only when the deletion is successful
        ELSE
            DBMS_OUTPUT.PUT_LINE('Order ID does not exist.');
        END IF;
    END IF;
END;
/

-- start test procedure delete_order
BEGIN
 --insert_order_details (n_order_id, n_pen_id, n_quatity)
    INSERT_ORDER_DETAILS (1, 1, 2);
END;

BEGIN
    DELETE_ORDER(1);
END;

SELECT
    *
FROM
    ORDERS;
SELECT
    *
FROM
    ORDERS_DETAILS;
SELECT
    *
FROM
    STOCK_DETAIL;
CREATE OR REPLACE PROCEDURE FIND_ORDER_TOTAL ( N_ORDER_ID IN NUMBER, O_TOTAL OUT NUMBER ) AS TOTAL_M1 NUMBER DEFAULT 0;
TOTAL_M2 NUMBER DEFAULT 0;
BEGIN
 -- Attempt to find the total from db_m1
    BEGIN
        SELECT
            TOTAL INTO TOTAL_M1
        FROM
            C##M1.ORDERS@DB_M1
        WHERE
            ORDER_ID = N_ORDER_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            TOTAL_M1 := 0;
    END;
 -- Attempt to find the total from db_m2
    BEGIN
        SELECT
            TOTAL INTO TOTAL_M2
        FROM
            C##M2.ORDERS@DB_M2
        WHERE
            ORDER_ID = N_ORDER_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            TOTAL_M2 := 0;
    END;
 -- Combine the totals
    O_TOTAL := TOTAL_M1 + TOTAL_M2;
 -- If both totals are zero, it might mean the order doesn't exist in either database
    IF O_TOTAL = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Order ID '
                             || TO_CHAR(N_ORDER_ID)
                             || ' does not exist in either database.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Total for Order ID '
                             || TO_CHAR(N_ORDER_ID)
                             || ' is: '
                             || TO_CHAR(O_TOTAL));
    END IF;
END;
/

DECLARE
    TOTAL_AMOUNT NUMBER;
BEGIN
    FIND_ORDER_TOTAL(1, TOTAL_AMOUNT); -- 123 is the order ID
    DBMS_OUTPUT.PUT_LINE('Total Amount: '
                         || TOTAL_AMOUNT);
END;
/

CREATE OR REPLACE PROCEDURE FIND_TOTAL_PRICE_ALL_ORDERS AS
    TOTAL_PRICE_M1    NUMBER := 0;
    TOTAL_PRICE_M2    NUMBER := 0;
    GRAND_TOTAL_PRICE NUMBER;
BEGIN
 -- Calculate total price from db_m1
    SELECT
        SUM(PRICE * QUATITY) INTO TOTAL_PRICE_M1
    FROM
        C##M1.ORDERS_DETAILS@DB_M1;
 -- Calculate total price from db_m2
    SELECT
        SUM(PRICE * QUATITY) INTO TOTAL_PRICE_M2
    FROM
        C##M2.ORDERS_DETAILS@DB_M2;
 -- Calculate grand total
    GRAND_TOTAL_PRICE := TOTAL_PRICE_M1 + TOTAL_PRICE_M2;
 -- Output the result
    DBMS_OUTPUT.PUT_LINE('Total Price from DB_M1: '
                         || TOTAL_PRICE_M1);
    DBMS_OUTPUT.PUT_LINE('Total Price from DB_M2: '
                         || TOTAL_PRICE_M2);
    DBMS_OUTPUT.PUT_LINE('Grand Total Price: '
                         || GRAND_TOTAL_PRICE);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: '
                             || SQLERRM);
END;
/

BEGIN
    FIND_TOTAL_PRICE_ALL_ORDERS;
END;