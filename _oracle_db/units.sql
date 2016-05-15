SET SERVEROUTPUT ON;

DROP PACKAGE BODY wUnitsManager;
/
DROP PACKAGE wUnitsManagers;
/

CREATE OR REPLACE PACKAGE wUnitsManager IS

 PROCEDURE insertUnit(p_id wUnits.id_unit%type,p_type wUnits.type_unit%type,p_name wUnits.name_unit%type,p_desc wUnits.description%type,p_atk wUnits.atk%type,p_hp wUnits.hp%type,p_ms wUnits.ms%type,p_lvl wUnits.lvl%type,p_gold wUnits.cost_gold%type);
 PROCEDURE deleteUnit(p_id wUnits.id_unit%type);
 
 FUNCTION getType(p_id wUnits.id_unit%type) RETURN INTEGER;
 FUNCTION getName(p_id wUnits.id_unit%type) RETURN VARCHAR2;
 FUNCTION getDesc(p_id wUnits.id_unit%type) RETURN VARCHAR2;
 FUNCTION getAtk(p_id wUnits.id_unit%type) RETURN INTEGER;
 FUNCTION getHp(p_id wUnits.id_unit%type) RETURN INTEGER;
 FUNCTION getMs(p_id wUnits.id_unit%type) RETURN INTEGER;
 FUNCTION getLvl(p_id wUnits.id_unit%type) RETURN INTEGER;
 FUNCTION getCost(p_id wUnits.id_unit%type) RETURN INTEGER;
 
 PROCEDURE addUserUnit(p_id_user wUsers.id_user%type, p_id_unit wUnits.id_unit%type);
 PROCEDURE delUserUnit(p_id_user wUsers.id_user%type, p_id_unit wUnits.id_unit%type);

END wUnitsManager;
/

CREATE OR REPLACE PACKAGE BODY wUnitsManager IS

   FUNCTION checkUnit(p_id wUnits.id_unit%type) 
   RETURN INTEGER
   AS
    v_count integer := 0;
   BEGIN
    SELECT count(*) INTO v_count FROM wUnits 
      WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_unit));
    IF v_count = 0 THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
   END checkUnit;

   PROCEDURE insertUnit(p_id wUnits.id_unit%type,p_type wUnits.type_unit%type,p_name wUnits.name_unit%type,p_desc wUnits.description%type,p_atk wUnits.atk%type,p_hp wUnits.hp%type,p_ms wUnits.ms%type,p_lvl wUnits.lvl%type,p_gold wUnits.cost_gold%type)
   AS
   BEGIN
    IF checkUnit(p_id) = 1 THEN
      RAISE wEx.unitExists;
    ELSIF (p_type NOT IN (1,2,3)) OR (p_name IS NULL) OR (p_desc IS NULL) OR
          (p_atk < 0) OR (p_hp < 0) OR (p_ms < 0) OR (p_lvl < 0) OR (p_gold < 0) THEN
      RAISE wEx.invUnitStats;
    ELSE
      INSERT INTO wUnits VALUES (p_id,p_type,p_name,p_desc,p_atk,p_hp,p_ms,p_lvl,p_gold);
    END IF;
    
    EXCEPTION
    WHEN wEx.unitExists THEN
      wEx.RAISE_EX(-20007);
    WHEN wEx.invUnitStats THEN
      wEx.RAISE_EX(-20009);
      
   END insertUnit;
   
   PROCEDURE deleteUnit(p_id wUnits.id_unit%type)
   AS
   BEGIN
    IF checkUnit(p_id) = 0 THEN
      RAISE wEx.unitNonExists;
    ELSE
      DELETE FROM wUnits WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_unit));
    END IF;
    
    EXCEPTION
    WHEN wEx.unitNonExists THEN
      wEx.RAISE_EX(-20008);
   END deleteUnit;
   
   FUNCTION getType(p_id wUnits.id_unit%type)
   RETURN INTEGER
   AS
    v_value integer := 0;
   BEGIN
    IF checkUnit(p_id) = 0 THEN
      RAISE wEx.unitNonExists;
    ELSE
      SELECT type_unit INTO v_value FROM wUnits
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_unit));
      RETURN v_value;
    END IF;
    EXCEPTION
    WHEN wEx.unitNonExists THEN
      wEx.RAISE_EX(-20008);
   END getType;
   
   FUNCTION getName(p_id wUnits.id_unit%type)
   RETURN VARCHAR2
   AS
    v_value varchar2(64) := '';
   BEGIN
    IF checkUnit(p_id) = 0 THEN
      RAISE wEx.unitNonExists;
    ELSE
      SELECT name_unit INTO v_value FROM wUnits
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_unit));
      RETURN v_value;
    END IF;
    EXCEPTION
    WHEN wEx.unitNonExists THEN
      wEx.RAISE_EX(-20008);
   END getName;
   
   FUNCTION getDesc(p_id wUnits.id_unit%type)
   RETURN VARCHAR2
   AS
    v_value varchar2(512) := '';
   BEGIN
    IF checkUnit(p_id) = 0 THEN
      RAISE wEx.unitNonExists;
    ELSE
      SELECT description INTO v_value FROM wUnits
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_unit));
      RETURN v_value;
    END IF;
    EXCEPTION
    WHEN wEx.unitNonExists THEN
      wEx.RAISE_EX(-20008);
   END getDesc;
   
   FUNCTION getAtk(p_id wUnits.id_unit%type)
   RETURN INTEGER
   AS
    v_value integer := 0;
   BEGIN
    IF checkUnit(p_id) = 0 THEN
      RAISE wEx.unitNonExists;
    ELSE
      SELECT atk INTO v_value FROM wUnits
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_unit));
      RETURN v_value;
    END IF;
    EXCEPTION
    WHEN wEx.unitNonExists THEN
      wEx.RAISE_EX(-20008);
   END getAtk;
   
   FUNCTION getHp(p_id wUnits.id_unit%type)
   RETURN INTEGER
   AS
    v_value integer := 0;
   BEGIN
    IF checkUnit(p_id) = 0 THEN
      RAISE wEx.unitNonExists;
    ELSE
      SELECT hp INTO v_value FROM wUnits
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_unit));
      RETURN v_value;
    END IF;
    EXCEPTION
    WHEN wEx.unitNonExists THEN
      wEx.RAISE_EX(-20008);
   END getHp;
   
   FUNCTION getMs(p_id wUnits.id_unit%type)
   RETURN INTEGER
   AS
    v_value integer := 0;
   BEGIN
    IF checkUnit(p_id) = 0 THEN
      RAISE wEx.unitNonExists;
    ELSE
      SELECT ms INTO v_value FROM wUnits
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_unit));
      RETURN v_value;
    END IF;
    EXCEPTION
    WHEN wEx.unitNonExists THEN
      wEx.RAISE_EX(-20008);
   END getMs;
   
   FUNCTION getLvl(p_id wUnits.id_unit%type)
   RETURN INTEGER
   AS
    v_value integer := 0;
   BEGIN
    IF checkUnit(p_id) = 0 THEN
      RAISE wEx.unitNonExists;
    ELSE
      SELECT lvl INTO v_value FROM wUnits
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_unit));
      RETURN v_value;
    END IF;
    EXCEPTION
    WHEN wEx.unitNonExists THEN
      wEx.RAISE_EX(-20008);
   END getLvl;
   
   FUNCTION getCost(p_id wUnits.id_unit%type)
   RETURN INTEGER
   AS
    v_value integer := 0;
   BEGIN
    IF checkUnit(p_id) = 0 THEN
      RAISE wEx.unitNonExists;
    ELSE
      SELECT cost_gold INTO v_value FROM wUnits
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_unit));
      RETURN v_value;
    END IF;
    EXCEPTION
    WHEN wEx.unitNonExists THEN
      wEx.RAISE_EX(-20008);
   END getCost;
   
  PROCEDURE addUserUnit(p_id_user wUsers.id_user%type, p_id_unit wUnits.id_unit%type)
  AS
    v_count integer := 0;
  BEGIN
    SELECT count(*) INTO v_count FROM wUsersUnits
      WHERE TRIM(UPPER(p_id_user)) = TRIM(UPPER(id_user)) AND TRIM(UPPER(p_id_unit)) = TRIM(UPPER(id_unit));
      
    IF wUsersManager.checkUser(p_id_user) = 0 THEN
      RAISE wEx.userNonExists;
    ELSIF checkUnit(p_id_unit) = 0 THEN
      RAISE wEx.unitNonExists;
    ELSIF v_count <> 0 THEN
      RAISE wEx.unitUserExists;
    ELSE
      INSERT INTO wUsersUnits VALUES (p_id_user, p_id_unit);
    END IF;
    
    EXCEPTION
    WHEN wEx.userNonExists THEN
      wEx.RAISE_EX(-20002);
    WHEN wEx.unitNonExists THEN
      wEx.RAISE_EX(-20008);
    WHEN wEx.unitUserExists THEN
      wEx.RAISE_EX(-20010);
  END addUserUnit;
  
  PROCEDURE delUserUnit(p_id_user wUsers.id_user%type, p_id_unit wUnits.id_unit%type)
  AS
  BEGIN
    IF wUsersManager.checkUser(p_id_user) = 0 THEN
      RAISE wEx.userNonExists;
    ELSIF checkUnit(p_id_unit) = 0 AND p_id_unit <> '*' THEN
      RAISE wEx.unitNonExists;
    ELSE
      IF(p_id_unit <> '*') THEN
        DELETE FROM wUsersUnits WHERE TRIM(UPPER(p_id_user)) = TRIM(UPPER(id_user)) AND TRIM(UPPER(p_id_unit)) = TRIM(UPPER(id_unit));
      ELSE
        DELETE FROM wUsersUnits WHERE TRIM(UPPER(p_id_user)) = TRIM(UPPER(id_user));
      END IF;
    END IF;
    
    EXCEPTION
    WHEN wEx.userNonExists THEN
      wEx.RAISE_EX(-20002);
    WHEN wEx.unitNonExists THEN
      wEx.RAISE_EX(-20008);
  END delUserUnit;
    
END wUnitsManager;
/