﻿/* Creación de usuario si está trabajando con BD Oracle XE */
CREATE USER C##MDY3131_P1 IDENTIFIED BY "MDY3131.practica_1"
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";
ALTER USER C##MDY3131_P1 QUOTA UNLIMITED ON USERS;
GRANT CREATE SESSION TO C##MDY3131_P1;
GRANT "RESOURCE" TO C##MDY3131_P1;
ALTER USER C##MDY3131_P1 DEFAULT ROLE "RESOURCE";

/* Creación de usuario si está trabajando con BD Oracle Cloud */
CREATE USER MDY3131_P1 IDENTIFIED BY "MDY3131.practica_1"
DEFAULT TABLESPACE "DATA"
TEMPORARY TABLESPACE "TEMP";
ALTER USER MDY3131_P1 QUOTA UNLIMITED ON DATA;
GRANT CREATE SESSION TO MDY3131_P1;
GRANT "RESOURCE" TO MDY3131_P1;
ALTER USER MDY3131_P1 DEFAULT ROLE "RESOURCE";