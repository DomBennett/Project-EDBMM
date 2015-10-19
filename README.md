# Evolutionary Distinctness Biased Markov Model (EDBMM)

An R pipeline for exploring how an evolutionary distinctness bias in a
tree-growth Markov model affects tree shape in order to test
the reality of the living fossil.

The pipeline uses a Markov-Model to grow trees with extinction and speciation
rates determined by a tip's evolutionary distinctness.

![EDBMM](https://raw.githubusercontent.com/DomBennett/Project-EDBMM/master/other/EDBMM.png "Evolutionary Distinctness Biased Markov Model")

Data and results files are not provided in this repository, only the code is.
The final set of files and folders used for publication can be found [here]().
 (*Publication pending*)

**System requirements**

Run the `install_deps.R` script to install all dependent packages automatically.

* OS
  + UNIX (but readily modifiable for Windows)
* R version
  + 3+
* R packages (version used)
  + `plyr` (1.8.1)
  + `ape` (3.2)
  + `geiger` (2.0.3)
  + `apTreeshape` (1.4.5)
  + `ggplot2` (1.0.0)
  + `MoreTreeTools` (0.0.1)
  + `outliers` (0.14)
  + `doMC` (1.3.3, not for Windows)
  + `foreach` (1.4.2)
  + `test_that` (0.9.1, optional)
  
Please note, [MoreTreeTools](https://github.com/DomBennett/MoreTreeTools) is in development and can only be installed via GitHub.

**Directory structure**

```
-- data/
---- raw_trees/
------ literature/
-------- [manually added]
------ treebase/
---- parsed_trees/
---- treestats/
-- parameters/
---- [all analysis parameters]
-- stages/
---- [all stage .R scripts]
-- tools/
---- [all tool .R scripts]
-- results/
----- [all folders named by analysis as specified in run.R]
-- other/
-- sanity_checks/
```

**Pipeline**

The pipeline works by calling the pipeline scripts `setup.R` and `run.R`. These scripts call
stage scripts which can be found in [`/stages`](https://github.com/DomBennett/Project-EDBMM/tree/master/stages).
The stages scripts depend on custom functions found in the [`/tools`](https://github.com/DomBennett/Project-EDBMM/tree/master/tools) folder.

![flow-diagram](https://raw.githubusercontent.com/DomBennett/Project-EDBMM/master/other/flow_diagram.png "Flow diagram")

**setup.R**

This phase of the pipeline sources and calculates statistics from empirical
trees:

1. Download trees from TreeBase
2. Parse trees (make ultramteric using different methods)
3. Calculate tree shape statistics
4. Determine the taxonomic identities of downloaded trees

**run.R**

This phase models trees for determining how model parameters affect tree shape:

1. Read in parameters from [`parameters/`](https://github.com/DomBennett/Project-EDBMM/tree/master/parameters)
2. Model trees according to parameters in `run.R`
3. Calculate tree shape statistics

**Analysis**

The final stage script is user interactive. All plots and analysis presented in the publication
are generated with this script.

**Testing**

Run `test.R` to make sure core functions are working.

**Author**

Dom Bennett
