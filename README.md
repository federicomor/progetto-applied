# Final Project for the course of Applied Statistics

## Introduction

## Brief description of our analysis

This project aims to analyze the well-being of students across various European countries by analyzing a range of several factors measured by OECD PISA questionnaires. The two main issues that we faced are the following:

-   **Defining a proper score to measure the well-being of the students.** Indeed, the dataset contains various psychological measurements (such as scores for the students' degree of competitiviness, sense of belonging to the school, feeling of being bullied, ecc.), but no straight-forward definition of well-being is given. To define such score we relied on a rotated principal components analysis (rPCA) applied to groups of variables. The procedure we followed is described at `src/dimensionality-reduction`

-   **Deal with the hierarchical structure of the data.** Our dataset has a two-level hierarchical structure where students are nested in schools, which are nested in countries. We deal with this structure by:

    -   *Discarding the lower level of the hierarchy* (student level) by grouping by schools and taking the average over the students in the schools for each variable. Doing so we lost a lot of information at student level, but our choice was justified by the fact of comparing as many countries (i.e. school systems) as possible and working with so many students would have been unfeasible.

    -   *Accounting for the grouping induced by countries using proper mixed effect models* to model the well-being scores that we computed. The models we used are Linear Mixed Effects Models (LMM) and Mixed Effects Random Forests (MERF). Details can be found at \`src/linear-mixed-models`and`\`src/random-forest\`

## Structure

-   `src` contains Rmarkdown notebooks where the analysis is actually performed
-   `data` contains the datasets used in the analysis
-   `showcase` contains the slides for the work-in-progress presentation and the final poster
-   `game` contains the source code written in julia for the telegram bot used to show some results in the form of a game during the poster session
-   `docs` contains some materials used as a reference in the analysis
-   `renv` and `renv.lock` are used by the renv package to ease code reproducibility, listing and loaading all the packages used in the code

## Partecipants

-   Ettore Modina

-   Giulia Mezzadri

-   Federico Angelo Mor

-   Beatrice Re

-   Marco Galliani

## References

-   James, G., Witten, D., Hastie, T., & Tibshirani, R. (2021). An introduction to statistical learning (2nd ed.) [PDF]. Springer. and the related online course and materials available [here](https://www.statlearning.com/resources-second-edition).
-   
