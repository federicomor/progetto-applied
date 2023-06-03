# UTILITIES ----

## (1) dictionary to get the variables description ----
what_is <- new.env(hash = TRUE, parent = emptyenv(), size = NA)

fun_colori = function(len=2, seed=33){
	hcols_ = hcl.pals()
	col.ramp_ = hcl.colors(len,palette=hcols_[seed%%115+1])
	return(col.ramp_)
}
colori_fun = colorami = colora = fun_colori


## for the scores dataset
## 
## better usage: cat(what_is[["scPC1_tec"]])
## così mostra anche gli "a capo"
## 
## o con la nuova funzione
spiegami = function(colonna){
	cat(what_is[[colonna]])
}
## esempio spiegami("scPC1_tec")
## aggiungere pure altri nomi nel caso uno dimenticasse "spiegami"
dimmi = racconta = raccontami = cose = cos_e = interpreta = interpretami = spiega = spiegami
## quindi ora dimmi(ecc) e le altre funzionano allo stesso modo

## scores dataset
what_is[["col1_tec"]] = "Frequenza di utilizzo di strumenti informatici (lezioni e non), sfruttabilità"
what_is[["col2_tec"]] = "Quantità di materiale informatico (casa + scuola), disponibilità"
what_is[["col3_tec"]] = "Passione nell'informatica (interesse + competenza + utilizzo generale ecc)"
what_is[["col4_tec"]] = "Utilizzo motivato o forzato (più è negativa più si usa informatica fuori da scuola, 
per lavoro o giochi, contro un impatto positivo dell'interesse"

what_is[["col1_psi"]] = "Impeto, energia dello studente nel vivere la scuola
(fin troppo poetica, è una somma della sua attitudine, tendenza alla competitività e resilienza)"
what_is[["col2_psi"]] = "Modo in cui vive la vita scolastica.
Bassa se lui è forzato ad essere più resiliente e combattivo, alta se può essere più pacifico, easy."
what_is[["col3_psi"]] = "Somma di contributi positivi
(supporto dei prof, genitori, compagni come aiuto ma anche stimolo alla competizione)"
what_is[["col4_psi"]] = "Supporto interno o esterno. Alta se supporto maggiore da parte dei genitori o compagni.
Bassa se più supportato invece dai prof."
what_is[["col5_psi"]] = "Tendenza alla singolarità, indipendenza vs lavoro di squadra.
Alta se maggiore cooperazione, bassa se maggiore competizione"
what_is[["col6_psi"]] = "target, somma contributi positivi vs negativi. Alta se si sta meglio (ci ho cambiato segno)"
what_is[["col7_psi"]] = "quanto lo studente si sente accolto, ascoltato. Alta se alta belong, bassa se alte swbp e beingbbullied.
Sembra un controsenso ma magari un bambino si mostra che sta bene perché non crede che gli altri lo possano/vogliano accogliere,
ascoltare, risolvere le sue problematiche. Come i gatti che non mostrano quando stanno male, per non farsi vedere deboli"

what_is[["col1_clt"]] = "quanto il clima culturale a casa è favorevole (gioia nella lettura, disponibilità di cultura, ecc), quindi tipo supporto culturale"
what_is[["col2_clt"]] = "contrasto tra gioia di lettura (+) e risorse educative (-), quindi amore per la cultura contro la sua effettiva disponibilità.
Alta se uno è interessato alla cultura ma in casa non ha molte risorse.
Bassa se uno ha molte risorse ma non è interessato."
what_is[["col3_clt"]] = "tempo di studio totale (language + math)"

what_is[["col1_fam"]] = "indice di benessere sociale, economico, culturale anche della famiglia. 
Più è alto più il clima, almeno su quegli aspetti, è ottimo, favorevole."

what_is[["col1_tch"]] = "contributo positivo del prof (somma di tante cose belle)"
what_is[["col2_tch"]] = "contrasto tra il supporto del prof e la passione trasmessa percepita.
Quindi in breve magari quanto il prof compensa le sua carenze, compensazione.
Più è negativa più il prof dà supporto. Pi è positiva pi riesce a stimolare gli studenti, a scapito magari di inesattezze sue."
what_is[["col3_tch"]] = "qualifica professori. 
Positiva se la maggioranza in quella ha scuola ha la triennale. Negativa se la maggioranza ecc ha la magistrale"
what_is[["col4_tch"]] = "agio nel proseguire le attività didattiche. 
Era la somma di quanto i prof e gli studenti ostacolano le lezioni. Ma più è alta più tutto va bene o più tutto è ostacolato?"

what_is[["col1_sch"]] = "Dimension of the scholastic ambient (school + class size + prof ratio)"
what_is[["col2_sch"]] = "Contrasto tra class size e student ratio. 
Positiva se ci sono molti studenti (e precisamente molti studenti per prof). 
Negativa se proprio ci sono pochi pochi studenti"
what_is[["col3_sch"]] = "Mancanza di materiale e di personale scolsatico insieme. Quindi mala-organizzazione tipo"
what_is[["col4_sch"]] = "La colonna originale creactive, Creative extra-curricular activities (Sum)"


## insert into hash table
what_is[["MMINS"]] = "Learning time (minutes per week) - <Mathematics>" 
what_is[["LMINS"]] = "Learning time (minutes per week) - <test language>" 
what_is[["SMINS"]] = "Learning time (minutes per week) - <science>" 
what_is[["TMINS"]] = "Learning time (minutes per week) - in total" 
what_is[["FCFMLRTY"]] = "Familiarity with concepts of finance (Sum)" 
what_is[["SCCHANGE"]] = "Number of school changes" 
what_is[["CHANGE"]] = "Number of changes in educational biography (Sum)" 
what_is[["STUBMI"]] = "Body mass index of student" 
what_is[["ESCS"]] = "Index of economic social and cultural status" 
what_is[["UNDREM"]] = "Meta-cognition: understanding and remembering" 
what_is[["METASUM"]] = "Meta-cognition: summarising" 
what_is[["METASPAM"]] = "Meta-cognition: assess credibility" 
what_is[["ICTHOME"]] = "ICT available at home" 
what_is[["ICTSCH"]] = "ICT available at school" 
what_is[["HOMEPOS"]] = "Home possessions (WLE)" 
what_is[["CULTPOSS"]] = "Cultural possessions at home (WLE)" 
what_is[["HEDRES"]] = "Home educational resources (WLE)" 
what_is[["WEALTH"]] = "Family wealth (WLE)" 
what_is[["ICTRES"]] = "ICT resources (WLE)" 
what_is[["DISCLIMA"]] = "Disciplinary climate in test language lessons (WLE)" 
what_is[["TEACHSUP"]] = "Teacher support in test language lessons (WLE)" 
what_is[["DIRINS"]] = "Teacher-directed instruction (WLE)" 
what_is[["PERFEED"]] = "Perceived feedback (WLE)" 
what_is[["EMOSUPS"]] = "Parents' emotional support perceived by student (WLE)" 
what_is[["STIMREAD"]] = "Teacher's stimulation of reading engagement perceived by student (WLE)" 
what_is[["ADAPTIVITY"]] = "Adaptation of instruction (WLE)" 
what_is[["TEACHINT"]] = "Perceived teacher's interest (WLE)" 
what_is[["JOYREAD"]] = "Joy/Like reading (WLE)" 
what_is[["SCREADCOMP"]] = "Self-concept of reading: Perception of competence (WLE)" 
what_is[["SCREADDIFF"]] = "Self-concept of reading: Perception of difficulty (WLE)" 
what_is[["PISADIFF"]] = "Perception of difficulty of the PISA test (WLE)" 
what_is[["PERCOMP"]] = "Perception of competitiveness at school (WLE)" 
what_is[["PERCOOP"]] = "Perception of cooperation at school (WLE)" 
what_is[["ATTLNACT"]] = "Attitude towards school: learning activities (WLE)" 
what_is[["COMPETE"]] = "Competitiveness (WLE)" 
what_is[["WORKMAST"]] = "Work mastery (WLE)" 
what_is[["GFOFAIL"]] = "General fear of failure (WLE)" 
what_is[["EUDMO"]] = "Eudaemonia: meaning in life (WLE)" 
what_is[["SWBP"]] = "Subjective well-being: Positive affect (WLE)" 
what_is[["RESILIENCE"]] = "Resilience (WLE)" 
what_is[["MASTGOAL"]] = "Mastery goal orientation (WLE)" 
what_is[["GCSELFEFF"]] = "Self-efficacy regarding global issues (WLE)" 
what_is[["GCAWARE"]] = "Student's awareness of global issues (WLE)" 
what_is[["ATTIMM"]] = "Student's attitudes towards immigrants (WLE)" 
what_is[["INTCULT"]] = "Student's interest in learning about other cultures (WLE)" 
what_is[["PERSPECT"]] = "Perspective-taking (WLE)" 
what_is[["COGFLEX"]] = "Cognitive flexibility/adaptability (WLE)" 
what_is[["RESPECT"]] = "Respect for people from other cultures (WLE)" 
what_is[["AWACOM"]] = "Awareness of intercultural communication (WLE)" 
what_is[["GLOBMIND"]] = "Global-mindedness (WLE)" 
what_is[["DISCRIM"]] = "Discriminating school climate (WLE)" 
what_is[["BELONG"]] = "Subjective well-being: Sense of belonging to school (WLE)" 
what_is[["BEINGBULLIED"]] = "Student's experience of being bullied (WLE)" 
what_is[["ENTUSE"]] = "ICT use outside of school (leisure) (WLE)" 
what_is[["HOMESCH"]] = "Use of ICT outside of school (for school work activities) (WLE)" 
what_is[["USESCH"]] = "Use of ICT at school in general (WLE)" 
what_is[["INTICT"]] = "Interest in ICT (WLE)" 
what_is[["COMPICT"]] = "Perceived ICT competence (WLE)" 
what_is[["AUTICT"]] = "Perceived autonomy related to ICT use (WLE)" 
what_is[["SOIAICT"]] = "ICT as a topic in social interaction (WLE)" 
what_is[["ICTCLASS"]] = "Subject-related ICT use during lessons (WLE)" 
what_is[["ICTOUTSIDE"]] = "Subject-related ICT use outside of lessons (WLE)" 
what_is[["INFOCAR"]] = "Information about careers (WLE)" 
what_is[["INFOJOB1"]] = "Information about the labour market provided by the school (WLE)" 
what_is[["INFOJOB2"]] = "Information about the labour market provided outside of school (WLE)" 
what_is[["FLCONFIN"]] = "Confidence about financial matters (WLE)" 
what_is[["FLCONICT"]] = "Confidence about financial matters using digital devices (WLE)" 
what_is[["FLSCHOOL"]] = "Financial education in school lessons (WLE)" 
what_is[["FLFAMILY"]] = "Parental involvement in matters of Financial Literacy (WLE)" 
what_is[["CURSUPP"]] = "Current parental support for learning at home (WLE)" 
what_is[["EMOSUPP"]] = "Parents' emotional support (WLE)" 
what_is[["PQSCHOOL"]] = "Parents' perceived school quality (WLE)" 
what_is[["PASCHPOL"]] = "School policies for parental involvement (WLE)" 
what_is[["PRESUPP"]] = "Previous parental support for learning at home (WLE)" 
what_is[["JOYREADP"]] = "Parents enjoyment of reading (WLE)" 
what_is[["ATTIMMP"]] = "Parents' attitudes towards immigrants (WLE)" 
what_is[["INTCULTP"]] = "Parents' interest in learning about other cultures (WLE)" 
what_is[["GCAWAREP"]] = "Parents' awareness of global issues (WLE)" 
what_is[["BODYIMA"]] = "Body image (WLE)" 
what_is[["SOCONPA"]] = "Social Connections: Parents (WLE)"
what_is[["BFMJ2"]] = "ISEI of father"
what_is[["BMMJ1"]] = "ISEI of mother"
what_is[["HISCED"]] = "Highest Education of parents"
what_is[["HISEI"]] = "Index highest parental occupational status"
what_is[["RATCMP1"]] = "Number of available computers per student at modal grade"
what_is[["TEACHINT"]] = "Perceived teacher's interest (WLE)"
what_is[["TEACHSUP"]] = "Teacher support in test language lessons (WLE)"
what_is[["STIMREAD"]] = "Teacher's stimulation of reading engagement perceived by student WLE"
what_is[["PROAT5AB"]] = "ndex proportion of all teachers ISCED LEVEL 5A Bachelor"
what_is[["PROAT5AM"]] = "ndex proportion of all teachers ISCED LEVEL 5A Master"
what_is[["PROAT6"]] = "ndex proportion of all teachers ISCED LEVEL 6"
what_is[["TOTAT"]] = "otal number of all teachers at school"
what_is[["TEACHBEHA"]] = "Teacher behaviour hindering learning (WLE)"
what_is[["PERCOMP"]] = "Perception of competitiveness at school (WLE)"
what_is[["PERCOOP"]] = "Perception of cooperation at school (WLE)"
what_is[["ICTSCH"]] = "ICT available at school"
what_is[["RATCMP1"]] = "Number of available computers per student at modal grade"
what_is[["SCHLTYPE"]] = "School Ownership"
what_is[["STRATIO"]] = "Student-Teacher ratio"
what_is[["SCHSIZE"]] = "School Size (Sum)"
what_is[["CLSIZE"]] = "Class Size"
what_is[["CREACTIV"]] = "Creative extra-curricular activities (Sum)"
what_is[["EDUSHORT"]] = "Shortage of educational material (WLE)"
what_is[["STAFFSHORT"]] = "Shortage of educational staff (WLE)"
what_is[["STUBEHA"]] = "Student behaviour hindering learning (WLE)"







