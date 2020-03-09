# Using latent class analysis to identify symptom subtypes of obstructive sleep apnea

This repository describes an end-to-end pipeline for using latent class analysis (LCA) for identification of subtypes of obstructive sleep apnea (OSA) based on specific symptom questions.

Please refer to the following publications for more details on the application:

- Ye L, Pien GW, Ratcliffe SJ, Bjornsdottir E, Arnardottir ES, Pack AI, et al. The different clinical faces of obstructive sleep apnoea: a cluster analysis. Eur Respir J. 2014;44(6):1600-7.
- Keenan BT, Kim J, Singh B, Bittencourt L, Chen NH, Cistulli PA, et al. Recognizable clinical subtypes of obstructive sleep apnea across international sleep centers: a cluster analysis. Sleep. 2018;41(3).
- Kim J, Keenan BT, Lim DC, Lee SK, Pack AI, Shin C. Symptom-based subgroups of Koreans with obstructive sleep apnea. J Clin Sleep Med. 2018;14(3):437-43.
- Mazzotti DR, Keenan BT, Lim DC, Gottlieb DJ, Kim J, Pack AI. Symptom subtypes of obstructive sleep apnea predict incidence of cardiovascular outcomes. Am J Respir Crit Care Med. 2019;200(4):493-506.

### Quick start with example

1. Clone or download this repository in your working directory
2. Set directory to the newly created folder: `setwd("OSA_Symptom_Subtypes_LCA_Pipeline/")`
3. Run `source("osa_subtypes.R")`
4. Run an example with sample data

```
osa_subtypes(input_f = "example_data/sample_data.csv", project_name = "SampleProject")
```

### Using your own data

To use the function `osa_subtypes()`, you will need a `.csv` file containing the following elements:
- First column: SampleID ()
- Second to last column: Variables corresponding to symptoms. These variables should be numerically coded and correspond to categories of specific symptoms.

Save the `.csv` file in your working directory and run (change file name and project name accordingly:

```
osa_subtypes(input_f = "my_data.csv", project_name = "MyProject", k=1:5)
```

This will run LCA using 1 to 5 cluster solutions, generate a plot with Bayesian Information Criterion of each solution, and a heatmap with the proportion of each symptom category for each solution.


