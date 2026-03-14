//****************************************************************
//* JOB PARA CRIACAO DE GDG
//****************************************************************
//CREATGDG JOB ,MSGCLASS=X,CLASS=D,TIME=NOLIMIT,NOTIFY=&SYSUID
//****************************************************************
//GDG      EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DEFINE GDG (NAME(DES.GLBSPB.SXS.SPRST06E) -
              LIMIT(3) -
              NOEMPTY -
              SCRATCH)
/*
//*
//
