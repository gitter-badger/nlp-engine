#ifndef LINUX
#include <windows.h>
#include <fstream>
#include <tchar.h>
#include <my_tchar.h>
#include <streamclasses.h>
#else
#include <sys/stat.h>
#include "machine.h"
#endif
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <strstream>
#include <time.h>

#include "machine.h"

#ifndef LINUX
#include <tchar.h>
#include <my_tchar.h>
#include <streamclasses.h>
#endif

#include "lite/lite.h"
#include "prim/libprim.h"                                      // 08/14/02 AM.
#include "prim/list_s.h"                                       // 08/14/02 AM.
#include "prim/list.h"                                         // 08/14/02 AM.
#include "lite/mach.h"
#include "lite/global.h"
#include "lite/inline.h"
#include "lite/nlp.h"    // ANALYZER API.
#include "lite/slist.h"                                        // 01/06/03 AM.
#include "lite/vtrun.h"                                        // 08/27/02 AM.
#include "consh/libconsh.h"
#include "consh/cg.h"   // KNOWLEDGE BASE API.
#include "lite/dir.h"
#include "lite/rug.h"   // RULE GENERATION API.
#include "lite/Aseq.h"

/********************************************
* CLASS:  NLP ENGINE
* CR:	  09/14/20 Dd.
* SUBJ:	  API Class for running the NLP engine
********************************************/

class LITE_API NLP_ENGINE
{

public:
	NLP_ENGINE(
        _TCHAR *analyzer,
        bool develop=false,
        bool silent=false,
        bool compiled=false
	);

	~NLP_ENGINE();

    _TCHAR *m_analyzer;
    _TCHAR *m_input;
    _TCHAR *m_output;
    _TCHAR *m_sequence;

    _TCHAR m_anadir[MAXSTR];
    _TCHAR m_ananame[MAXSTR];
    _TCHAR m_rfbdir[MAXSTR];
    _TCHAR m_logfile[MAXSTR];	
    _TCHAR m_specdir[MAXSTR];
    _TCHAR m_infile[MAXSTR];
    _TCHAR m_outdir[MAXSTR];
    _TCHAR m_outfile[MAXSTR];
    _TCHAR m_seqfile[MAXSTR];

    VTRun *m_vtrun;
    NLP *m_nlp;
    CG *m_cg;

    #ifdef TEST_RUG_
    CONCEPT *m_gram;
    RUG *m_rug
    #endif

    bool m_develop;
    bool m_silent;
    bool m_compiled;

    void zeroInit();

    int init(
        _TCHAR *analyzer,
        bool develop=false,
        bool silent=false,
        bool compiled=false
    );

    int analyze(
        _TCHAR *infile,
        _TCHAR *outfile,
        bool develop=false,
        bool silent=false,
        bool compiled=false
    );

    int analyze(
        _TCHAR *inbuf,
        long len,
        _TCHAR *outbuf,
        long outlen,
        bool develop=false,
        bool silent=false,
        bool compiled=false
    );

    int close();
};