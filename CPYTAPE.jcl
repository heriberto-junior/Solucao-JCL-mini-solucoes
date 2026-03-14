//****************************************************************
//* UTILIZACAO DE UM IEBGENER PARA COPIAR GDG PARA UM PARTICIONADO
//****************************************************************
//CPYTAPE  JOB ,MSGCLASS=X,CLASS=D,NOTIFY=&SYSUID
//****************************************************************
//COPYSTEP EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=X
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=SPP0.SXS.SPRKXA0B.G0004V00,DISP=SHR,
//            UNIT=(VTS1),     <--- UNIDADE DE FITA VIRTUAL (VTS1)
//*           VOL=SER=WRKQ28,  <--- VOLUME DO TAPE
//            LABEL=(1,SL)
//SYSUT2   DD DSN=USUARIO.TAPE.SPRKXA0B,DISP=(NEW,CATLG,DELETE),
//            UNIT=SYSDA,
//*           DCB=(RECFM=FB,LRECL=00,BLKSIZE=00),
//            SPACE=(CYL,(1000,1000),RLSE)
