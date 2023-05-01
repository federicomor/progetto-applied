<<<<<<< HEAD
setwd("/")

library(GGally)
library(dplyr)
library(MVN)
library(car)

rm(list=ls())

stu=read.csv("pisa-woNA_school_final.csv")

colnames(stu)
summary(stu)

for(i in c(4:44))
{
  x11()
  barplot(stu[,i], main=paste('Histogram of ', colnames(stu)[i], sep=''), xlab=paste('V', i, sep=''))
  lines(900:2800, dnorm(900:2800,mean(stu[,i]),sd(stu[,i])), col='blue', lty=2)
  qqnorm(stu[,i], main=paste('QQplot of ', colnames(stu)[i], sep=''))
  qqline(stu[,i])
  print(shapiro.test(stu[,i])$p)
}
#shapiro test infinitesimali -> no gaussianità per nessuna variabile
#ordine di grandezza tra e-15 ed e-76
#analisi visiva:
#comportamento terribile su code -> outliers
#ictoutside, icthome, ictclass, genderprop sembrano i peggiori



x11()
boxplot(stu[,4:44])
#rimuovere outliers evidenziati dal boxplot
data=stu
for(col in colnames(stu)[4:44]){
  q1=quantile(stu[[col]],probs=0.25)
  q3=quantile(stu[[col]],probs=0.75)
  IQR=(q3-q1)  #range interquartile
  x = stu[[col]] > q3+IQR*1.5 | stu[[col]] < q1-IQR*1.5
  data[[col]][x]=NA
}

sum(is.na(data))  
print(sapply(data,function(x) sum(is.na(x))))
#no colonne con troppi otliers rispetto alle altre
data=na.omit(data)
#restano 2814 osservazioni, circa il 58%

x11()
boxplot(data[,4:44])

for(i in c(4:44))
{
  x11()
  barplot(data[,i], main=paste('Histogram of ', colnames(data)[i], sep=''), xlab=paste('V', i, sep=''))
  lines(900:2800, dnorm(900:2800,mean(data[,i]),sd(data[,i])), col='blue', lty=2)
  qqnorm(data[,i], main=paste('QQplot of ', colnames(data)[i], sep=''))
  qqline(data[,i])
  print(shapiro.test(data[,i])$p)
}
#sensibile miglioramento shapiro ma ancora insufficiente 
#ordine di grandezza ancora tra e-1 ed e-27




#Tentativo di normalizzare con boxcox

#boxcox funziona solo con dati strettamente positivi -> serve traslare dataset 
dati=data[,4:44]
dati=dati+abs(min(dati))+1e-5 #1e-5 epsilon per ottenere disuguaglianza stretta
lambda = powerTransform(dati)    
lambda
BC=data  
for(i in c(1:41)){
  BC[i+3]=bcPower(dati[,i], lambda$lambda[i])   #dataset trasformato
}

for(i in c(4:44))
{
  x11()
  barplot(BC[,i], main=paste('Histogram of ', colnames(BC)[i], sep=''), xlab=paste('V', i, sep=''))
  lines(900:2800, dnorm(900:2800,mean(BC[,i]),sd(BC[,i])), col='blue', lty=2)
  qqnorm(BC[,i], main=paste('QQplot of ', colnames(BC)[i], sep=''))
  qqline(BC[,i])
  print(shapiro.test(BC[,i])$p)
}
#miglioramento ma ancora non sufficiente per accettare ipotesi di gaussianità
#ordine di grandezza tra e-1 ed e-16




=======
setwd("/")

library(GGally)
library(dplyr)
library(MVN)
library(car)

rm(list=ls())

stu=read.csv("pisa-woNA_school_final.csv")

colnames(stu)
summary(stu)

for(i in c(4:44))
{
  x11()
  barplot(stu[,i], main=paste('Histogram of ', colnames(stu)[i], sep=''), xlab=paste('V', i, sep=''))
  lines(900:2800, dnorm(900:2800,mean(stu[,i]),sd(stu[,i])), col='blue', lty=2)
  qqnorm(stu[,i], main=paste('QQplot of ', colnames(stu)[i], sep=''))
  qqline(stu[,i])
  print(shapiro.test(stu[,i])$p)
}
#shapiro test infinitesimali -> no gaussianità per nessuna variabile
#ordine di grandezza tra e-15 ed e-76
#analisi visiva:
#comportamento terribile su code -> outliers
#ictoutside, icthome, ictclass, genderprop sembrano i peggiori



x11()
boxplot(stu[,4:44])
#rimuovere outliers evidenziati dal boxplot
data=stu
for(col in colnames(stu)[4:44]){
  q1=quantile(stu[[col]],probs=0.25)
  q3=quantile(stu[[col]],probs=0.75)
  IQR=(q3-q1)  #range interquartile
  x = stu[[col]] > q3+IQR*1.5 | stu[[col]] < q1-IQR*1.5
  data[[col]][x]=NA
}

sum(is.na(data))  
print(sapply(data,function(x) sum(is.na(x))))
#no colonne con troppi otliers rispetto alle altre
data=na.omit(data)
#restano 2814 osservazioni, circa il 58%

x11()
boxplot(data[,4:44])

for(i in c(4:44))
{
  x11()
  barplot(data[,i], main=paste('Histogram of ', colnames(data)[i], sep=''), xlab=paste('V', i, sep=''))
  lines(900:2800, dnorm(900:2800,mean(data[,i]),sd(data[,i])), col='blue', lty=2)
  qqnorm(data[,i], main=paste('QQplot of ', colnames(data)[i], sep=''))
  qqline(data[,i])
  print(shapiro.test(data[,i])$p)
}
#sensibile miglioramento shapiro ma ancora insufficiente 
#ordine di grandezza ancora tra e-1 ed e-27




#Tentativo di normalizzare con boxcox

#boxcox funziona solo con dati strettamente positivi -> serve traslare dataset 
dati=data[,4:44]
dati=dati+abs(min(dati))+1e-5 #1e-5 epsilon per ottenere disuguaglianza stretta
lambda = powerTransform(dati)    
lambda
BC=data  
for(i in c(1:41)){
  BC[i+3]=bcPower(dati[,i], lambda$lambda[i])   #dataset trasformato
}

for(i in c(4:44))
{
  x11()
  barplot(BC[,i], main=paste('Histogram of ', colnames(BC)[i], sep=''), xlab=paste('V', i, sep=''))
  lines(900:2800, dnorm(900:2800,mean(BC[,i]),sd(BC[,i])), col='blue', lty=2)
  qqnorm(BC[,i], main=paste('QQplot of ', colnames(BC)[i], sep=''))
  qqline(BC[,i])
  print(shapiro.test(BC[,i])$p)
}
#miglioramento ma ancora non sufficiente per accettare ipotesi di gaussianità
#ordine di grandezza tra e-1 ed e-16




>>>>>>> 8938121f3b89dc7ce167fcc4cff836d5c215c6ae
