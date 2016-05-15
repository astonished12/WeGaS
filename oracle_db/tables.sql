SET SERVEROUTPUT ON;

DROP TABLE wUsersSkills;
/
DROP TABLE wUsersUnits;
/
DROP TABLE wUsersOnline;
/
DROP TABLE wUsers;
/
DROP TABLE wLevels;
/
DROP TABLE wSkills;
/
DROP TABLE wUnits;
/


CREATE TABLE wLevels(
  lvl integer PRIMARY KEY,
  xp integer NOT NULL
);
/

CREATE TABLE wUsers(
  id_user varchar2(32) PRIMARY KEY,
  firstname varchar2(32) NOT NULL,
  surname   varchar2(32) NOT NULL,
  pass varchar2(32) NOT NULL,
  email varchar2(64) NOT NULL,
  lvl integer DEFAULT 1 NOT NULL,
  gold integer DEFAULT 100 NOT NULL,
  xp integer DEFAULT 0 NOT NULL,
  skill_points integer DEFAULT 0 NOT NULL,
  victories integer DEFAULT 0 NOT NULL,
  defeats integer DEFAULT 0 NOT NULL,
  killed integer DEFAULT 0 NOT NULL,
  FOREIGN KEY (lvl) REFERENCES wLevels (lvl)
);
/

CREATE TABLE wUnits(
  id_unit varchar2(32) PRIMARY KEY,
  type_unit integer NOT NULL,
  name_unit varchar2(64) NOT NULL,
  description varchar2(512),
  atk integer NOT NULL,
  hp integer NOT NULL,
  ms integer NOT NULL,
  lvl integer NOT NULL,
  cost_gold integer NOT NULL
);
/

CREATE TABLE wSkills(
  id_skill varchar2(32) PRIMARY KEY,
  type_skill integer NOT NULL,
  name_skill varchar2(64) NOT NULL,
  description varchar2(512) NOT NULL,
  value_skill integer NOT NULL,
  lvl integer NOT NULL,
  cost_gold integer NOT NULL
);
/

CREATE TABLE wUsersUnits(
  id_user varchar2(32) NOT NULL,
  id_unit varchar2(32) NOT NULL,
  FOREIGN KEY (id_user) REFERENCES wUsers (id_user),
  FOREIGN KEY (id_unit) REFERENCES wUnits (id_unit)
);
/


CREATE TABLE wUsersSkills(
  id_user varchar2(32) NOT NULL,
  id_skill varchar2(32) NOT NULL,
  FOREIGN KEY (id_user) REFERENCES wUsers (id_user),
  FOREIGN KEY (id_skill) REFERENCES wSkills (id_skill)
);
/

CREATE TABLE wUsersOnline(
  id_user varchar2(32) PRIMARY KEY,
  status integer NOT NULL,
  login_time timestamp NOT NULL,
  FOREIGN KEY (id_user) REFERENCES wUsers (id_user)
);
/

INSERT INTO wLevels VALUES (1,0);
INSERT INTO wLevels VALUES (2,100);
INSERT INTO wLevels VALUES (3,200);
INSERT INTO wLevels VALUES (4,250);
INSERT INTO wLevels VALUES (5,400);
INSERT INTO wLevels VALUES (6,600);
INSERT INTO wLevels VALUES (7,900);
INSERT INTO wLevels VALUES (8,1000);
INSERT INTO wLevels VALUES (10,1100);

INSERT INTO wUsers (id_user,firstname,surname,pass,email) VALUES ('user1','User','One','pass1','mail1@mail.dom');
INSERT INTO wUsers (id_user,firstname,surname,pass,email) VALUES ('user2','User','Two','pass2','mail2@mail.dom');
INSERT INTO wUsers (id_user,firstname,surname,pass,email) VALUES ('user3','User','Three','pass3','mail3@mail.dom');
INSERT INTO wUsers (id_user,firstname,surname,pass,email) VALUES ('user4','User','Four','pass4','mail4@mail.dom');
INSERT INTO wUsers (id_user,firstname,surname,pass,email) VALUES ('user5','User','Fiv','pass5','mail5@mail.dom');

INSERT INTO wUnits VALUES ('unit1','1','Swordsman','A simple man carrying a longsword.',10,200,100,1,0);
INSERT INTO wUnits VALUES ('unit2','1','Archer','Trained elven archer have best marksman skills.',15,100,150,1,100);
INSERT INTO wUnits VALUES ('unit3','1','Knight','A dark knight riding a dark horse.',20,250,200,5,500);
INSERT INTO wUnits VALUES ('unit4','1','Ballista','Wooden ballistic weapon firing B.F. arrows.',50,500,80,10,1000);

INSERT INTO wSkills VALUES ('skill1','1','Battle Cry','Increases all your troops'' damage by 10%.',10,5,500);
INSERT INTO wSkills VALUES ('skill2','1','Vigor','Increases all your troops'' HP by 10%.',10,5,500);

INSERT INTO wUsersUnits VALUES ('user1','unit1');
INSERT INTO wUsersUnits VALUES ('user1','unit2');
INSERT INTO wUsersUnits VALUES ('user2','unit1');
INSERT INTO wUsersUnits VALUES ('user3','unit1');
INSERT INTO wUsersUnits VALUES ('user3','unit2');
INSERT INTO wUsersUnits VALUES ('user3','unit3');
INSERT INTO wUsersUnits VALUES ('user4','unit1');
INSERT INTO wUsersUnits VALUES ('user4','unit2');
INSERT INTO wUsersUnits VALUES ('user5','unit1');
INSERT INTO wUsersUnits VALUES ('user5','unit2');
INSERT INTO wUsersUnits VALUES ('user5','unit4');

INSERT INTO wUsersSkills VALUES ('user1','skill1');
INSERT INTO wUsersSkills VALUES ('user2','skill1');
INSERT INTO wUsersSkills VALUES ('user2','skill2');
INSERT INTO wUsersSkills VALUES ('user4','skill1');
INSERT INTO wUsersSkills VALUES ('user4','skill2');
INSERT INTO wUsersSkills VALUES ('user5','skill2');

COMMIT;

CREATE OR REPLACE TRIGGER deleteUserTrig
BEFORE DELETE ON wUsers
FOR EACH ROW
BEGIN
  DELETE FROM wUsersUnits WHERE TRIM(UPPER(id_user)) = TRIM(UPPER(:OLD.id_user));
  DELETE FROM wUsersSkills WHERE TRIM(UPPER(id_user)) = TRIM(UPPER(:OLD.id_user));
  DELETE FROM wUsersOnline WHERE TRIM(UPPER(id_user)) = TRIM(UPPER(:OLD.id_user));
END;
/

CREATE OR REPLACE TRIGGER deleteUnitTrig
BEFORE DELETE ON wUnits
FOR EACH ROW
BEGIN
  DELETE FROM wUsersUnits WHERE TRIM(UPPER(id_unit)) = TRIM(UPPER(:OLD.id_unit));
END;
/

CREATE OR REPLACE TRIGGER deleteSkillTrig
BEFORE DELETE ON wSkills
FOR EACH ROW
BEGIN
  DELETE FROM wUsersSkills WHERE TRIM(UPPER(id_skill)) = TRIM(UPPER(:OLD.id_skill));
END;
/

DROP INDEX wUsersIndex;
/
DROP INDEX wUsersOnlineIndex;
/
CREATE INDEX wUsersIndex ON wUsers (TRIM(UPPER(id_user)));
/
CREATE INDEX wUsersOnlineIndex ON wUsersOnline (status,TRIM(UPPER(id_user)));
/