# UTILITIES ----

## (1) dictionary to get the variables description ----
what_is <- new.env(hash = TRUE, parent = emptyenv(), size = NA)

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


what_is[["scPC1_tec"]] = "quanta tecnologia gli studenti hanno a disposizione
	alta -> maggiore disponibilità"
what_is[["scPC2_tec"]] = "contrasto tra uso della tecnologia ed interesse/dedizione dello studente
	alta -> gli studenti avrebbero anche molta tecnologia a disposizione ma non sembrano interessati/bravi
	bassa -> gli studenti sono molto interessati alla tecnologia malgrado la poca disponibilità"
what_is[["scPC3_tec"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC4_tec"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC1_psi"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC2_psi"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC3_psi"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC4_psi"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC5_psi"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC1_clt"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC2_clt"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC3_clt"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC1_fam"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC1_tch"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC1_sch"]] = "intepretazione ancora da dare/scrivere"
what_is[["scPC2_sch"]] = "intepretazione ancora da dare/scrivere"

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
what_is[["TEACHBEHA"]] = "eacher behaviour hindering learning (WLE)"
what_is[["PERCOMP"]] = "Perception of competitiveness at school (WLE)"
what_is[["PERCOOP"]] = "Perception of cooperation at school (WLE)"
what_is[["ICTSCH"]] = "ICT available at school"
what_is[["RATCMP1"]] = "Number of available computers per student"
what_is[["SCHLTYPE"]] = "School Ownership"
what_is[["STRATIO"]] = "StudenTeacher ratio"
what_is[["SCHSIZE"]] = "School Size (Sum)"
what_is[["CLSIZE"]] = "CLass Size"
what_is[["CREACTIV"]] = "Creative extracurricular activities (Sum)"
what_is[["EDUSHORT"]] = "Shortage of educational material (WLE)"
what_is[["STAFFSHORT"]] = "Shortage of educational staff (WL)"
what_is[["STUBEHA"]] = "Student behaviour hindering learning (WL)"







