# Note

## Poster
Tenerlo diviso in sezioni, minimale, poco tecnico, con grafici abbastanza ma soprattutto facilmente interpretabili (dotplot, ecc). Grafici forse rifatti con ggplot.

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
