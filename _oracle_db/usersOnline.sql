SET SERVEROUTPUT ON;

DROP PACKAGE BODY wUsersOnlineManager;
/
DROP PACKAGE wUsersOnlineManager;
/

CREATE OR REPLACE PACKAGE wUsersOnlineManager IS

  FUNCTION checkOnline(p_id wUsersOnline.id_user%type) RETURN INTEGER;
  FUNCTION checkStatus(p_id wUsersOnline.id_user%type) RETURN INTEGER;
  FUNCTION getTimeOnline(p_id wUsersOnline.id_user%type) RETURN VARCHAR2;
  
  PROCEDURE setOnline (p_id wUsersOnline.id_user%type);
  PROCEDURE setOffline(p_id wUsersOnline.id_user%type);
  PROCEDURE setStatus (p_id wUsersOnline.id_user%type, p_status wUsersOnline.status%type);
  
END wUsersOnlineManager;
/

CREATE OR REPLACE PACKAGE BODY wUsersOnlineManager IS
  
  FUNCTION checkOnline(p_id wUsersOnline.id_user%type)
  RETURN INTEGER
  AS
    v_count integer := 0;
  BEGIN
    IF wUsersManager.checkUser(p_id) = 0 THEN
      RAISE wEx.userNonExists;
    ELSE
      SELECT count(*) INTO v_count FROM wUsersOnline
        WHERE TRIM(UPPER(p_id)) = TRIM(upper(id_user));
      IF v_count = 0 THEN
        RETURN 0;
      ELSE
        RETURN 1;
      END IF;
  END IF;
  
  EXCEPTION
    WHEN wEx.userNonExists THEN
      wEx.RAISE_EX(-20002);
  END checkOnline;
  
  FUNCTION checkStatus(p_id wUsersOnline.id_user%type)
  RETURN INTEGER
  AS
    v_status integer := 0;
  BEGIN
    IF checkOnline(p_id) = 0 THEN
      RAISE wEx.notOnline;
    ELSE
      SELECT status INTO v_status FROM wUsersOnline
        WHERE TRIM(UPPER(p_id)) = TRIM(upper(id_user));
      RETURN v_status;
    END IF;
    
  EXCEPTION
    WHEN wEx.notOnline THEN
      wEx.RAISE_EX(-20015);
  END checkStatus;
  
  PROCEDURE setOnline(p_id wUsersOnline.id_user%type)
  AS
  BEGIN
    IF checkOnline(p_id) <> 0 THEN
      RAISE wEx.alreadyOnline;
    ELSE
      INSERT INTO wUsersOnline VALUES (p_id,1,CURRENT_TIMESTAMP);
    END IF;
  EXCEPTION
    WHEN wEx.alreadyOnline THEN
      wEx.RAISE_EX(-20016);
  END setOnline;
  
  PROCEDURE setOffline(p_id wUsersOnline.id_user%type)
  AS
  BEGIN
    IF p_id = '*' THEN
      DELETE FROM wUsersOnline;
    ELSE
      IF checkOnline(p_id) = 0 THEN
        RAISE wEx.notOnline;
      ELSE
        DELETE FROM wUsersOnline WHERE TRIM(UPPER(p_id)) = TRIM(upper(id_user));
      END IF;
    END IF;
  
  EXCEPTION
    WHEN wEx.notOnline THEN
      wEx.RAISE_EX(-20015);
  END setOffline;
  
  PROCEDURE setStatus (p_id wUsersOnline.id_user%type, p_status wUsersOnline.status%type)
  AS
  BEGIN
    IF p_status NOT IN (1,2) THEN
      RAISE wEx.invOnlineStatus;
    ELSIF checkOnline(p_id) = 0 THEN
      RAISE wEx.notOnline;
    ELSE
      UPDATE wUsersOnline SET status = p_status WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
    END IF;
    
  EXCEPTION
    WHEN wEx.invOnlineStatus THEN
      wEx.RAISE_EX(-20017);
    WHEN wEx.notOnline THEN
      wEx.RAISE_EX(-20015);
  END setStatus;
  
  FUNCTION getTimeOnline(p_id wUsersOnline.id_user%type)
  RETURN VARCHAR2
  AS
    v_days integer := -1;
    v_hours integer := -1;
    v_minutes integer := -1;
    v_seconds integer := -1;
    
    v_stamp varchar2(64);
    v_time varchar2(64) := '';
  BEGIN
    IF checkOnline(p_id) = 0 THEN
      RAISE wEx.notOnline;
    ELSE
      SELECT current_timestamp - login_time INTO v_stamp FROM wUsersOnline
        WHERE TRIM(UPPER(p_id)) = TRIM(upper(id_user));
      v_days := SUBSTR(v_stamp,2,9);
      v_hours := SUBSTR(v_stamp,12,2);
      v_minutes := SUBSTR(v_stamp,15,2);
      v_seconds := SUBSTR(v_stamp,18,2);
      IF v_days <> 0 THEN
        v_time := v_time||v_days||'d  ';
      END IF;
      
      IF v_hours <> 0 THEN
        v_time := v_time||v_hours||'h  ';
      END IF;
      
      IF v_minutes <> 0 THEN
        v_time := v_time||v_minutes||'m  ';
      END IF;
      
      v_time := v_time||v_seconds||'s';
      
      
    END IF;
    RETURN v_time;
    
  EXCEPTION
    WHEN wEx.notOnline THEN
      wEx.RAISE_EX(-20015);
  END getTimeOnline;
END wUsersOnlineManager;
/

DECLARE
  temp varchar2(64) := '';
BEGIN
  --wUsersOnlineManager.setOnline('user2');
  temp := wUsersOnlineManager.getTimeOnline('user2');
  DBMS_OUTPUT.PUT_LINE(''''||temp||'''');
END;
/

COMMIT;
