lmerf= function (y, cov, group, xnam, znam=NULL, bizero=NULL, itmax=100, toll=0.03) {
#argomenti: 
#-y=vettore con le risposte
#-cov=data frame con le covariate di ogni unit? statistica
#-group=vettore factor che, per ogni unit? statistica, dice il gruppo a cui appartiene
#-xnam=vettore coi nomi delle covariate da usare nella random forest
#-znam=vettore coi nomi delle covariate da usare nei random effects
#-bizero=matrice in cui ogni colonna contiene i coefficienti dei random effects
#	   il primo valore di ogni colonna ? l'intercept, gli altri le covariate znam

#assumo che group e bizero siano coerenti, cio? b[,i] corrisponda a levels(group)[i]


	######################################
	####	STEP 1: Inizializzazione  ######
	######################################

	N <- length(y) #numero di osservazioni
	n=length(levels(group)) #numero di gruppi
	q <- length(znam)+1	# numero di covariate + random intercept
	Zi=NULL
	z.not.null=!(is.null(znam)) #controllo se ci sono covariate incluse nei random effects
	if (z.not.null) Zi=cov[znam] #covariate dei random effects
	Zi.int=cbind(rep(1,N),Zi)
	
	#Inizializzo (se ? NULL) bi a 0
	if( is.null(bizero) ){
		bi <- NULL
		for(i in 1:n) bi=cbind(bi,rep(0,q))
	}	
	if( !is.null(bizero) ) bi=bizero
	lev=levels(group) #nomi dei gruppi
	bi=data.frame(bi)
	names(bi)=lev
	all.bi=list()  #i b_i di ogni iterazione
	all.bi[[1]]=bi

#se xnam ? null assumo che tutte le variabili di cov siano da usare
	if(is.null(xnam)) xnam=names(cov)

#group deve essere un factor, altrimenti da errore
	if(!is.factor(group)) stop('Argomento "group" deve essere un factor')

	if(z.not.null) {
		lmer.formula=as.formula(paste("y ~ ( 1+", paste(znam, collapse= "+"), " | group )"))
	}
	if(!z.not.null){lmer.formula=as.formula(paste("y ~ ( 1 | group)"))}
	forest.formula=as.formula(paste("target ~ ", paste(xnam, collapse= "+")))
	
	
	####################################################
	####	STEP 2-3: Stima iterativa del modello  #######
	####################################################
	
	library(randomForest)
	library(lme4)
	it=1
	converged=FALSE
	while(!converged && it<itmax) {

		#random forest
		target=rep(0,N) #target=y-Z%*%b
		for (i in 1:N) {
			b.temp=as.matrix(bi[group[i]], nrow=q, ncol=1)
			z.temp=as.matrix(Zi.int[i,], nrow=1, ncol=q)
			target[i]= y[i] - z.temp%*%b.temp
		}
		forest.data=cbind(target, cov[xnam])
		forest=randomForest(forest.formula, forest.data, mtry=5, ntree = 200) 
		f.x_ij=forest$predicted

		#glm con mixed effects
		lmer.data=data.frame(y,group)
		if(z.not.null) lmer.data=cbind(lmer.data, Zi)
		lmer.data=data.frame(lmer.data) #altrimenti lmer non funziona
		lmer.fit= lmer(lmer.formula, lmer.data, offset=f.x_ij)

		#voglio mantenere l'ordine degli elementi dei b_i
		select=c("(Intercept)",znam) #tutti i b_i da estrarre
		lmer.bi=ranef(lmer.fit)$group[select]
		
		#convergenza dei b_i
		bi.old=bi
		bi=data.frame(t(lmer.bi))
		names(bi)=lev
		diff.t=abs(bi.old-bi)
		n.diff=max(diff.t) #uso la norma infinito(max)
		ind=which(diff.t==n.diff, arr.ind=T)
		n.old=abs(bi.old[ind])
		converged= n.diff/n.old <toll
		it=it+1
		all.bi[[it]]=bi
	}

	###############################################
	####	STEP 4: Preparazione output  ############
	###############################################

	#se non ho convergenza do un messaggio di errore
	if(!converged) {
		warning('Numero massimo di iterazioni superato, non si ? arrivati a convergenza')
	}

	result=list(lmer.fit,forest,bi,it-1,converged,all.bi,xnam,znam)
	names(result)=c('lmer.model', 'forest.model', 'rand.coef', 'n.iteration',
			    'converged','all.rand.coef','forest.var','random.eff.var')
	class(result)='lmerf'
	result
}



summary.lmerf=function(gm) {
	print('Mixed effects model') #summary del mixed effects model
	print(summary(gm$lmer.model)) 
	str=ifelse(gm$converged, 'Converged', 'Did not converge')
	print(paste(str , 'after', gm$n.iteration, 'iterations')) #dice se c'? convergenza
}



fitted.lmerf=function(gm) {
#i fitted values corretti sono gi? quelli della funzione glmer, poich?
#ho incorporato i fitted values della random forest nel modello
	fitted(gm$lmer.model)
}



predict.lmerf=function(gm, newdata, group, predict.all=FALSE, re.form=NULL, newparam=NULL, 
				terms=NULL, allow.new.levels=TRUE, na.action=na.pass,
				random.only=FALSE) {

#chiamo semplicemente i metodi predict di gmerf e randomForest
	forest.data=newdata[gm$forest.var]
	lmer.data=cbind(newdata[gm$random.eff.var],group)
	p1=predict(gm$lmer.model,newdata=lmer.data,newparam=newparam,re.form=re.form,
			random.only=random.only, type='link', na.action=na.action,
			allow.new.levels=allow.new.levels)			
	p2=predict(gm$forest.model,forest.data,predict.all=predict.all)
	ans=p1+p2 
}


