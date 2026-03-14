//AMBMPSPT JOB (AMB,MZ,%%HCC,00,00),CONTROLM,CLASS=A,
//     MSGLEVEL=(1,1),MSGCLASS=T,REGION=0M,SCHENV=SEBAT
//*--------------------------------------------------------------------*
//JOBLIB   DD DISP=SHR,DSN=%%JLIB1
//         DD DISP=SHR,DSN=%%JLIB2
//         DD DISP=SHR,DSN=%%JLIB3
//         DD DISP=SHR,DSN=%%JLIB4
//*--------------------------------------------------------------------*
//*  %%SET %%AMBIENTE   = %%SUBSTR %%AMB 1 1
//*  %%SET %%DD         = %%SUBSTR %%$ODATE 7 2
//*  %%SET %%MM         = %%SUBSTR %%$ODATE 5 2
//*  %%SET %%AAAA       = %%SUBSTR %%$ODATE 1 4
//*  %%SET %%AA         = %%SUBSTR %%$ODATE 3 2
//*  %%SET %%DTMOV      = %%DD..%%MM..%%AAAA
//*  %%SET %%PARMM      = %%DD.%%MM.%%AA
//*                                                                     
//*  %%SET %%BFNO       = 50                                            
//*  %%SET %%QTDE       = 10                                            
//**********************************************************************
//* FUNCAO.....: LER ARQUIVOS DO SISLEGADO COM PSPT NA DATA DE MIG E   *
//*              DIVIDE EM 2 ARQUIVOS ENVIADOS AO TST SENDO UM COM     *
//*              CONTAS ATIVAS E UM COM CONTAS EM CA.                  *
//*=====================================================================
//* SEPARA AS INFORMACOES DO BOOK AMBBJM0L (UNLOAD TB106 + BOOK) EM 2  *
//* ARQUIVOS, SENDO UM COM CONTAS ATIVAS E OUTRO COM PSPT EM CA.       *
//*--------------------------------------------------------------------*
//ST01ICET EXEC PGM=ICETOOL,COND=(00,NE)
//*        +----------------------------------------------------------+
//*        | ENTRADA - AMBBJM0L                                       |
//*        +----------------------------------------------------------+
//AMBBJM0L DD DISP=SHR,BUFNO=%%BFNO,
//            DSN=%%HALIAS%%.AMB.MZ.BDD2.AMBBJM0L.D%%ODATE.FMOT01
//         DD DISP=SHR,BUFNO=%%BFNO,
//            DSN=%%HALIAS%%.AMB.MZ.BDD2.AMBBJM0L.D%%ODATE.FMOT11
//*        +----------------------------------------------------------+
//*        | SAIDA - AMBBJM0L                                         |
//*        +----------------------------------------------------------+
//AMBCRATV DD DISP=(,CATLG,DELETE),
//         DSN=%%HALIAS%%.AMB.MZ.BMT1.AMBCRATV.D%%ODATE.FMPSPT,
//         DATACLAS=S2004096,LRECL=3056
//*        +----------------------------------------------------------+
//*        | SAIDA - AMBBJM0L                                         |
//*        +----------------------------------------------------------+
//AMBCRTCA DD DISP=(,CATLG,DELETE),
//         DSN=%%HALIAS%%.AMB.MZ.BMT1.AMBCRTCA.D%%ODATE.FMPSPT,
//         DATACLAS=S2004096,LRECL=3056
//*
//TOOLMSG  DD SYSOUT=*
//DFSMSG   DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//*
//SYMNAMES DD *
NU-OPERACAO,252,3,ZD
IND-GARANTIDA,471,1,ZD
IND-LIQUI-JUR,474,1,ZD
ARQUIVO-INTEIRO,1,3056,CH
//*
//TOOLIN   DD *
*
  COPY FROM(AMBBJM0L) TO(AMBCRATV) USING(CTL1)
  COPY FROM(AMBBJM0L) TO(AMBCRTCA) USING(CTL2)
/*
//*==> BOOK L - CONTAS ATIVAS
//CTL1CNTL DD *
  INCLUDE COND=((NU-OPERACAO,EQ,001,OR,
                 NU-OPERACAO,EQ,002,OR,
                 NU-OPERACAO,EQ,023),AND,
                 IND-LIQUI-JUR,EQ,0,AND,
                (IND-GARANTIDA,EQ,0,OR,
                 IND-GARANTIDA,EQ,1,OR,
                 IND-GARANTIDA,EQ,2))
  OUTREC FIELDS=(ARQUIVO-INTEIRO)
  OPTION MOSIZE=MAX,
         HIPRMAX=OPTIMAL,
         DSPSIZE=MAX,
         MAINSIZE=MAX,
         DYNALLOC=(SYSDA,%%QTDE),
         DYNAPCT=%%QTDE
/*
//*==> BOOK L - PSPT EM CA
//CTL2CNTL DD *
  INCLUDE COND=((NU-OPERACAO,EQ,001,OR,
                 NU-OPERACAO,EQ,002,OR,
                 NU-OPERACAO,EQ,023),AND,
                (IND-LIQUI-JUR,EQ,1,OR,
                 IND-LIQUI-JUR,EQ,2,OR,
                 IND-LIQUI-JUR,EQ,3))
  OUTREC FIELDS=(ARQUIVO-INTEIRO)
  OPTION MOSIZE=MAX,
         HIPRMAX=OPTIMAL,
         DSPSIZE=MAX,
         MAINSIZE=MAX,
         DYNALLOC=(SYSDA,%%QTDE),
         DYNAPCT=%%QTDE
/*
//**********************************************************************
//*--------------------------------------------------------------------*
//* VERIFICA SE ARQUIVOS ESTAO VAZIOS                                  *
//* SE ST02PVAZ.RC EQ 000  ==> ARQUIVO COM CONTEUDO                    *
//* SE ST02PVAZ.RC EQ 004  ==> ARQUIVO VAZIO                           *
//*--------------------------------------------------------------------*
//ST02PVAZ EXEC PGM=ICETOOL,COND=(00,NE)
//*        +-----------------------------------------------------------+
//*        | ENTRADA - AMBBJM0L - CONTAS ATIVAS                        |
//*        +-----------------------------------------------------------+
//ARQVCOPF DD DISP=SHR,BUFNO=%%BFNO,
//            DSN=%%HALIAS%%.AMB.MZ.BMT1.AMBCRATV.D%%ODATE.FMPSPT
//         DD DISP=SHR,BUFNO=%%BFNO,
//            DSN=%%HALIAS%%.AMB.MZ.BMT1.AMBCRTCA.D%%ODATE.FMPSPT
//*        +-----------------------------------------------------------+
//*        | ENTRADA - AMBBJM0X - CA - OP. CR. IGUAL A 196 6500 BYTES  |
//*        +-----------------------------------------------------------+
//ARQVCOPJ DD DISP=SHR,BUFNO=%%BFNO,
//            DSN=%%HALIAS%%.AMB.MZ.BMT1.AMBCA196.D%%ODATE.FMCRPJ
//*        +----------------------------------------------------------+
//RESULT   DD DISP=(MOD,PASS),
//            DSN=&&TEMPRESU,
//            DCB=(RECFM=FB,LRECL=01,DSORG=PS),
//            SPACE=(TRK,(1,1),RLSE)
//*        +----------------------------------------------------------+
//SAIDA    DD SYSOUT=*
//*        +----------------------------------------------------------+
//TOOLMSG  DD SYSOUT=*
//DFSMSG   DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//*
//SYMNAMES DD *
POS1,1,1,CH
//*
//TOOLIN   DD *
*
  COPY FROM(ARQVCOPF) TO(RESULT,SAIDA) USING(CTL1)
  COPY FROM(ARQVCOPJ) TO(RESULT,SAIDA) USING(CTL1)
*
  COUNT FROM(RESULT) RC4 EMPTY
*
//CTL1CNTL DD *
  OUTREC FIELDS=(POS1)
  OPTION COPY,STOPAFT=1
*
/*                                                                      
//**********************************************************************
//*--------------------------------------------------------------------*
//* CRIA ARQUIVOS COM OS PARA UTILIZACAO NA ROTINA AMBRPSPT
//*--------------------------------------------------------------------*
//ST03ICET EXEC PGM=ICETOOL,COND=(04,NE,ST02PVAZ)
//*        +----------------------------------------------------------+
//*        | HEADER E TRAILER GERADO VIA STREAMING                    |
//*        +----------------------------------------------------------+
//AMBTEMP0 DD *
0
9
//*
//*        +----------------------------------------------------------+
//*        | ARQUIVOS COM HEADER E TRAILER PARA O AMBRPSPT            |
//*        +----------------------------------------------------------+
//DD0      DD DISP=(,CATLG,DELETE),
//            DSN=%%HALIAS%%.TST.MZ.BDD2.ITSTBP01.D%%ODATE.FMBT00,
//            DATACLAS=S2004096,LRECL=500
//DD1      DD DISP=(,CATLG,DELETE),
//            DSN=%%HALIAS%%.TST.MZ.BDD2.ITSTBP11.D%%ODATE.FMBT00,
//            DATACLAS=S2004096,LRECL=500
//DD2      DD DISP=(,CATLG,DELETE),
//            DSN=%%HALIAS%%.TST.MZ.BDD2.ITSTBP21.D%%ODATE.FMBT00,
//            DATACLAS=S2004096,LRECL=500
//*        +----------------------------------------------------------+
//DDA      DD DISP=(,CATLG,DELETE),
//            DSN=%%HALIAS%%.TST.MZ.BDD2.ITSTCP01.D%%ODATE.FMBT00,
//            DATACLAS=S2004096,LRECL=500
//DDB      DD DISP=(,CATLG,DELETE),
//            DSN=%%HALIAS%%.TST.MZ.BDD2.ITSTCP11.D%%ODATE.FMBT00,
//            DATACLAS=S2004096,LRECL=500
//DDC      DD DISP=(,CATLG,DELETE),
//            DSN=%%HALIAS%%.TST.MZ.BDD2.ITSTCP21.D%%ODATE.FMBT00,
//            DATACLAS=S2004096,LRECL=500
//*        +----------------------------------------------------------+
//*        | ARQUIVO TEMPORARIO PARA ARMAZENAR HEADER E TRAILER       |
//*        +----------------------------------------------------------+
//AMBTEMP1 DD DISP=(MOD,PASS),
//            DSN=%%HALIAS%%.AMB.MZ.BMT1.AMBTMP0.D%%ODATE.FMPSPT,
//            DCB=(RECFM=FB,LRECL=500),
//            SPACE=(TRK,(1,1),RLSE),DATACLAS=S2004096
//TOOLMSG  DD SYSOUT=*
//DFSMSG   DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//*
//TOOLIN   DD *
*
  COPY FROM(AMBTEMP0) TO(AMBTEMP1)
*
  COPY FROM(AMBTEMP1) TO(DD0)
  COPY FROM(AMBTEMP1) TO(DD1)
  COPY FROM(AMBTEMP1) TO(DD2)
*
  COPY FROM(AMBTEMP1) TO(DDA)
  COPY FROM(AMBTEMP1) TO(DDB)
  COPY FROM(AMBTEMP1) TO(DDC)
/*
//**********************************************************************
//*--------------------------------------------------------------------*
//* ADICIONA CONDICOES DO CONTROL-M                                    *
//*--------------------------------------------------------------------*
//ST04ADDC EXEC IOACND,COND=(04,NE,ST02PVAZ)
//DAPRINT  DD SYSOUT=*
//SYSIN    DD *
ADD COND TSTMBT01-AMBRPSPT-@K                   %%PARMM
ADD COND TSTMBT11-AMBRPSPT-@K                   %%PARMM
//*--------------------------------------------------------------------*
//* SCHEDULA TSTDSMIG SE O AMBIENTE DO TST NAO FOR SIMULADO            *
//*--------------------------------------------------------------------*
%%IF %%SIMULATST EQ N
//*
//**********************************************************************
//ST05CTMJ EXEC CTMJOB,PARM='NODACHK',COND=(00,NE,ST02PVAZ)
//DDS      DD DISP=SHR,
//            DSN=%%SCHLIB
//DAJOB    DD *
ORDER DDNAME=DDS MEM=TSTDSMIG ODATE=%%PARMM
//*
%%ENDIF
//*
//
