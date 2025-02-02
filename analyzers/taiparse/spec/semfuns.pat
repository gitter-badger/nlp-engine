###############################################
# FILE: semfuns.pat
# SUBJ: General semantic functions.
# AUTH: AM
# CREATED: 12/Jan/05 14:30:25
# MODIFIED:
###############################################

@DECL



########
# FUNC:   ADVLREGISTER
# SUBJ:   Register an adverbial in the kb.
# CR:     09/11/02 AM.
# INPUT:  
# OUTPUT: 
# NOTE:   For adverbials not attached to a clause, eg, at the
#         start of a sentence.
#		  Register for subsequent clauses.
#		  Check for prior clauses.
########

advlregister(
	L("anode"),	# Adverbial node.
	L("snode")	# Sentence node.
	)
{
if (!L("anode") || !L("snode"))
  return;

#domadvlregister(L("anode"),L("snode"));

# Get and update count of advls in sentence node.
L("nadvls") = pnvar(L("snode"),"nadvls");
pnreplaceval(L("snode"),"nadvls", ++L("nadvls"));

# Get sentence's kb concept.
L("kb sent") = pnvar(L("snode"), "kb sent");

L("advl name") = "advl" + str(L("nadvls"));
L("kb concept") = makeconcept(L("kb sent"), L("advl name"));
replaceval(L("kb concept"),"type","advl");
replaceval(L("kb concept"),"zone",pnvar(L("anode"),"zone"));

if (G("verbose"))
  {
"dump.txt" << "[advlreg: "	# *VERBOSE*
	<< conceptname(L("kb sent"))	# *VERBOSE*
	<< " "	# *VERBOSE*
	<< L("advl name")	# *VERBOSE*
	<< "]\n";	# *VERBOSE*
"dump.txt" << "[text= "	# *VERBOSE*
	<< pnvar(L("anode"),"$text")	# *VERBOSE*
	<< "]\n";	# *VERBOSE*
  }

# Advl pnode points to kb advl concept.
pnreplaceval(L("anode"), "kb concept", L("kb concept"));

# Some crosslinks.
L("advls") = pnvar(L("snode"),"advls");
L("len") = arraylength(L("advls"));
if (L("advls"))
  L("advls")[L("len")] = L("anode");
else
  L("advls") = L("anode");	# First one.
pnreplaceval(L("snode"),"advls",L("advls"));

}

########
# FUNC:   NODESEM
# SUBJ:	  Quick and dirty fetch of "semantic" word for a node.
# CR:	  08/05/02 AM.
# RET:	  text or 0.
# WARN:	GETTING LOWERCASED TEXT.
########

nodesem(L("n"))
{
if (!L("n"))
  return 0;
if (L("sem") = pnvar(L("n"),"sem"))
  return L("sem");
if (L("sem") = pnvar(L("n"),"stem"))
  return L("sem");
if (L("text") = pnvar(L("n"),"text")) # Get from var.
  return L("text");
return strtolower(pnvar(L("n"),"$text")); # Get from tokens.
}

########
# FUNC:   NODESTEM
# SUBJ:	  Fetch stem for a node. Assume one word.
# RET:	  text or 0.
# WARN:	RETURNING LOWERCASED TEXT.
########

nodestem(L("n"))
{
if (!L("n"))
  return 0;
if (L("stem") = pnvar(L("n"),"stem"))
  return L("stem");
L("text") = pnvar(L("n"),"text"); # Get from var, if any.
if (!L("text"))
  {
  L("text") = pnvar(L("n"),"$text");
  if (!strisalpha(L("text")))
    return 0;
  }
L("arr") = nvstem(L("text"));
return L("arr")[0];
}

########
# FUNC:	SEMRANGE
# SUBJ:	Look for junk in list of nodes.
# RET:	
# NOTE:	Fills into the given node.
#	Eg, fill an NP with semantics of its noun nodes.
########
semrange(
	L("node"),	# Node to update.
	L("first"),	# First node of range.
	L("last"))	# Last node of range.
{
if (!L("node") || !L("first"))
  return;	# Last could be null, I s'ppose.

if (L("last"))
  L("last") = pnnext(L("last")); # Nice end boundary.

L("vsenses") = pnvar(L("node"),"vsenses");	# 07/23/11 AM.
L("nsenses") = pnvar(L("node"),"nsenses");	# 07/23/11 AM.
#L("senses") = 0;	# FIX.	# 02/09/11 AM.

L("n") = L("first");
while (L("n") != L("last"))
  {
  if (pnvar(L("n"),"sem") == "date")
    pnreplaceval(L("node"),"sem date",1);
  L("s") = pnvar(L("n"),"vsenses");
  if (L("s"))
	{
    L("vsenses") = unioncons(L("vsenses"),L("s"));
	}
  L("s") = pnvar(L("n"),"nsenses");
  if (L("s"))
	{
    L("nsenses") = unioncons(L("nsenses"),L("s"));
	}
#  L("s") = pnvar(L("n"),"senses");	# 2/8/11 AM.
#  if (L("s"))
#	{
#    L("senses") = unioncons(L("senses"),L("s"));	# 2/8/11 AM.
#	}
  L("n") = pnnext(L("n"));
  }

if (L("vsenses"))	# 2/8/11 AM.
  {
  pnreplaceval(L("node"),"vsenses",L("vsenses"));	# 2/8/11 AM.
  }
if (L("nsenses"))
  {
  pnreplaceval(L("node"),"nsenses",L("nsenses"));
  }

#if (L("senses"))	# 2/8/11 AM.
#  {
#  pnreplaceval(L("node"),"senses",L("senses"));	# 2/8/11 AM.
#  }


#L("senses") = pnvar(L("red"),"senses");
}

########
# FUNC:   SEMNPNOUNS
# SUBJ:   Get semantics from nouns into np.
# CR:     04/20/05 AM.
########

semnpnouns(L("np"),L("firstn"),L("headn"))
{
if (!L("np") || !L("firstn") || !L("headn"))
  return;

L("n") = L("firstn");
while (L("n") && L("n") != L("headn"))
  {
  L("sem") = pnvar(L("n"),"sem");
  if (L("sem") == "date")
    pnreplaceval(L("np"),"date node",L("n"));
  L("n") = pnnext(L("n"));
  }
}

########
# FUNC:   SEMNPNP
# SUBJ:   Compose semantics for two nps.
# CR:     05/17/05 AM.
# RET:	[0] = overriding sem object.
#		[1] = overriding text.
########

semnpnp(L("np1"),L("np2"))
{
if (!L("np1") || !L("np2"))
  return 0;

L("s1") = pnvar(L("np1"),"sem");
L("s2") = pnvar(L("np2"),"sem");

L("ne1") = pnvar(L("np1"),"ne text");
L("ne2") = pnvar(L("np2"),"ne text");

if (!L("s1"))
  L("s1") = pnvar(L("np1"),"stem");
if (!L("s2"))
  L("s2") = pnvar(L("np2"),"stem");

if (!L("s1"))
  return L("s2");
if (!L("s2"))
  return L("s1");
if (L("s1") == L("s2"))
  return L("s1");

if (L("s1") == "date" || L("s2") == "date")
  return "date";

if (L("ne1"))
  {
  L("arr")[0] = L("s2");
  L("arr")[1] = L("ne1");
  return L("arr");
  }
if (L("s1") == "name")	# Cap phrase etc.
  {
  L("arr")[0] = L("s2");
  L("arr")[1] = pnvar(L("np1"),"$text");
  return L("arr");
  }

if (L("ne2"))
  {
  L("arr")[0] = L("s1");
  L("arr")[1] = L("ne2");
  return L("arr");
  }
if (L("s2") == "name")
  {
  L("arr")[0] = L("s1");
  L("arr")[1] = pnvar(L("np2"),"$text");
  return L("arr");
  }

return L("s2");	# Default to the last one.
}

########
# FUNC:   SEMVG
# SUBJ:   Semantics for vg.
# CR:     05/17/05 AM.
########

semvg(L("vg"),L("v"),
	L("b"),L("being") )	# 09/21/19 AM.
{
if (!L("vg") || !L("v"))
  return;
L("sem") = pnvar(L("v"),"sem");
L("stem") = pnvar(L("v"),"stem");	# 09/21/19 AM.
if (!L("stem")) L("stem") = strtolower(pnvar(L("v"),"$text"));	# 09/21/19 AM.
if (!L("sem"))
  L("sem") = L("stem");
pnreplaceval(L("vg"),"sem",L("sem"));

L("vsenses") = pnvar(L("v"),"vsenses");	# 02/08/11 AM.
if (L("vsenses"))	# 02/08/11 AM.
  {
  pnreplaceval(L("vg"),"vsenses",L("vsenses"));	# 02/08/11 AM.
  }

L("nsenses") = pnvar(L("v"),"nsenses");	# 02/08/11 AM.
if (L("nsenses"))	# 02/08/11 AM.
  {
  pnreplaceval(L("vg"),"nsenses",L("nsenses"));	# 02/08/11 AM.
  }

#L("senses") = pnvar(L("v"),"senses");	# 02/08/11 AM.
#if (L("senses"))	# 02/08/11 AM.
#  {
#  pnreplaceval(L("vg"),"senses",L("senses"));	# 02/08/11 AM.
#  }
#

if (L("matchcons") = pnvar(L("v"),"MATCHCONS"))		# 03/17/14 AM.
  {
  pnreplaceval(L("vg"),"MATCHCONS",L("matchcons"));	# 03/17/14 AM.
  PRETTYCONShier(L("matchcons"),G("mhdump"));
  }
}

#########################
# REGISTERPERSNAMES
#########################
# Note: Based on text, not nodes.
registerpersnames(L("txt"))
{
if (!L("txt"))
  return;

L("lc") = strtolower(L("txt"));
L("arr") = split(L("lc")," ");
L("len") = arraylength(L("arr"));
L("ii") = 0;
while (L("ii") < L("len"))
  {
  L("t") = L("arr")[L("ii")];
  L("l") = strlength(L("t"));
  if (L("l") > 1)
    {
	L("c") = strpiece(L("t"),0,0);
	if (strisalpha(L("c")))
	  {
	  dictattr(L("t"),"persname",1);
	  if (G("verbose"))
	    "persname.txt" << L("t") << "\n";
	  }
	}
  ++L("ii");
  }
}

########
# FUNC:   SEMINIT
# SUBJ:   Initialize semantics for current parse.
# CR:     05/24/02 AM.
# INPUT:  
# OUTPUT: 
# NOTE:	  Not doing anything fancy across texts.
#	Could retain objects and/or entities across texts by
#	taking them out of the "currtext" concept.  Or by
#	having a separate collection locus for cross-document
#	accounting.  By doing both, one can decide which entities
#	to retain for cross-document vs current-document only.
########

seminit()
{
G("kbroot") = findroot();

# Kb locus for representations for current text.
G("currtext") = findconcept(G("kbroot"),"currtext");

# Clear out any structures inadvertently saved in the kb,
# or not cleared from a prior text analysis.
if (G("currtext"))
  rmconcept(G("currtext"));
  
# Now build from scratch.
G("currtext") = makeconcept(G("kbroot"),"currtext");

# Manage objects in parse of current text.
G("objects") = makeconcept(G("currtext"),"objects");

# Manage resolved-entities.
G("entities") = makeconcept(G("currtext"),"entities");

# Manage entity references.
G("ents") = makeconcept(G("currtext"),"ents");

# Manage events in parse of current text.			# 06/24/02 AM.
G("events") = makeconcept(G("currtext"),"events");	# 06/24/02 AM.

# Manage the parse of current text.
# Place sentence concepts in here, then actor, object instances
# in there.
G("parse") = makeconcept(G("currtext"),"parse");

# Counter for sentences in current parse.
G("sent count") = 0;
}

########
# FUNC:   SENTREGISTER
# SUBJ:   Register a sentence in the kb.
# CR:     05/24/02 AM.
# INPUT:  
# OUTPUT: 
########

sentregister(
	L("snode") # Sentence node.
	)
{
++G("sent count");	# Counter for sentences.
pnreplaceval(L("snode"),"sent id",G("sent count"));


L("sent name") = "sent" + str(G("sent count"));
if (G("verbose"))
  "dump.txt" << "[sentregister: " << L("sent name") << "]\n";	# *VERBOSE*
L("sent") = makeconcept(G("parse"), L("sent name"));
replaceval(L("sent"),"type","sent");

# Sentence pnode points to kb sentence concept.
pnreplaceval(L("snode"), "kb sent", L("sent"));

# Kb sentence concept points to sentence pnode.
# Unimplemented in NLP++ kb functions.	# 05/28/02 AM.
# replaceval(L("sent"),"pnode",L("snode"));
}



########
# FUNC:   CLAUSEREGISTER
# SUBJ:   Register a clause in the kb.
# CR:     05/28/02 AM.
# INPUT:  
# OUTPUT: 
########

clauseregister(
	L("cnode"),	# Clause node.
	L("snode")	# Sentence node.
	)
{
if (!L("cnode") || !L("snode"))
  return;

# Get and update count of clauses in sentence node.
L("nclauses") = pnvar(L("snode"),"nclauses");
pnreplaceval(L("snode"),"nclauses", ++L("nclauses"));

# Get sentence's kb concept.
L("kb sent") = pnvar(L("snode"), "kb sent");

L("clause name") = "clause" + str(L("nclauses"));
L("kb concept") = makeconcept(L("kb sent"), L("clause name"));
replaceval(L("kb concept"),"type","clause");
replaceval(L("kb concept"),"zone",pnvar(L("cnode"),"zone"));

if (G("verbose"))
"dump.txt" << "[clausereg: "	# *VERBOSE*
	<< conceptname(L("kb sent"))	# *VERBOSE*
	<< " "	# *VERBOSE*
	<< L("clause name")	# *VERBOSE*
	<< "]\n";	# *VERBOSE*
if (G("verbose"))
"dump.txt" << "[text= "	# *VERBOSE*
	<< pnvar(L("cnode"),"$text")	# *VERBOSE*
	<< "]\n";	# *VERBOSE*


# Clause pnode points to kb clause concept.
pnreplaceval(L("cnode"), "kb concept", L("kb concept"));

# Layer application-specific onto general structures.
#domclauseregister(L("cnode"),L("snode"));

}


########
# FUNC:   CLAUSETRAVERSE
# SUBJ:   Manually traverse a clause in the parse tree.
# CR:     05/28/02 AM.
# INPUT:  
# OUTPUT: 
########

clausetraverse(
    L("node"),	# Root node within a clause
	L("cnode"),	# Clause node.
	L("sent")	# Current sentence.
	)
{
if (!L("node") || !L("cnode"))
  return;

if (G("verbose"))
  "dump.txt" << "[clausetraverse:]" << "\n";	# *VERBOSE*

# Get clause's kb concept.
L("kb concept") = pnvar(L("cnode"), "kb concept");
if (!L("kb concept"))
  return;

# Check for eventive np.	# 07/25/02 AM.
L("nm") = pnname(L("node"));
if (L("nm") == "_np")
  {
  # Record actor or object.
  L("con") = objectregister(L("node"),L("cnode"));
	
  # Resolve with existing objects/events.
  resolveobjects(L("con"),G("objects"),G("events"));
  
  return;
  }

if (L("nm") != "_clause" && G("verbose"))
  "dump.txt" << "[clausetraverse: concept=" << L("nm") << "]\n";	# *VERBOSE*

# Get first child node.
L("n") = pndown(L("node"));

while (L("n"))
  {
  L("nname") = pnname(L("n"));
  if (L("nname") == "_np"
   || L("nname") == "_nps")
    {
#	if (pnvar(L("n"),"eventive"))
#	  domnp(L("n"),L("sent"));
	pnreplaceval(L("sent"),"last np", L("n"));

    # Record actor or object.
	L("con") = objectregister(L("n"),L("cnode"));
	
	# Resolve with existing objects/events.
	resolveobjects(L("con"),G("objects"),G("events"));
    }
  else if (L("nname") == "_vg")
    {
    # Record act.
	L("nacts") = pnvar(L("cnode"),"nacts");
	pnreplaceval(L("cnode"),"nacts", ++L("nacts"));
	L("con") = makeconcept(L("kb concept"),"act" + str(L("nacts")));
    replaceval(L("con"),"type","act");
	replaceval(L("con"),"text",
		strtolower(pnvar(L("n"),"$text")));
	pnreplaceval(L("n"),"kb act",L("con"));

	# Only handling singletons for the moment.
	if (L("nsem") = pnvar(L("n"),"sem"))
	  replaceval(L("con"),"sem", L("nsem"));

    if (L("tmp") = pnvar(L("n"),"act val"))
	  replaceval(L("con"),"act val",L("tmp"));

	if (pnvar(L("n"),"passive"))
	  replaceval(L("con"),"passive",1);
	if (pnvar(L("n"),"neg"))
	  replaceval(L("con"),"negative",1);
    }
  else if (L("nname") == "_advl" && pnvar(L("n"),"pp"))
    {
	clauseadvltraverse(L("n"),L("cnode"),L("sent"));
	}
  else if (L("nname") == "_advl"
   && pnvar(L("n"),"pattern") == "that-clause" )
    {
	# Assume np+that+clause pattern.
	L("clause") = pnvar(L("n"),"clause");
	clauseregister(L("clause"), L("sent"));
	clausetraverse(L("clause"),L("clause"),L("sent"));
	}
  else if (L("nname") == "_adj")	# assume np vg adj pattern
    {
    # Record state.
	L("con") = stateregister(L("n"),L("cnode"));
	}
  else if (L("nname") == "_clause")
    {
    if (G("verbose"))
      "clauses.txt" << pnvar(L("n"),"$text") << "\n\n";
	clauseregister(L("n"), L("sent"));
	clausetraverse(L("n"), L("n"), L("sent"));
	}
  else	# Traverse advl etc.
    clausetraverse(L("n"), L("cnode"), L("sent"));

  L("n") = pnnext(L("n"));
  }

# If the current item that we've traversed is a clause,
# fix up the event semantics for it.
semclause(L("node"),L("sent"));
}


########
# FUNC:   CLAUSEADVLTRAVERSE
# SUBJ:   Manually traverse an adverbial in the parse tree.
# CR:     09/11/02 AM.
# INPUT:  
# OUTPUT: 
########

clauseadvltraverse(
    L("n"),	# Adverbial node.
	L("cnode"),
	L("sent")	# Current sentence.
	)
{
if (G("verbose"))
  "dump.txt" << "[clauseadvltraverse:]" << "\n";	# *VERBOSE*

#domadvl(L("n"), L("sent"));
if (L("nps") = pnvar(L("n"),"pn nps"))
  {
  L("advl np") = L("nps")[0];
	pnreplaceval(L("sent"),"last np",
	      L("nps")[0]);	# (Reverse order...)
  if (L("cnode"))
    {
    L("con") = objectregister(L("advl np"),L("cnode"));
    L("np con") = resolveobjects(L("con"),G("objects"),
	  	G("events"));

    if (!L("np con")  && G("verbose"))
	  	"dump.txt" << "no np con" << "\n";	# *VERBOSE*
    }
	  
  # If np belongs to an eventive, place it there.
  if (L("ev") = pnvar(L("advl np"),"pn eventive"))
	{
    if (G("verbose"))
      "dump.txt" << pnvar(L("advl np"),"$text")	# *VERBOSE*
		  << " =event=> "	# *VERBOSE*
		  << pnvar(L("ev"),"$text")	# *VERBOSE*
		  << "\n";	# *VERBOSE*
	L("ev con") = pnvar(L("ev"),"kb obj");
	L("resolver") = conval(L("ev con"),"resolver");
	replaceval(L("resolver"),"actor",L("np con"));
	replaceval(L("np con"),"event",L("resolver"));
	}
  }
}


########
# FUNC:   ADVLTRAVERSE
# SUBJ:   Handle a non-clause adverbial.
# CR:     09/11/02 AM.
# INPUT:  
# OUTPUT: 
# NOTE:   Not a "traversal", though named that for consistency.
#         May involve lists and other complexities in the future.
########

advltraverse(
    L("n"),	# Adverbial node.
	L("sent")	# Current sentence.
	)
{
if (G("verbose"))
  "dump.txt" << "[advltraverse:]" << "\n";	# *VERBOSE*

if (!L("n") || !L("sent"))
  return;

#domadvl(L("n"),L("sent"));
if (L("nps") = pnvar(L("n"),"pn nps"))
  {
  L("advl np") = L("nps")[0];
	pnreplaceval(L("sent"),"last np",
	      L("nps")[0]);	# (Reverse order...)

    L("con") = objectregister(L("advl np"),L("n"));
    L("np con") = resolveobjects(L("con"),G("objects"),
	  	G("events"));

    if (!L("np con") && G("verbose"))
	  	"dump.txt" << "no np con" << "\n";	# *VERBOSE*
	  
  # If np belongs to an eventive, place it there.
  if (L("ev") = pnvar(L("advl np"),"pn eventive"))
	{
	if (G("verbose"))
      "dump.txt" << pnvar(L("advl np"),"$text")	# *VERBOSE*
		  << " =event=> "	# *VERBOSE*
		  << pnvar(L("ev"),"$text")	# *VERBOSE*
		  << "\n";	# *VERBOSE*
	L("ev con") = pnvar(L("ev"),"kb obj");
	L("resolver") = conval(L("ev con"),"resolver");
	replaceval(L("resolver"),"actor",L("np con"));
	replaceval(L("np con"),"event",L("resolver"));
	}
  }
}

########
# FUNC:   ADVLSHANDLE
# SUBJ:   Traverse tree of adverbials.
# CR:     09/19/02 AM.
########

advlshandle(
    L("n"),		# Adverbial node.
	L("sent")	# Current sentence.
	)
{
if (!L("n") || !L("sent"))
  return;

L("zone") = pnvar(L("n"),"zone");

if (pnvar(L("n"),"advl list"))	# List of advls.
  {
  L("list") = pndown(L("n"));
  while (L("list"))
    {
	if (L("zone"))
	  pnreplaceval(L("list"),"zone",L("zone"));
	advlshandle(L("list"),L("sent"));
	L("list") = pnnext(L("list"));
	}
  return;
  }

# Non-list adverbial here.
advlhandle(L("n"),L("sent"));
}

########
# FUNC:   ADVLHANDLE
# SUBJ:   Handle a clause-independent adverbial.
# CR:     09/19/02 AM.
# NOTE:	  Taken from qclause100, _advl rule.
########

advlhandle(
    L("n"),		# Adverbial node.
	L("sent")	# Current sentence.
	)
{
if (!L("n") || !L("sent"))
  return;

L("zone") = pnvar(L("n"),"zone");

L("clause") = pnvar(L("n"),"clause");
L("clauses") = pnvar(L("n"),"clauses");
if (L("clause"))
 {
 if (G("verbose"))
   "clauses.txt" << pnvar(L("n"),"$text") << "\n\n";
 if (L("clause"))
   {
   if (L("zone"))
     pnreplaceval(L("clause"),"zone",L("zone"));
   clauseregister(L("clause"),L("sent"));
   L("last np") = prevnp(L("sent"));
   clausetraverse(L("clause"),L("clause"),L("sent"));
   clauseresolve(L("clause"),L("sent"),L("last np"));
   pnreplaceval(L("sent"),"clause",L("clause"));
   }
 else if (L("clauses"))
   {
   L("count") = arraylength(L("clauses"));
   L("ii") = 0;
   while (L("ii") < L("count"))
     {
	 L("cls") = L("clauses")[L("ii")];
   if (L("zone"))
     pnreplaceval(L("cls"),"zone",L("zone"));
     clauseregister(L("cls"),L("sent"));
     L("last np") = prevnp(L("sent"));
     clausetraverse(L("cls"),L("cls"),L("sent"));
     clauseresolve(L("cls"),L("sent"),L("last np"));
	 pnreplaceval(L("sent"),"clause",L("cls"));
	 ++L("ii");
	 }
   }
 }
else
  {
  # Get object, perhaps semantic case, from pp.
  # Can register to the current sentence at least.
  # Could check if before, betwixt, after clauses.
  if (pnvar(L("n"),"pp"))	# Prepositional phrase
    {
	# Register adverbial as a kind of nearly empty clause.
	advlregister(L("n"),L("sent"));
	
	# Handle non-clause adverbials.
	advltraverse(L("n"),L("sent"));
	}

  }

}

########
# FUNC:   SEMCLAUSE
# SUBJ:   Handle semantics of given clause.
# CR:     06/25/02 AM.
# INPUT:  
# RET:
# NOTE:
########

semclause(L("clause"),L("sent"))
{
if (!L("clause") || !L("sent"))
  return;
if (pnname(L("clause")) != "_clause")
  return;

if (G("verbose"))
  "dump.txt" << "[semclause: " << pnvar(L("clause"),"$text")	# *VERBOSE*
	<< "]\n";

# If clause has an immediately preceding np resolving it,
# check active-passive etc.
if (L("np") = pnvar(L("clause"),"np-that"))
  {
  if (G("verbose"))
    "dump.txt" << "np-that=" << pnvar(L("np"),"$text") << "\n";	# *VERBOSE*
  if (!pnvar(L("clause"),"passive")) # Assume passive noted here.
    {
    if (!pnvar(L("clause"),"actor"))
      {
	  # Resolve as actor.
	  pnreplaceval(L("clause"),"actor",L("np"));
	  }
	}
  else	# passive present.
    {
    if (!pnvar(L("clause"),"obj"))
      {
	  # Resolve as object.
	  pnreplaceval(L("clause"),"obj",L("np"));
	  }
	}
  }


# If clause has a preceding adverbial, throw it into a date/loc
# slot (or something like that).
L("advls") = pnvar(L("sent"),"advls");
if (L("advls"))	# 09/17/02 AM.
  {
  if (G("verbose"))
	"dump.txt" << "[Found previous advl.]" << "\n";	# *VERBOSE*
  L("advl") = L("advls")[0];	# Grab only the 1st, for now.
  L("loc") = pnvar(L("advl"),"pn nps");
  pnreplaceval(L("clause"),"loc",L("loc"));
  }

# If clause isn't registered as an event, register it.
L("kb concept") = pnvar(L("clause"),"kb concept");
if (!L("kb concept"))
  return;
L("event con") = resolveevent(L("kb concept"),G("events"));
if (!L("event con"))
  return; # Error.

# Add the pieces of the event.
if (L("act") = pnvar(L("clause"),"act"))
  {
  if (L("act con") = pnvar(L("act"),"kb act"))
    {
    if (L("res") = conval(L("act con"),"resolver"))
	  L("act con") = L("res");
	replaceval(L("event con"),"act",L("act con"));
	}
  }

if (L("actor") = pnvar(L("clause"),"actor"))
  {
  if (L("actor con") = pnvar(L("actor"),"kb obj"))
    {
    if (L("res") = conval(L("actor con"),"resolver"))
	  L("actor con") = L("res");
	replaceval(L("event con"),"actor",L("actor con"));
	}
  }

if (L("obj") = pnvar(L("clause"),"dobj"))
  {
  if (L("obj con") = pnvar(L("obj")[0],"kb obj"))
    {
    if (L("res") = conval(L("obj con"),"resolver"))
	  L("obj con") = L("res");
	replaceval(L("event con"),"obj",L("obj con"));
	}
  }

if (L("iobj") = pnvar(L("clause"),"iobj"))
  {
  if (L("iobj con") = pnvar(L("iobj")[0],"kb obj"))
    {
    if (L("res") = conval(L("iobj con"),"resolver"))
	  L("iobj con") = L("res");
	replaceval(L("event con"),"iobj",L("iobj con"));
	}
  }
if (L("adj") = pnvar(L("clause"),"adj role"))
  {
  if (G("verbose"))
    "dump.txt" << "adj= " << pnvar(L("adj"),"$text")	# *VERBOSE*
  	<<  "\n";	# *VERBOSE*
  if (L("state con") = pnvar(L("adj"),"kb con"))
    {
	# No resolver mechanism for attrs, states...
	replaceval(L("event con"),"state",L("state con"));
	}
  }
if (L("loc") = pnvar(L("clause"),"loc"))
  {
  if (L("loc con") = pnvar(L("loc"),"kb obj"))
    {
    if (L("res") = conval(L("loc con"),"resolver"))
	  L("loc con") = L("res");
	replaceval(L("event con"),"loc",L("loc con"));
	}
  }

}

########
# FUNC:   CLAUSERESOLVE
# SUBJ:   Resolve inter-clause references.
# CR:     07/23/02 AM.
# INPUT:  
# OUTPUT: 
########

clauseresolve(
	L("cnode"),	# Clause node.
	L("sent"),	# Current sentence.
	L("prev np")	# Previous np in sentence.
	)
{
if (!L("cnode") || !L("sent"))
  return;

# Get clause's kb concept.
L("kb concept") = pnvar(L("cnode"), "kb concept");
if (!L("kb concept"))
  return;

# Get event resolver.
L("event") = conval(L("kb concept"),"resolver");
if (!L("event"))
  return;

L("pattern") = pnvar(L("cnode"),"pattern");

if (L("pattern") == "ellipted-that-clause")
  {
  # Look for the immediately preceding np, structurally.
  if (G("verbose"))
    "dump.txt" << "ellipted-that-clause\n";	# *VERBOSE*
  
  # Get prev np in sent.
  if (!L("prev np"))
    return;
  if (G("verbose"))
    "dump.txt" << "clauseresolve: prev np=" << pnvar(L("prev np"),	# *VERBOSE*
  	"$text") << "\n";	# *VERBOSE*
  # Assume something like "np vg-passive"

  if (!(L("con") = pnvar(L("prev np"),"kb obj") ))
    return;
  if (!(L("res") = conval(L("con"),"resolver") ))
    return;
  replaceval(L("event"),"obj",L("res"));
  return;
  }

# Get prior clause from current sentence, if any.
if (!(L("cprev") = pnvar(L("sent"),"clause")))
  return;

# Get prev clause's kb concept.
L("kb cprev") = pnvar(L("cprev"), "kb concept");
if (!L("kb cprev"))
  return;

# Get event resolver.
L("prev event") = conval(L("kb cprev"),"resolver");
if (!L("prev event"))
  return;

if (G("verbose"))
  "dump.txt" << "[clauseresolve: got prior clause "	# *VERBOSE*
	<< conceptname(L("kb cprev"))	# *VERBOSE*
	<< "]\n";	# *VERBOSE*

# Only handle "that-clause.
if (L("pattern") != "that-clause")
  return;

if (G("verbose"))
  "dump.txt" << "[clauseresolve: got that-clause]" << "\n";	# *VERBOSE*

# If previous already has an object, can't fill it here.
if (conval(L("prev event"),"obj"))
  return;

# Fill previous clause's object with current clause.
replaceval(L("prev event"),"obj",L("event"));
}


########
# FUNC:   OBJECTREGISTER
# SUBJ:   Register an actor/object in the kb.
# CR:     06/24/02 AM.
# CR:     06/12/05 AM.
# RET:	  Object's concept.
# NOTE:	  New version of an old function.
########

objectregister(
	L("n"),	# Object's node.
	L("cnode")	# Object's clause node.
	)
{
if (!L("n") || !L("cnode"))
  return 0;

if (G("verbose"))
"dump.txt" << "[objectregister:] "	# *VERBOSE*
	<< pnvar(L("n"),"$text")	# *VERBOSE*
	<< "\n";	# *VERBOSE*

# Tracking instances of "I".
if (pnvar(L("n"),"stem") == "i")
  ++G("1st person");

# Get clause's kb concept.
L("kb concept") = pnvar(L("cnode"), "kb concept");
if (!L("kb concept"))
  return 0;

# Record actor or object.
# Make and fill obj concept.
L("txt") = strtolower(pnvar(L("n"),"$text"));
L("nobjs") = pnvar(L("cnode"),"nobjs");
pnreplaceval(L("cnode"),"nobjs", ++L("nobjs"));
#L("con") = makeconcept(L("kb concept"),"obj" + str(L("nobjs")));
L("con") = makeconcept(L("kb concept"),"obj" + str(L("nobjs"))
	+ " = " + L("txt"));
replaceval(L("con"),"type","obj");
replaceval(L("con"),"text",L("txt"));
if (L("sem") = pnvar(L("n"),"sem"))
  replaceval(L("con"),"sem",strtolower(L("sem")));
pnreplaceval(L("n"),"kb obj",L("con"));

if (pnvar(L("n"),"eventive"))	# 07/10/02 AM.
  replaceval(L("con"),"eventive",1);	# 07/10/02 AM.

if (pnvar(L("n"),"ne"))	# Named entity.
  replaceval(L("con"),"ne",1);

L("ne type") = pnvar(L("n"),"ne type");
if (L("ne type"))
  replaceval(L("con"),"ne type",L("ne type"));

L("ne type conf") = pnvar(L("n"),"ne type conf");
if (L("ne type conf"))
  replaceval(L("con"),"ne type conf",L("ne type conf"));

L("ne text") = pnvar(L("n"),"ne text");
if (L("ne text"))
  replaceval(L("con"),"ne text",L("ne text"));

# Handle singleton.
if (L("nsem") = pnvar(L("n"),"sem"))
  replaceval(L("con"),"sem", L("nsem"));

if (pnvar(L("n"),"pro"))	# If a pronoun.
  replaceval(L("con"),"pro",1);

#domcopynodetocon(L("n"),L("con"));

# If a list of nps, handle it.
# (nps were collected in REVERSE order.)	# 07/10/02 AM.
if (L("count") = pnvar(L("n"),"count"))
  replaceval(L("con"),"count",L("count"));
L("nps") = pnvar(L("n"),"nps");	# List of np nodes.
L("num") = L("count");
while (--L("num") >= 0)
  {
  # Register each object.
  # Link to group concept also...
  L("one") = L("nps")[L("num")];
  L("obj") = objectregister(L("one"),L("cnode"));
  
  # Cross link.
  addconval(L("con"),"cons",L("obj"));
  replaceval(L("obj"),"group",L("con"));
  }

return L("con");
}

########
# FUNC:   RESOLVEOBJECTS
# SUBJ:   Resolve object reference to objects in the text.
# CR:     07/10/02 AM.
# INPUT:  
# RET:	con - Resolving object.
# NOTE:		Requiring precise text compare, for now.
########

resolveobjects(
	L("ref"),		# An object reference.
	L("objects"),	# KB concept managing objects.
	L("events")		# KB concept managing events.
	)
{
if (!L("ref"))
  return 0;

if (G("verbose"))
  "dump.txt" << "[resolveobjects: ref="	# *VERBOSE*
	<< conceptname(L("ref"))	# *VERBOSE*
	<< "]\n";	# *VERBOSE*

# If not eventive...
# Resolve object with existing objects in the text.
if (numval(L("ref"),"pro"))
  L("ret") = resolvepro(L("ref"),L("objects"),L("events"));
else if (!numval(L("ref"),"eventive"))
  L("ret") = resolveobject(L("ref"),G("objects"));

# Else if eventive...
# Resolve with existing events in the text.	# 06/24/02 AM.
else
  L("ret") = resolveevent(L("ref"),L("events"));

L("count") = numval(L("ref"),"count");
if (L("count") <= 1)	# Single object.
  return L("ret");

L("num") = 0;
L("cons") = findvals(L("ref"),"cons");
while (L("num") < L("count"))
  {
  L("con") = getconval(L("cons"));
  if (numval(L("con"),"pro"))	# If a pronoun...
    resolvepro(L("con"),L("objects"),L("events"));
  else if (numval(L("con"),"eventive"))
    resolveevent(L("con"),L("events"));
  else
    resolveobject(L("con"),L("objects"));

  ++L("num");
  L("cons") = nextval(L("cons"));
  }
return L("ret");
}

########
# FUNC:   MERGEOBJECTATTRS
# SUBJ:   Merge a reference's attributes into resolved object.
# CR:     03/21/06 AM.
# INPUT:  
# RET:	con - Resolving object.
# NOTE:		Requiring precise text compare, for now.
########

mergeobjectattrs(
	L("cobj"),		# Object reference.
	L("cobject")	# Resolved object.
	)
{
if (!L("cobj") || !L("cobject"))
  return;

# Named entity logic.
L("ne type conf") = numval(L("cobj"),"ne type conf");
L("conf") = numval(L("cobject"),"ne type conf");
if (L("ne type conf") <= L("conf"))
  return;

# Straight copy.
copyobjectattrs(L("cobj"),L("cobject"));
}

########
# FUNC:   COPYOBJECTATTRS
# SUBJ:   Copy a reference's attributes into resolved object.
# CR:     03/21/06 AM.
# INPUT:  
# RET:	con - Resolving object.
# NOTE:		Requiring precise text compare, for now.
########

copyobjectattrs(
	L("cobj"),		# Object reference.
	L("cobject")	# Resolved object.
	)
{
if (!L("cobj") || !L("cobject"))
  return;

if (numval(L("cobj"),"eventive"))
  replaceval(L("cobject"),"eventive",1);

# Named entity logic.

if (numval(L("cobj"),"ne"))	# Named entity.
  replaceval(L("cobject"),"ne",1);
else
  return;	# DONE.

L("ne type conf") = numval(L("cobj"),"ne type conf");
if (L("ne type conf"))
  replaceval(L("cobject"),"ne type conf",L("ne type conf"));

L("ne type") = strval(L("cobj"),"ne type");
if (L("ne type"))
  replaceval(L("cobject"),"ne type",L("ne type"));

L("ne text") = strval(L("cobj"),"ne text");
if (L("ne text"))
  replaceval(L("cobject"),"ne text",L("ne text"));
}

########
# FUNC:   RESOLVEOBJECT
# SUBJ:   Resolve object reference to objects in the text.
# CR:     05/28/02 AM.
# INPUT:  
# RET:	con - Resolving object.
# NOTE:		Requiring precise text compare, for now.
########

resolveobject(
	L("ref"),		# An object reference concept.
	L("objects")	# KB concept managing objects.
	)
{
if (!L("objects") || !L("ref"))
  return 0;

L("list") = down(L("objects"));
if (!L("list"))	# Empty objects list.
  {
  # Just add the reference and done.
  if (G("verbose"))
	"dump.txt" << "[resolveobject: make object1]\n";	# *VERBOSE*
  L("txt") = strval(L("ref"),"text");
#  L("con") = makeconcept(L("objects"),"object1");
  L("con") = makeconcept(L("objects"),"object1 = "+L("txt"));
  replaceval(L("con"),"type","object");
  replaceval(L("objects"),"count",1);
  replaceval(L("con"),"text",L("txt"));
  if (L("sem") = strval(L("ref"),"sem"))
    replaceval(L("con"),"sem",L("sem"));
  copyobjectattrs(L("ref"),L("con"));
#  domcopyattrs(L("ref"),L("con"));
  replaceval(L("con"),"refs",L("ref")); # Point to ref concepts.
  replaceval(L("ref"),"resolver",L("con"));
  return L("con");
  }

# Traverse the list of existing objects, looking for a mergable
# object.  For now, requiring exact text match.
L("merged") = 0;	# Not merged with an existing object.
L("done") = 0;
L("cand") = L("list");	# Candidate object.
while (!L("done"))
  {
  # Should use hierarchy concepts as part of the merge test...
  if ((strval(L("cand"),"text") == strval(L("ref"),"text"))
#   && (strval(L("cand"),"sem") == strval(L("ref"),"sem"))
   )
    {
	# Successful merge.
	L("merged") = 1;
	L("done") = 1;
	addconval(L("cand"),"refs",L("ref"));
    replaceval(L("ref"),"resolver",L("cand"));
    mergeobjectattrs(L("ref"),L("cand"));
	return L("cand");
	}
  
  L("cand") = next(L("cand"));
  if (!L("cand"))
    L("done") = 1;
  }


if (!L("merged"))	# Didn't find an existing object.
  {
  # Just add the reference and done.
  L("ct") = numval(L("objects"),"count");
  L("txt") = strval(L("ref"),"text");
  replaceval(L("objects"),"count", ++L("ct"));	# inc count.
#  L("nm") = "object" + str(L("ct"));
  L("nm") = "object" + str(L("ct")) + " = " + L("txt");
  if (G("verbose"))
	"dump.txt" << "[resolveobject: make "	# *VERBOSE*
  	<< L("nm") << "]\n";	# *VERBOSE*
  L("con") = makeconcept(L("objects"),L("nm"));
  replaceval(L("con"),"type","object");
  replaceval(L("con"),"text",strval(L("ref"),"text"));
  if (L("sem") = strval(L("ref"),"sem"))
    replaceval(L("con"),"sem",L("sem"));
  copyobjectattrs(L("ref"),L("con"));
#  domcopyattrs(L("ref"),L("con"));
  addconval(L("con"),"refs",L("ref")); # Point to ref concept.
  replaceval(L("ref"),"resolver",L("con"));
  return L("con");
  }
return L("con");
}

########
# FUNC:   RESOLVEPRO
# SUBJ:   Resolve pronoun reference to objects in the text.
# CR:     07/24/02 AM.
# INPUT:  
# RET:	con - Resolving object.
# NOTE:	  May handle other anaphoric utterances, eventually.
########

resolvepro(
	L("ref"),		# An object reference.
	L("objects"),	# KB concept managing objects.
	L("events")		# KB concept managing events.
	)
{
if (!L("objects") || !L("events") || !L("ref"))
  return 0;

L("list") = down(L("objects"));
if (!L("list"))	# Empty objects list.
  {
  if (G("verbose"))
    "dump.txt" << "[resolvepro: No objects.]\n";	# *VERBOSE*
  # Couldn't resolve.
  # Could be something like "It is raining...."
  return 0;
  }

# Traverse the list of existing objects, looking for a mergable
# object.  (Todo: look at prior events, states also...)
L("merged") = 0;	# Not merged with an existing object.
L("done") = 0;
L("cand") = L("list");	# Candidate object.

# Go to end of the list.
while (next(L("cand")))
  L("cand") = next(L("cand"));

while (!L("done"))
  {
  # Trivial heuristic.  Look back to the nearest object
  # that doesn't conflict with person, plural, etc.
  # Examine individual pronouns I, we, you, etc....
  # Should use hierarchy concepts as part of the merge test...
  if (mergableobjs(L("ref"),L("cand")) )
    {
	if (G("verbose"))
	  "dump.txt" << "[resolvepro: Trivial proximity heur, merge with "	# *VERBOSE*
		<< conceptname(L("cand"))	# *VERBOSE*
		<< "]\n";	# *VERBOSE*

	# Successful merge.
	L("merged") = 1;
	L("done") = 1;
	addconval(L("cand"),"refs",L("ref"));
    replaceval(L("ref"),"resolver",L("cand"));
	return L("cand");
	}
  
  L("cand") = prev(L("cand"));
  if (!L("cand"))
    L("done") = 1;
  }
}

if (!L("merged"))	# Didn't find an existing object.
  {
  return 0;
  }

########
# FUNC:   MERGABLEOBJS
# SUBJ:   See if object reference can be merged with candidate.
# CR:     08/01/02 AM.
# INPUT:  
# RET:	bool - 1 if mergable, else 0.
# NOTE:
########

mergableobjs(L("ref"),	# Object reference.
	L("cand"))	# Object in kb list.
{
if (!L("ref") || !L("cand"))
  return 0;

L("sem") = strval(L("cand"),"sem");

# Don't merge with dates, for now!
if (L("sem") == "date")
  return 0;

# Don't merge with locations for now!
# Todo: better get of location semantics.
if (L("sem") == "country")
  return 0;

# Todo: Put more tests here, like plural, etc.

return 1;
}


########
# FUNC:   STATEREGISTER
# SUBJ:   Record state in semantics.
# CR:     07/18/02 AM.
# INPUT:  
# RET:	con - state's concept.
# NOTE:
########

stateregister(
	L("n"),     # State node.
	L("cnode")	# Clause.
	)
{
if (!L("n") || !L("cnode"))
  return 0;

# Get clause's kb concept.
L("kb concept") = pnvar(L("cnode"), "kb concept");
if (!L("kb concept"))
  return 0;

# Record actor or object.
L("nstates") = pnvar(L("cnode"),"nstates");
pnreplaceval(L("cnode"),"nstates", ++L("nstates"));
L("con") = makeconcept(L("kb concept"),"state" + str(L("nstates")));
replaceval(L("con"),"type","state");
replaceval(L("con"),"text",
  strtolower(pnvar(L("n"),"$text")));
pnreplaceval(L("n"),"kb con",L("con"));
	
# Handle singleton.
if (L("nsem") = pnvar(L("n"),"sem"))
  replaceval(L("con"),"sem", L("nsem"));

return L("con");
}


########
# FUNC:   RESOLVEEVENT
# SUBJ:   Resolve eventive np reference to events in the text.
# CR:     05/28/02 AM.
# INPUT:  
# RETURN:	event_con - Resolved event concept.
# NOTE:		Requiring precise text compare, for now.
########

resolveevent(
	L("ref"),		# An eventive np reference.
	L("events")		# KB concept managing events in current text.
	)
{
if (!L("events") || !L("ref"))
  return 0;

L("list") = down(L("events"));
if (!L("list"))	# Empty events list.
  {
  # Just add the reference and done.
  return newevent(L("ref"),L("events"));
  }

# Traverse the list of existing events, looking for a mergable
# event.  For now, requiring exact text match.
L("merged") = 0;	# Not merged with an existing event.
L("done") = 0;
L("cand") = L("list");	# Candidate object.
L("rtext") = strval(L("ref"),"text");
while (!L("done"))
  {
  # Should use hierarchy concepts as part of the merge test...
#  "dump.txt" << "[resolveevent: cand="	# *VERBOSE*
#  	<< strval(L("cand"),"text")	# *VERBOSE*
#	<< " ref=" << L("rtext") << "]\n";	# *VERBOSE*
  if (L("rtext")
   && strval(L("cand"),"text") == L("rtext") )
    {
	# Successful merge.
	L("merged") = 1;
	L("done") = 1;
	addconval(L("cand"),"refs",L("ref"));
    replaceval(L("ref"),"resolver",L("cand"));
#	dommergeevent(L("ref"),L("cand"));
	return L("cand");
	}
  
  L("cand") = next(L("cand"));
  if (!L("cand"))
    L("done") = 1;
  }

# Didn't find an existing object.
# Just add the reference and done.
return newevent(L("ref"),L("events"));
}

########
# FUNC:   NEWEVENT
# SUBJ:   Register a new (unmergeable) event in semantics.
# CR:     06/25/02 AM.
# INPUT:  
# OUTPUT: 
########

newevent(
   L("ref"),	# Reference concept.
   L("events")  # Kb list of event concepts to update.
   )
{
L("ct") = numval(L("events"),"count");
replaceval(L("events"),"count", ++L("ct"));	# inc count.
L("nm") = "event" + str(L("ct"));
if (G("verbose"))
  "dump.txt" << "[new event: " << L("nm") << "]\n";	# *VERBOSE*
L("con") = makeconcept(L("events"),L("nm"));
replaceval(L("con"),"type","event");
L("rtext") = strval(L("ref"),"text");
if (L("rtext"))
  replaceval(L("con"),"text",L("rtext"));

addconval(L("con"),"refs",L("ref")); # Point to ref concept.
replaceval(L("ref"),"resolver",L("con"));

# Application-specific fixups.
#domnewevent(L("ref"),L("con"));	# 09/18/02 AM.

return L("con");
}


########
# FUNC:   COMPLEXTRAVERSE
# SUBJ:   Manually traverse a complex clause in the parse tree.
# CR:     05/28/02 AM.
# INPUT:  
# OUTPUT: 
########

complextraverse(
	L("cxnode"),	# Complex node.
	L("snode")		# Sentence node.
	)
{
if (!L("cxnode") || !L("snode"))
  return;

L("n") = pndown(L("cxnode"));
while (L("n"))
  {
  if (pnname(L("n")) == "_clause")
    {
    if (G("verbose"))
	  "clauses.txt" << pnvar(L("n"),"$text") << "\n\n";
	L("last np") = prevnp(L("snode"));	# 09/22/02 AM.
	pnreplaceval(L("n"),"zone",pnvar(L("cxnode"),"zone"));
	clauseregister(L("n"),L("snode"));
    clausetraverse(L("n"),L("n"),L("snode"));
	clauseresolve(L("n"),L("snode"),L("last np"));
	}
  L("n") = pnnext(L("n"));
  }
}

########
# FUNC:   ENTREGISTER
# SUBJ:   Register an entity reference in the kb.
# CR:     03/21/06 AM.
# RET:	  Entity reference concept.
# NOTE:	  Distinguishing ent and entity.
#	ent = specific reference to entity in text.
#   entity = resolved entity that covers multiple references.
#	Also distinguishing entities from objects.
#	eg, "New York residents".  Object is "residents", but
#	a contained entity is "New York".
#
#	Owning concept could be the entity reference itself.
########

entregister(
	L("n"),		# Entity's pnode.
	L("nown")	# Entity's owning node (e.g., an _np node).
	)
{
if (!L("n") || !L("nown"))
  return 0;


if (!pnvar(L("n"),"ne"))	# Not named entity.
  return 0;

# (Could make this a parameter).
L("ents") = G("ents");	# Locus for placing ents.

# Get clause's kb concept.
#L("kb concept") = pnvar(L("nown"), "kb concept");

# Make and fill ent concept.
L("txt") = strtolower(pnvar(L("n"),"$text"));
L("nents") = numval(L("ents"),"nents");
replaceval(L("ents"),"nents", ++L("nents"));

L("con") = makeconcept(L("ents"),"ent" + str(L("nents"))
	+ " = " + L("txt"));

#replaceval(L("con"),"type","ent");
replaceval(L("con"),"text",L("txt"));
if (L("sem") = pnvar(L("n"),"sem"))
  replaceval(L("con"),"sem",strtolower(L("sem")));
pnreplaceval(L("n"),"kb ent",L("con"));

if (pnvar(L("n"),"eventive"))	# 07/10/02 AM.
  replaceval(L("con"),"eventive",1);	# 07/10/02 AM.

replaceval(L("con"),"ne",1);

L("ne type") = pnvar(L("n"),"ne type");
if (L("ne type"))
  replaceval(L("con"),"ne type",L("ne type"));

L("ne type conf") = pnvar(L("n"),"ne type conf");
if (L("ne type conf"))
  replaceval(L("con"),"ne type conf",L("ne type conf"));

L("ne text") = pnvar(L("n"),"ne text");
if (L("ne text"))
  replaceval(L("con"),"ne text",L("ne text"));

return L("con");
}

########
# FUNC:   RESOLVEENTITY
# SUBJ:   Lookup ent reference in entities.
# NOTE:	  An np may have a list of entities, so that
#		  list of entities might not match list of objects.
# RET:    Entity concept.
########

resolveentity(
	L("cref"),	# Ent reference concept.
	L("entities")
	)
{
if (!L("cref") || !L("entities"))
  return 0;

L("list") = down(L("entities"));
if (!L("list"))	# Empty objects list.
  {
  # Just add the reference and done.
  if (G("verbose"))
	"dump.txt" << "[resolveentity: make entity1]\n";	# *VERBOSE*
  L("txt") = strval(L("cref"),"text");
  L("con") = makeconcept(L("entities"),"entity1 = "+ L("txt"));
#  replaceval(L("con"),"type","entity");
  replaceval(L("entities"),"count",1);
  replaceval(L("con"),"text",L("txt"));
  if (L("sem") = strval(L("cref"),"sem"))
    replaceval(L("con"),"sem",L("sem"));
  copyobjectattrs(L("cref"),L("con"));
  replaceval(L("con"),"refs",L("cref")); # Point to ref concepts.
  replaceval(L("cref"),"resolver",L("con"));
  return L("con");
  }


# Traverse the list of existing objects, looking for a mergable
# object.  For now, requiring exact text match.
L("merged") = 0;	# Not merged with an existing object.
L("done") = 0;
L("cand") = L("list");	# Candidate object.
while (!L("done"))
  {
  # Should use hierarchy concepts as part of the merge test...
  if ((strval(L("cand"),"text") == strval(L("cref"),"text"))
#   && (strval(L("cand"),"sem") == strval(L("cref"),"sem"))
   )
    {
	# Successful merge.
	L("merged") = 1;
	L("done") = 1;
	addconval(L("cand"),"refs",L("cref"));
    replaceval(L("cref"),"resolver",L("cand"));
    mergeobjectattrs(L("cref"),L("cand"));
	return L("cand");
	}
  
  L("cand") = next(L("cand"));
  if (!L("cand"))
    L("done") = 1;
  }


if (!L("merged"))	# Didn't find an existing object.
  {
  # Just add the reference and done.
  L("ct") = numval(L("entities"),"count");
  L("txt") = strval(L("cref"),"text");
  replaceval(L("entities"),"count", ++L("ct"));	# inc count.
  L("nm") = "entity" + str(L("ct")) + " = " + L("txt");
  if (G("verbose"))
	"dump.txt" << "[resolveentity: make "	# *VERBOSE*
  	<< L("nm") << "]\n";	# *VERBOSE*
  L("con") = makeconcept(L("entities"),L("nm"));
#  replaceval(L("con"),"type","entity");
  replaceval(L("con"),"text",strval(L("cref"),"text"));
  if (L("sem") = strval(L("cref"),"sem"))
    replaceval(L("con"),"sem",L("sem"));
  copyobjectattrs(L("cref"),L("con"));
  addconval(L("con"),"refs",L("cref")); # Point to ref concept.
  replaceval(L("cref"),"resolver",L("con"));
  return L("con");
  }
return L("con");

}

########
# FUNC:   FINDCONCEPTWITHPARENT
# SUBJ:   Lookup semantic concept with given parent name.
# CR:     06/02/02 AM.
# INPUT:  
# OUTPUT: L("sem con") = Concept having parent with given name.
# NOTE:	 Looking up in dictionary, then traversing from there
#		 to a semantic hierarchy.
#		 I guess conval works with attrs by name, not concept.
#		 Todo: handle list of concept values when fetching the
#		 attr.
########

findconceptwithparent(
	L("word"),			# Word to lookup in dictionary.
	L("attrname"),		# Attribute to follow in dict word.
	L("parentname")		# Parent's name in sem hierarchy.
	)
{
L("con") = 0;
if (!L("word") || !L("attrname") || !L("parentname"))
  return 0;
#"dump.txt" << "[fcwpar: word=" << L("word")	# *VERBOSE*
#	<< ",attr=" << L("attrname")	# *VERBOSE*
#	<< ",par=" << L("parentname")	# *VERBOSE*
#	<< "\n";	# *VERBOSE*
L("word con") = dictfindword(L("word"));
if (!L("word con"))
  return 0;
L("sem con") = conval(L("word con"),L("attrname"));
if (!L("sem con"))
  return 0;
#"dump.txt" << "[fcwpar: sem con=" << conceptname(L("sem con")) << "\n";	# *VERBOSE*
L("parent") = conceptname(up(L("sem con")));
#"dump.txt" << "[fcwpar: par=" << L("parent")	# *VERBOSE*
#	<< ",parname=" << L("parentname")	# *VERBOSE*
#	<< "\n";	# *VERBOSE*
if (L("parent") != L("parentname"))
  return 0;
return L("sem con");	# Success.
}

########
# FUNC:   ANAPHORIC
# SUBJ:   Traverse events to resolve anaphora.
# CR:     05/28/02 AM.
# INPUT:  
# OUTPUT: 
# NOTE:	Perhaps should be in discourse functions pass.
########

anaphoric(
	L("events") # Domain events concept.
	)
{
if (!L("events"))
  return;
L("ev") = down(L("events"));
while (L("ev"))
  {
  # If event is missing an actor.
  # Heur: First look in the same clause.
  if (!conval(L("ev"),"actor"))
    {
	if (G("verbose"))
	  "dump.txt" << "[ana: Missing actor in '"	# *VERBOSE*
		<< conceptname(L("ev"))	# *VERBOSE*
		<< "]\n";	# *VERBOSE*

	# If event is eventive np, don't use an eventive np to
	# resolve it.
	L("refs") = conval(L("ev"),"refs");
	L("eventive") = numval(L("refs"),"eventive");

	# Look at first ref (that led to event creation).
	# May want to have a special field for that, given
	# that we don't know what kb does with ordering.
	L("ref") = conval(L("ev"),"refs");
	L("con") = L("ref");
	L("done") = 0;
	while (!L("done"))
	  {
	  if (L("con") = prev(L("con")))
	    {
		if (strval(L("con"),"type") == "obj")
		  {
		  L("ok") = 0;
		  if (!L("eventive"))
		    L("ok") = 1;
		  else if (!numval(L("con"),"eventive")
		   && !numval(L("con"),"count")) # A group of nps.
		    L("ok") = 1;
		  if (L("ok"))
		   {
		    # Found anaphor.
		    L("done") = 1;
		    # Point to actor.
		    if (L("res") = conval(L("con"),"resolver"))
		      {
			  replaceval(L("ev"),"actor",L("res"));
			  if (G("verbose"))
				"dump.txt" << "anaphoric: found actor="	# *VERBOSE*
				<< strval(L("res"),"text") << "\n";	# *VERBOSE*
			  }
			}
		  }
		}
	  else
	    L("done") = 1;
	  }
	
	# Look backward in same clause.
	
	}
  L("ev") = next(L("ev"));
  }
}

########
# FUNC:   MOVEBACK
# SUBJ:   Given a kb clause object, back up one.
# CR:     07/25/02 AM.
# INPUT:  
# OUTPUT: 
# NOTE:	  May back up into a previous clause.
#		Utility for resolving references.
########

moveback(L("con"))
{
if (!L("con"))
  return 0;
if (L("prev") = prev(L("con")))
  return L("prev");
L("type") = strval(L("con"),"type");
if (L("type") == "clause" || L("type") == "sent")
  return 0;

# Get current clause.
if (!(L("cls") = up(L("con")) ))
  return 0;

# Get previous clause.
if (!(L("cls") = prev(L("cls")) ))
  return 0;

# Get first item in prev clause.
if (!(L("dn") = down(L("cls")) ))
  return 0;

# Get last item in prev clause.
while (L("tmp") = next(L("dn")) )
  {
  L("dn") = L("tmp");
  }
return L("dn");
}

########
# FUNC:   PREVNP
# SUBJ:   Given a sentence node, find its last np so far.
# CR:     07/29/02 AM.
# INPUT:  
# OUTPUT: 
# NOTE:
#		Utility for resolving references.
########

prevnp(L("sent")) # sentence node
{
if (!L("sent"))
  return 0;
if (L("np") = pnvar(L("sent"),"last np"))
  {
  return L("np");
  }
return 0;
}


######
# FN:  NENODERANGE
# SUBJ: Look for named entities in node range.
# RET:	array of nodes.
######

nenoderange(L("start"),L("end"))
{
if (!L("start"))
  return 0;
if (L("end"))
  L("end") = pnnext(L("end"));
L("node") = L("start");
L("ii") = 0;
L("arr") = 0;
while (L("node"))
  {
  if (pnvar(L("node"),"ne"))
    {
	L("arr")[L("ii")] = L("node");
	++L("ii");
	}
  if (L("node") == L("end"))
    return L("arr");
  L("node") = pnnext(L("node"));
  }
return L("arr");
}
######
# FN:  NECHILDREN
# SUBJ: Look for named entities in node's children.
# RET:	Place array of named entity nodes in given node.
######

nechildren(
	L("node")	# The parent node (usu just created).
	)
{
}

######
# FN:  SEMACTORNODE
# SUBJ: See if sem is a good actor, eg for "by-np".
# RET:	1 if good actor else 0.
# NOTE: Assume good unless you know otherwise.
######

semactornode(L("n"))
{
if (!L("n"))
  return 0;

L("sem") = nodesem(L("n"));
if (!L("sem"))
  return 1;	# NO SEM, so can't exclude good actor.

if (L("sem") == "date"
 || L("sem") == "geoloc"
 || L("sem") == "quantiy")
  return 0;	# Not good actor.

return 1; # COULND'T DISQUALIFY AS ACTOR.
}

########
# FUNC:   SEMCOMPOSE
# SUBJ:   General semantic grouping function.
# CR:     11/01/05 AM.
########

semcompose(
	L("node"),	# Node to place stuff into.
	L("arr")	# Items of semantic interest, in order.
	)
{
if (!L("node") || !L("arr"))
  return;
pnreplaceval(L("node"),"subs",L("arr"));
}

########
# FUNC:   SEMCOMPOSENP
# SUBJ:   General semantic grouping function for np.
# CR:     11/01/05 AM.
########

semcomposenp(
	L("node"),	# Node to place stuff into.
	L("start"),	# Start of node list.
	L("head")	# End of node list.
	)
{
if (!L("node") || !L("start"))
  return;
if (L("head"))
  L("end") = pnnext(L("head"));
else
  L("end") = 0;

L("arr") = 0;
L("ii") = 0;
L("n") = L("start");
while (L("n") && L("n") != L("end"))
  {
  L("nm") = pnname(L("n"));
  if (L("nm") == "_adj"
   || L("nm") == "_noun"
   || L("nm") == "_verb"
   || L("nm") == "_adv"
   || L("nm") == "_np"
   || L("nm") == "_vg"
   )
    {
    L("arr")[L("ii")] = L("n");
    ++L("ii");
	}
  L("n") = pnnext(L("n"));
  }
pnreplaceval(L("node"),"subs",L("arr"));

# Compare senses of head with each other part of np in turn.
#wsdnp(L("node"),L("start"),L("head"));
}


########
# FUNC:   SEMCOMPOSETWO
# SUBJ:   Compose semantics for two nodes.
########

semcomposetwo(
	L("n"),	# Reduce node
	L("n1"),	# First subnode
	L("n2")		# Second subnode
	)
{
if (!L("n") || !L("n1") || !L("n2"))
  return;

L("s")  = pnvar(L("n"),"vsenses");
L("s1") = pnvar(L("n1"),"vsenses");
L("s2") = pnvar(L("n2"),"vsenses");
L("union1") = unioncons(L("s1"),L("s2"));
L("tot") = unioncons(L("s"),L("union1"));
pnreplaceval(L("n"),"vsenses",L("tot"));

L("s")  = pnvar(L("n"),"nsenses");
L("s1") = pnvar(L("n1"),"nsenses");
L("s2") = pnvar(L("n2"),"nsenses");
L("union1") = unioncons(L("s1"),L("s2"));
L("tot") = unioncons(L("s"),L("union1"));
pnreplaceval(L("n"),"nsenses",L("tot"));

#L("s")  = pnvar(L("n"),"senses");
#L("s1") = pnvar(L("n1"),"senses");
#L("s2") = pnvar(L("n2"),"senses");
#L("union1") = unioncons(L("s1"),L("s2"));
#L("tot") = unioncons(L("s"),L("union1"));
#pnreplaceval(L("n"),"senses",L("tot"));
}



####################################
### FROM KBLOAD PASS (TAIPARSE)
####################################
########
# FUNC:	DICTATTR
# SUBJ:	Add attribute for dictionary word.
########

########
# FUNC:	FINDDICTATTR
# SUBJ:	Add attribute for dictionary word.
# RET:	Numeric-valued attr.
########

########
# FUNC:	FINDDICTSATTR
# SUBJ:	Add attribute for dictionary word.
# RET:	String-valued attr.
########


@CODE
L("hello") = 0;
@@CODE
