###############################################
# FILE: KBFuncs.pat
# SUBJ: Call the DumpKB function
# AUTH: Your Name
# CREATED: 2020-11-19 8:40:53
# MODIFIED:
###############################################

@DECL

###############################################
# General functions
###############################################

AddUniqueCon(L("concept"),L("name")) {
	L("con") = findconcept(L("concept"),L("name"));
	if (!L("con")) L("con") = makeconcept(L("concept"),L("name"));
	return L("con");
}

###############################################
# KB Dump Functins
###############################################

DumpKB(L("con"),L("file")) {
	L("dir") = G("$apppath") + "/kb/";
	L("filename") = L("dir") + L("file") + ".kb";
	if (!kbdumptree(L("con"),L("filename"))) {
		"kb.txt" << "FAILED dump: " << L("filename") << "\n";
	} else {
		"kb.txt" << "DUMPED: " << L("filename") << "\n";
	}
}

IncrementCount(L("con"),L("countname")) {
	L("count") = numval(L("con"),L("countname"));
	if (L("count")) {
		L("count") = L("count") + 1;
		replaceval(L("con"),L("countname"),L("count"));
	} else {
		addnumval(L("con"),L("countname"),1);
	}
}

TakeKB(L("filename")) {
	L("path") = G("$apppath") + "/kb/" + L("filename") + ".kb";
	"kb.txt" << "Taking: " << L("path") << "\n";
	if (take(L("path"))) {
		"kb.txt" << "  Taken successfully: " << L("path") << "\n";
	} else {
		"kb.txt" << "  Taken FAILED: " << L("path") << "\n";		
	}
} 

ChildCount(L("con")) {
	L("count") = 0;
	L("child") = down(L("con"));
	while (L("child")) {
		L("count")++;
		L("child") = next(L("child"));
	}
	return L("count");
}

###############################################
# KBB DISPLAY FUNCTIONS
###############################################

DisplayKB(L("top"),L("full")) {
	if (num(G("$passnum")) < 10) {
		L("file") = "ana00" + str(G("$passnum"));
	}else if (num(G("$passnum")) < 100) {
		L("file") = "ana0" + str(G("$passnum"));
	} else {
		L("file") = "ana0" + str(G("$passnum"));
	}
	L("file") = L("file") + ".kbb";
	L("top con") = findconcept(findroot(),L("top"));
	DisplayKBRecurse(L("file"),L("top con"),0,L("full"));
	L("file") << "\n";
	return L("top con");
}

DisplayKBRecurse(L("file"),L("top"),L("level"),L("full")) {
	if (L("level") == 0) {
		L("file") << conceptname(L("top")) << "\n";
	}
	L("con") = down(L("top"));
	while (L("con")) {
		L("file") << SpacesStr(L("level")+1) << conceptname(L("con"));
		DisplayAttributes(L("file"),L("con"),L("full"));
		L("file") << "\n";
		if (down(L("con"))) {
			L("lev") = 1;
			DisplayKBRecurse(L("file"),L("con"),L("level")+L("lev"),L("full"));
		}

		L("con") = next(L("con"));
	}
}

DisplayAttributes(L("file"),L("con"),L("full")) {
	L("attrs") = findattrs(L("con"));
	if (L("attrs")) L("file") << ": ";
	if (L("full") && L("attrs")) L("file") << "\n";
	L("first attr") = 1;
	
	while (L("attrs")) {
		L("vals") = attrvals(L("attrs"));
		if (!L("full") && !L("first attr")) {
			L("file") << ", ";
		}
		if (L("full")) {
			if (!L("first attr")) L("file") << "\n";
			L("file") << SpacesStr(L("level")+2);
		}
		L("file") << attrname(L("attrs")) << "=[";
		L("first") = 1;
		
		while (L("vals")) {
			if (!L("first"))
				L("file") << ",";
			L("val") = getstrval(L("vals"));
			L("num") = getnumval(L("vals"));
			L("con") = getconval(L("vals"));
			if (L("con")) {
				L("file") << conceptpath(L("con"));
			} else if (!L("full") && strlength(L("val")) > 20) {
				L("shorty") = strpiece(L("val"),0,20);
				L("file") << L("shorty");
				L("file") << "...";
				if (strendswith(L("val"),"\""))
					L("file") << "\"";
			} else if (L("num") > -1) {
				L("file") << str(L("num"));
			} else {
				L("file") << L("val");
			}
			L("first") = 0;
			L("vals") = nextval(L("vals"));
		}
		
		L("file") << "]";
		L("first attr") = 0;
		L("attrs") = nextattr(L("attrs"));
	}
}

# Because NLP++ doesn't allow for empty strings,
# this function can only be called with "num" >= 1
SpacesStr(L("num")) {
    L("n") = 1;
	L("spaces") = "  ";
	while (L("n") < L("num")) {
		L("spaces") = L("spaces") + "  ";
		L("n")++;
	}
	return L("spaces");
}

@@DECL