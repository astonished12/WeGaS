SET SERVEROUTPUT ON;

DROP PACKAGE BODY wUsersManager;
/
DROP PACKAGE wUsersManager;
/

CREATE OR REPLACE PACKAGE wUsersManager IS
   
   FUNCTION checkUser(p_id wUsers.id_user%type) RETURN INTEGER;
   PROCEDURE registerUser(p_id wUsers.id_user%type, p_fname wUsers.firstname%type,
                         p_sname wUsers.surname%type, p_pass wUsers.pass%type, p_email wUsers.email%type);
   PROCEDURE deleteUser(p_id wUsers.id_user%type);
   PROCEDURE loginUser(p_id wUsers.id_user%type, p_pass wUsers.pass%type);
   
   PROCEDURE addGold(p_id wUsers.id_user%type, p_value wUsers.gold%type);
   FUNCTION getGold(p_id wUsers.id_user%type) RETURN INTEGER;
   PROCEDURE addXp(p_id wUsers.id_user%type, p_value wUsers.xp%type);
   FUNCTION getXp(p_id wUsers.id_user%type) RETURN INTEGER;
  
   FUNCTION getLvl(p_id wUsers.id_user%type) RETURN INTEGER;
   
   PROCEDURE addKilled(p_id wUsers.id_user%type, p_killed wUsers.killed%type);
   FUNCTION getKilled(p_id wUsers.id_user%type) RETURN INTEGER;
   
   PROCEDURE addVictory(p_id wUsers.id_user%type, p_xp wUsers.xp%type, p_gold wUsers.gold%type, p_killed wUsers.killed%type);
   FUNCTION getVictory(p_id wUsers.id_user%type) RETURN INTEGER;
  
   PROCEDURE addDefeat(p_id wUsers.id_user%type, p_xp wUsers.xp%type, p_gold wUsers.gold%type, p_killed wUsers.killed%type);
   FUNCTION getDefeat(p_id wUsers.id_user%type) RETURN INTEGER;
   
   FUNCTION getFname(p_id wUsers.id_user%type) RETURN VARCHAR2;
   FUNCTION getSname(p_id wUsers.id_user%type) RETURN VARCHAR2;
   FUNCTION getEmail(p_id wUsers.id_user%type) RETURN VARCHAR2;
   FUNCTION getSkillPoints(p_id wUsers.id_user%type) RETURN INTEGER;
END wUsersManager;
/

CREATE OR REPLACE PACKAGE BODY wUsersManager IS

  FUNCTION checkUser(p_id wUsers.id_user%type)
  RETURN INTEGER
  AS
    v_count integer := 0;
  BEGIN
    SELECT count(*) INTO v_count FROM wUsers 
      WHERE TRIM(UPPER(id_user)) = TRIM(UPPER(p_id));
    IF v_count = 0 THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  END checkUser;

  PROCEDURE registerUser(p_id wUsers.id_user%type, p_fname wUsers.firstname%type, p_sname wUsers.surname%type, p_pass wUsers.pass%type, p_email wUsers.email%type) 
  IS
  BEGIN
    IF checkUser(p_id) = 0 THEN
      INSERT INTO wUsers (id_user,firstname,surname,pass,email)
                  VALUES (p_id,p_fname,p_sname,p_pass,p_email);
      INSERT INTO wUsersUnits VALUES (p_id, 'unit1');
      INSERT INTO wUsersUnits VALUES (p_id, 'unit2');
    ELSE
      RAISE wEx.userExists;
    END IF;
    EXCEPTION
      WHEN wEx.userExists THEN
        wEx.RAISE_EX(-20001); --id_user exista deja
  END registerUser;
  
  PROCEDURE deleteUser(p_id wUsers.id_user%type)
  IS
  BEGIN
    IF checkUser(p_id) = 0 THEN
      RAISE wEx.userNonExists;
    ELSE
      DELETE FROM wUsers WHERE TRIM(UPPER(id_user)) = TRIM(UPPER(p_id));
    END IF;
    
    EXCEPTION
      WHEN wEx.userNonExists THEN
        wEx.RAISE_EX(-20002);
  END deleteUser;
  
  PROCEDURE loginUser (p_id wUsers.id_user%type, p_pass wUsers.pass%type) 
  AS
    v_count integer := 0;
  BEGIN
    IF checkUser(p_id) = 0 THEN
      RAISE wEx.userNonExists;
    ELSE
      SELECT count(*) INTO v_count FROM wUsers 
        WHERE TRIM(UPPER(id_user)) = TRIM(UPPER(p_id)) AND p_pass = pass;
      IF v_count = 0 THEN
         RAISE wEx.passIncorrect;
       END IF;
    END IF;
    
    EXCEPTION
    WHEN wEx.userNonExists THEN
      wEx.RAISE_EX(-20002);
    WHEN wEx.passIncorrect THEN
      wEx.RAISE_EX(-20003);
  END loginUser;
  
   PROCEDURE addGold(p_id wUsers.id_user%type, p_value wUsers.gold%type)
   AS
   BEGIN
    IF checkUser(p_id) = 0 THEN
      RAISE wEx.userNonExists;
    ELSE
      IF p_value < 0 THEN
        RAISE wEx.invalidGold;
      ELSE
        UPDATE wUsers SET gold = gold+p_value WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
      END IF;
    END IF;
    
    EXCEPTION
    WHEN wEx.userNonExists THEN
      wEx.RAISE_EX(-20002);
    WHEN wEx.invalidGold THEN
      wEx.RAISE_EX(-20004);
   END addGold;
   
   FUNCTION getGold(p_id wUsers.id_user%type) 
   RETURN INTEGER
   AS
    v_gold integer := 0;
   BEGIN
    IF checkUser(p_id) = 0 THEN
     RAISE wEx.userNonExists;
    ELSE
     SELECT gold INTO v_gold FROM wUsers WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
     RETURN v_gold;
    END IF;
    
    EXCEPTION
      WHEN wEx.userNonExists THEN
        wEx.RAISE_EX(-20002);
   END getGold;
   
   
   PROCEDURE addXp(p_id wUsers.id_user%type, p_value wUsers.xp%type)
   AS
    v_tempXp integer;
    v_templvl integer;
    v_maxLvl integer;
   BEGIN
    IF checkUser(p_id) = 0 THEN
      RAISE wEx.userNonExists;
    ELSIF p_value < 0 THEN
      RAISE wEx.invalidXp;
    ELSE
      SELECT max(lvl) INTO v_maxLvl FROM wLevels;
      SELECT lvl INTO v_tempLvl FROM wUsers WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
      SELECT xp INTO v_tempXp FROM wUsers WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
      --DBMS_OUTPUT.PUT_LINE('Old lvl: '||v_tempLvl||'  Old xp: '||v_tempXp);
      
      v_tempXp := v_tempXp + p_value;
      FOR lvlRow IN (SELECT * FROM wLevels WHERE lvl > v_tempLvl ORDER BY lvl) LOOP
        IF v_tempXp >= lvlRow.xp THEN
          v_tempXp := v_tempXp - lvlRow.xp;
          v_tempLvl := lvlRow.lvl;
          UPDATE wUsers SET skill_points = skill_points + 1
            WHERE TRIM(UPPER(id_user)) = TRIM(UPPER(p_id));
        END IF;
      END LOOP;
      
      --DBMS_OUTPUT.PUT_LINE('New lvl: '||v_tempLvl||'  New xp: '||v_tempXp);
      UPDATE wUsers SET lvl = v_tempLvl, xp = v_tempXp
          WHERE TRIM(UPPER(id_user)) = TRIM(UPPER(p_id));
    END IF;
    
    EXCEPTION
    WHEN wEx.userNonExists THEN
      wEx.RAISE_EX(-20002);
    WHEN wEx.invalidXp THEN
      wEx.RAISE_EX(-20005);
   END addXp;
   
   FUNCTION getXp(p_id wUsers.id_user%type) 
   RETURN INTEGER
   AS
    v_xp integer := 0;
   BEGIN
    IF checkUser(p_id) = 0 THEN
     RAISE wEx.userNonExists;
    ELSE
     SELECT xp INTO v_xp FROM wUsers WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
     RETURN v_xp;
    END IF;
    
    EXCEPTION
      WHEN wEx.userNonExists THEN
        wEx.RAISE_EX(-20002);
   END getXp;
   
   FUNCTION getLvl(p_id wUsers.id_user%type) 
   RETURN INTEGER
   AS
    v_lvl integer := 0;
   BEGIN
    IF checkUser(p_id) = 0 THEN
     RAISE wEx.userNonExists;
    ELSE
     SELECT lvl INTO v_lvl FROM wUsers WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
     RETURN v_lvl;
    END IF;
    
    EXCEPTION
      WHEN wEx.userNonExists THEN
        wEx.RAISE_EX(-20002);
   END getLvl;
   
   PROCEDURE addKilled(p_id wUsers.id_user%type, p_killed wUsers.killed%type)
   AS
   BEGIN
    IF checkUser(p_id) = 0 THEN
      RAISE wEx.userNonExists;
    ELSE
      UPDATE wUsers SET killed = killed + p_killed
        WHERE TRIM(UPPER(id_user)) = TRIM(UPPER(p_id));
    END IF;
    
    EXCEPTION
    WHEN wEx.userNonExists THEN
      wEx.RAISE_EX(-20002);
    WHEN wEx.invalidKilled THEN
      wEx.RAISE_EX(-20006);
   END addKilled;
   
   FUNCTION getKilled(p_id wUsers.id_user%type)
   RETURN INTEGER
    AS
    v_killed integer := 0;
  BEGIN
    IF checkUser(p_id) = 0 THEN
     RAISE wEx.userNonExists;
    ELSE
     SELECT killed INTO v_killed FROM wUsers WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
     RETURN v_killed;
    END IF;
    
    EXCEPTION
      WHEN wEx.userNonExists THEN
        wEx.RAISE_EX(-20002);
   END getKilled;
   
 
   PROCEDURE addVictory(p_id wUsers.id_user%type, p_xp wUsers.xp%type, p_gold wUsers.gold%type, p_killed wUsers.killed%type)
   AS
    v_ret integer;
   BEGIN
    IF checkUser(p_id) = 0 THEN
      RAISE wEx.userNonExists;
    ELSE
      addXp(p_id,p_xp);
      addGold(p_id,p_gold);
      addKilled(p_id,p_killed);
      UPDATE wUsers SET victories = victories + 1 WHERE TRIM(UPPER(id_user)) = TRIM(UPPER(p_id));
    END IF;
    
    EXCEPTION
    WHEN wEx.userNonExists THEN
      wEx.RAISE_EX(-20002);
    WHEN wEx.invalidXp THEN
      wEx.RAISE_EX(-20005);
    WHEN wEx.invalidGold THEN
      wEx.RAISE_EX(-20004);
    WHEN wEx.invalidKilled THEN
      wEx.RAISE_EX(-20006);
   END addVictory;
  
   
   FUNCTION getVictory(p_id wUsers.id_user%type) 
   RETURN INTEGER
   AS
    v_victories integer := 0;
   BEGIN
    IF checkUser(p_id) = 0 THEN
     RAISE wEx.userNonExists;
    ELSE
     SELECT victories INTO v_victories FROM wUsers WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
     RETURN v_victories;
    END IF;
    
    EXCEPTION
      WHEN wEx.userNonExists THEN
        wEx.RAISE_EX(-20002);
   END getVictory;
    
   PROCEDURE addDefeat(p_id wUsers.id_user%type, p_xp wUsers.xp%type, p_gold wUsers.gold%type, p_killed wUsers.killed%type)
   AS
    v_ret integer := 0;
   BEGIN
    IF checkUser(p_id) = 0 THEN
      RAISE wEx.userNonExists;
    ELSE
      addXp(p_id,p_xp);
      addGold(p_id,p_gold);
      addKilled(p_id,p_killed);
      UPDATE wUsers SET defeats = defeats + 1 WHERE TRIM(UPPER(id_user)) = TRIM(UPPER(p_id));
    END IF;
    
    EXCEPTION
    WHEN wEx.userNonExists THEN
      wEx.RAISE_EX(-20002);
    WHEN wEx.invalidXp THEN
      wEx.RAISE_EX(-20005);
    WHEN wEx.invalidGold THEN
      wEx.RAISE_EX(-20004);
    WHEN wEx.invalidKilled THEN
      wEx.RAISE_EX(-20006);
   END addDefeat;
  
   FUNCTION getDefeat(p_id wUsers.id_user%type) 
   RETURN INTEGER
   AS
    v_defeats integer := 0;
  BEGIN
    IF checkUser(p_id) = 0 THEN
     RAISE wEx.userNonExists;
    ELSE
     SELECT defeats INTO v_defeats FROM wUsers WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
     RETURN v_defeats;
    END IF;
    
    EXCEPTION
      WHEN wEx.userNonExists THEN
        wEx.RAISE_EX(-20002);
   END getDefeat;
   
   FUNCTION getFname(p_id wUsers.id_user%type) 
   RETURN VARCHAR2
   AS
    v_fname varchar2(32);
   BEGIN
    IF checkUser(p_id) = 0 THEN
     RAISE wEx.userNonExists;
    ELSE
     SELECT firstname INTO v_fname FROM wUsers WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
     RETURN v_fname;
    END IF;
    
    EXCEPTION
      WHEN wEx.userNonExists THEN
        wEx.RAISE_EX(-20002);
   END getFname;
   
   FUNCTION getSname(p_id wUsers.id_user%type) 
   RETURN VARCHAR2
   AS
    v_sname varchar2(32);
   BEGIN
    IF checkUser(p_id) = 0 THEN
     RAISE wEx.userNonExists;
    ELSE
     SELECT surname INTO v_sname FROM wUsers WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
     RETURN v_sname;
    END IF;
    
    EXCEPTION
      WHEN wEx.userNonExists THEN
        wEx.RAISE_EX(-20002);
   END getSname;
   
   FUNCTION getEmail(p_id wUsers.id_user%type) 
   RETURN VARCHAR2
   AS
    v_email varchar2(64);
   BEGIN
    IF checkUser(p_id) = 0 THEN
     RAISE wEx.userNonExists;
    ELSE
     SELECT email INTO v_email FROM wUsers WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
     RETURN v_email;
    END IF;
    
    EXCEPTION
      WHEN wEx.userNonExists THEN
        wEx.RAISE_EX(-20002);
   END getEmail;
   
   FUNCTION getSkillPoints(p_id wUsers.id_user%type) 
   RETURN INTEGER
   AS
    v_sp integer := 0;
   BEGIN
    IF checkUser(p_id) = 0 THEN
     RAISE wEx.userNonExists;
    ELSE
     SELECT skill_points INTO v_sp FROM wUsers WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_user));
     RETURN v_sp;
    END IF;
    
    EXCEPTION
      WHEN wEx.userNonExists THEN
        wEx.RAISE_EX(-20002);
   END getSkillPoints;

END wUsersManager;
/
