# Note

## Poster
Tenerlo diviso in sezioni, minimale, poco tecnico, con grafici abbastanza ma soprattutto facilmente interpretabili (dotplot, ecc). Grafici forse rifatti con ggplot.

## Dim Redux 
Scegliere quali variabili tenere e come ridurle. Intanto in modo che sia poco forzato, e poi al massimo si riduce dopo quando avremo il modello.

## Variabili
Provare a considerare categoriche *col4_sch* e il *tipo della scuola* (privata/pubblica; forse presente nel dataset school). Sia come intercetta nei modelli lineari sia come altro modo di fare clustering.

Aggiungere PV1Math e PV1Read da usare insieme alle altre variabili.
E anche al tipo di scuola (da ricavare in qualche modo, tipo dal dataset iniziale).
SC013Q01TA	Is your school a public or a private school?

## LMM
Fare magari due modelli, uno con le variabili su cui si può avere controllo (lui da usare per il gioco quindi) e l'altro con le variabili fuori controllo.

y ~ (1 + tec|state) + (1 + psi|state) + ecc

## Domande Masci
- Come valutare la qualità di un LMM? in confronto [a un altro LMM o, lo sappiam già questo] ad un classico LM. O forse di per sè, tipo un suo indice R^2 o simile.
- Chiedere un parere sull'idea di Marco nuova per la PCA/FA.

## Flusso di Lavoro
Usare manova (come indagine inziale per il lmm, o finale per valutare i clustering).
Random Forest.
TANTI! mixed models (e confrontarli con anova).
Abbellire i grafici, o crearne di nuovi, o comunque salvare in qualche modo quelli belli/interessanti da mettere nel poster.
