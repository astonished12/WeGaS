SET SERVEROUTPUT ON;

DROP PACKAGE BODY wEx;
/
DROP PACKAGE wEx;
/

CREATE OR REPLACE PACKAGE wEx AS
  userExists      EXCEPTION;
  userNonExists   EXCEPTION;
  passIncorrect   EXCEPTION;
  invalidGold     EXCEPTION;
  invalidXp       EXCEPTION;
  invalidKilled   EXCEPTION;
  unitExists      EXCEPTION;
  unitNonExists   EXCEPTION;
  invUnitStats    EXCEPTION;
  unitUserExists  EXCEPTION;
  skillExists     EXCEPTION;
  skillNonExists  EXCEPTION;
  invSkillStats   EXCEPTION;
  skillUserExists EXCEPTION;
  notOnline       EXCEPTION;
  alreadyOnline   EXCEPTION;
  invOnlineStatus EXCEPTION;
  
  PRAGMA EXCEPTION_INIT(userExists     , -20001);
  PRAGMA EXCEPTION_INIT(userNonExists  , -20002);  
  PRAGMA EXCEPTION_INIT(passIncorrect  , -20003);
  PRAGMA EXCEPTION_INIT(invalidGold    , -20004);
  PRAGMA EXCEPTION_INIT(invalidXp      , -20005);
  PRAGMA EXCEPTION_INIT(invalidKilled  , -20006);
  PRAGMA EXCEPTION_INIT(unitExists     , -20007);
  PRAGMA EXCEPTION_INIT(unitNonExists  , -20008);
  PRAGMA EXCEPTION_INIT(invUnitStats   , -20009);
  PRAGMA EXCEPTION_INIT(unitUserExists , -20010);
  PRAGMA EXCEPTION_INIT(skillExists    , -20011);
  PRAGMA EXCEPTION_INIT(skillNonExists , -20012);
  PRAGMA EXCEPTION_INIT(invSkillStats  , -20013);
  PRAGMA EXCEPTION_INIT(skillUserExists, -20014);
  PRAGMA EXCEPTION_INIT(notOnline      , -20015);
  PRAGMA EXCEPTION_INIT(alreadyOnline  , -20016);
  PRAGMA EXCEPTION_INIT(invOnlineStatus, -20017);
  
  PROCEDURE RAISE_EX (p_exNum NUMBER, p_exMsg VARCHAR2 DEFAULT NULL);
END wEx;
/

CREATE OR REPLACE PACKAGE BODY wEx AS
  
  PROCEDURE RAISE_EX (p_exNum NUMBER, p_exMsg VARCHAR2 DEFAULT NULL) IS
  BEGIN
    CASE p_exNum
      WHEN -20001 THEN RAISE_APPLICATION_ERROR(p_exNum,'Username already exists ! - '||p_exMsg);
      WHEN -20002 THEN RAISE_APPLICATION_ERROR(p_exNum,'Username doesn''t exist ! - '||p_exMsg);
      WHEN -20003 THEN RAISE_APPLICATION_ERROR(p_exNum,'Password incorrect      ! - '||p_exMsg);
      WHEN -20004 THEN RAISE_APPLICATION_ERROR(p_exNum,'Invalid gold amount     ! - '||p_exMsg);
      WHEN -20005 THEN RAISE_APPLICATION_ERROR(p_exNum,'Invalid xp   amount     ! - '||p_exMsg);
      WHEN -20006 THEN RAISE_APPLICATION_ERROR(p_exNum,'Invalid killed amount   ! - '||p_exMsg);
      WHEN -20007 THEN RAISE_APPLICATION_ERROR(p_exNum,'Unit already exists     ! - '||p_exMsg);
      WHEN -20008 THEN RAISE_APPLICATION_ERROR(p_exNum,'Unit doesn''t exist     ! - '||p_exMsg);
      WHEN -20009 THEN RAISE_APPLICATION_ERROR(p_exNum,'Invalid unit stats      ! - '||p_exMsg);
      WHEN -20010 THEN RAISE_APPLICATION_ERROR(p_exNum,'User already has this unit ! - '||p_exMsg);
      WHEN -20011 THEN RAISE_APPLICATION_ERROR(p_exNum,'Skill already exists     ! - '||p_exMsg);
      WHEN -20012 THEN RAISE_APPLICATION_ERROR(p_exNum,'Skill doesn''t exist    ! - '||p_exMsg);
      WHEN -20013 THEN RAISE_APPLICATION_ERROR(p_exNum,'Invalid skill stats     ! - '||p_exMsg);
      WHEN -20014 THEN RAISE_APPLICATION_ERROR(p_exNum,'User already has this skill ! - '||p_exMsg);
      WHEN -20015 THEN RAISE_APPLICATION_ERROR(p_exNum,'User is not online ! - '||p_exMsg);
      WHEN -20016 THEN RAISE_APPLICATION_ERROR(p_exNum,'User is already online  ! - '||p_exMsg);
      WHEN -20017 THEN RAISE_APPLICATION_ERROR(p_exNum,'Invalid online status   ! - '||p_exMsg);
      ELSE             RAISE_APPLICATION_ERROR(-20999 ,'Unknown exception       ! - '||p_exMsg);
    END CASE;
  END RAISE_EX;

END wEx;
/
