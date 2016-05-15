SET SERVEROUTPUT ON;

DROP PACKAGE BODY wSkillsManager;
/
DROP PACKAGE wSkillsManager;
/

CREATE OR REPLACE PACKAGE wSkillsManager IS
  
    PROCEDURE insertSkill(p_id wSkills.id_skill%type, p_type wSkills.type_skill%type, p_name wSkills.name_skill%type, p_desc wSkills.description%type, p_value wSkills.value_skill%type, p_lvl wSkills.lvl%type, p_gold wSkills.cost_gold%type);
    PROCEDURE deleteSkill(p_id wSkills.id_skill%type);
    
    FUNCTION getType(p_id wSkills.id_skill%type) RETURN INTEGER;
    FUNCTION getName(p_id wSkills.id_skill%type) RETURN VARCHAR2;
    FUNCTION getDesc(p_id wSkills.id_skill%type) RETURN VARCHAR2;
    FUNCTION getValue(p_id wSkills.id_skill%type) RETURN INTEGER;
    FUNCTION getLvl(p_id wSkills.id_skill%type) RETURN INTEGER;
    FUNCTION getGold(p_id wSkills.id_skill%type) RETURN INTEGER;
    
    PROCEDURE addUserSkill(p_id_user wUsersSkills.id_user%type, p_id_skill wUsersSkills.id_skill%type);
    PROCEDURE delUserSkill(p_id_user wUsersSkills.id_user%type, p_id_skill wUsersSkills.id_skill%type);
    
END wSkillsManager;
/

CREATE OR REPLACE PACKAGE BODY wSkillsManager IS
  
  FUNCTION checkSkill(p_id wSkills.id_skill%type)
  RETURN INTEGER
  AS
    v_count integer := 0;
  BEGIN
    SELECT count(*) INTO v_count FROM wSkills
      WHERE TRIM(UPPER(id_skill)) = TRIM(UPPER(p_id));
    IF v_count = 0 THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  END checkSkill;
  
  PROCEDURE insertSkill (p_id wSkills.id_skill%type, p_type wSkills.type_skill%type, p_name wSkills.name_skill%type, p_desc wSkills.description%type, p_value wSkills.value_skill%type, p_lvl wSkills.lvl%type, p_gold wSkills.cost_gold%type)
  AS
  BEGIN
    IF checkSkill(p_id) <> 0 THEN
      RAISE wEx.skillExists;
    ELSIF (p_type NOT IN (1,2,3)) OR (p_name IS NULL) OR (p_desc IS NULL) OR
          (p_lvl < 0) OR (p_gold < 0) THEN
      RAISE wEx.invSkillStats;
    ELSE
      INSERT INTO wSkills VALUES (p_id, p_type, p_name, p_desc, p_value, p_lvl, p_gold);
    END IF;
   EXCEPTION
    WHEN wEx.skillExists THEN
      wEx.RAISE_EX(-20011);
    WHEN wEx.invSkillStats THEN
      wEx.RAISE_EX(-20013);
  END insertSkill;
  
  PROCEDURE deleteSkill(p_id wSkills.id_skill%type)
  AS
  BEGIN
    IF checkSkill(p_id) = 0 THEN
      RAISE wEx.skillNonExists;
    ELSE
      DELETE FROM wSkills WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_skill));
    END IF;
    
    EXCEPTION
    WHEN wEx.skillNonExists THEN
      wEx.RAISE_EX(-20012);
  END deleteSkill;
  
  FUNCTION getType(p_id wSkills.id_skill%type)
  RETURN INTEGER
  AS
    v_type integer := 0;
  BEGIN
    IF checkSkill(p_id) = 0 THEN
      RAISE wEx.skillNonExists;
    ELSE
      SELECT type_skill INTO v_type FROM wSkills
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_skill));
      RETURN v_type;
    END IF; 
    
    EXCEPTION
    WHEN wEx.skillNonExists THEN
      wEx.RAISE_EX(-20012);
  END getType;
  
  FUNCTION getName(p_id wSkills.id_skill%type)
  RETURN VARCHAR2
  AS
    v_name varchar2(64) := '';
  BEGIN
    IF checkSkill(p_id) = 0 THEN
      RAISE wEx.skillNonExists;
    ELSE
      SELECT name_skill INTO v_name FROM wSkills
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_skill));
      RETURN v_name;
    END IF; 
    
    EXCEPTION
    WHEN wEx.skillNonExists THEN
      wEx.RAISE_EX(-20012);
  END getName;
  
  FUNCTION getDesc(p_id wSkills.id_skill%type)
  RETURN VARCHAR2
  AS
    v_desc varchar2(512) := '';
  BEGIN
    IF checkSkill(p_id) = 0 THEN
      RAISE wEx.skillNonExists;
    ELSE
      SELECT description INTO v_desc FROM wSkills
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_skill));
      RETURN v_desc;
    END IF; 
    
    EXCEPTION
    WHEN wEx.skillNonExists THEN
      wEx.RAISE_EX(-20012);
    END getDesc;
    
  FUNCTION getValue(p_id wSkills.id_skill%type)
  RETURN INTEGER
  AS
    v_value integer := 0;
  BEGIN
    IF checkSkill(p_id) = 0 THEN
      RAISE wEx.skillNonExists;
    ELSE
      SELECT value_skill INTO v_value FROM wSkills
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_skill));
      RETURN v_value;
    END IF; 
    
    EXCEPTION
    WHEN wEx.skillNonExists THEN
      wEx.RAISE_EX(-20012);
  END getValue;
  
  FUNCTION getLvl(p_id wSkills.id_skill%type)
  RETURN INTEGER
  AS
    v_lvl integer := 0;
  BEGIN
    IF checkSkill(p_id) = 0 THEN
      RAISE wEx.skillNonExists;
    ELSE
      SELECT lvl INTO v_lvl FROM wSkills
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_skill));
      RETURN v_lvl;
    END IF; 
    
    EXCEPTION
    WHEN wEx.skillNonExists THEN
      wEx.RAISE_EX(-20012);
  END getLvl;
  
  FUNCTION getGold(p_id wSkills.id_skill%type)
  RETURN INTEGER
  AS
    v_gold integer := 0;
  BEGIN
    IF checkSkill(p_id) = 0 THEN
      RAISE wEx.skillNonExists;
    ELSE
      SELECT cost_gold INTO v_gold FROM wSkills
        WHERE TRIM(UPPER(p_id)) = TRIM(UPPER(id_skill));
      RETURN v_gold;
    END IF; 
    
    EXCEPTION
    WHEN wEx.skillNonExists THEN
      wEx.RAISE_EX(-20012);
  END getGold;
  
  PROCEDURE addUserSkill(p_id_user wUsersSkills.id_user%type, p_id_skill wUsersSkills.id_skill%type)
  AS
    v_count integer := 0;
  BEGIN
    SELECT count(*) INTO v_count FROM wUsersSkills 
      WHERE TRIM(UPPER(p_id_user)) = TRIM(UPPER(id_user)) AND TRIM(UPPER(p_id_skill)) = TRIM(UPPER(id_skill));
  
    IF checkSkill(p_id_skill) = 0 THEN
      RAISE wEx.skillNonExists;
    ELSIF wUsersManager.checkUser(p_id_user) = 0 THEN
      RAISE wEx.userNonExists;
    ELSIF v_count <> 0 THEN
      RAISE wEx.skillUserExists;
    ELSE
      INSERT INTO wUsersSkills VALUES (p_id_user, p_id_skill);
    END IF;
    
    EXCEPTION
    WHEN wEx.skillNonExists THEN
      wEx.RAISE_EX(-20012);
    WHEN wEx.userNonExists THEN
      wEx.RAISE_EX(-20002);
    WHEN wEx.skillUserExists THEN
      wEx.RAISE_EX(-20014);
  END addUserSkill;
 
  PROCEDURE delUserSkill(p_id_user wUsersSkills.id_user%type, p_id_skill wUsersSkills.id_skill%type)
  AS
  BEGIN
    IF wUsersManager.checkUser(p_id_user) = 0 THEN
      RAISE wEx.userNonExists;
    ELSIF checkSkill(p_id_skill) = 0 AND p_id_skill <> '*' THEN
      RAISE wEx.skillNonExists;
    ELSE
      IF(p_id_skill <> '*') THEN
        DELETE FROM wUsersSkills WHERE TRIM(UPPER(p_id_user)) = TRIM(UPPER(id_user)) AND TRIM(UPPER(p_id_skill)) = TRIM(UPPER(id_skill));
      ELSE
        DELETE FROM wUsersSkills WHERE TRIM(UPPER(p_id_user)) = TRIM(UPPER(id_user));
      END IF;
    END IF;
    
    EXCEPTION
    WHEN wEx.userNonExists THEN
      wEx.RAISE_EX(-20002);
    WHEN wEx.skillNonExists THEN
      wEx.RAISE_EX(-20012);
  END delUserSkill;
  
END wSkillsManager;
/
