#  Automating Deferred Processing using Triggers
>![pach_logo](../images/pach_logo.svg) The *trigger* functionality is available in version **1.12 and higher**.


This example extends the original [housing prices](../../housing-prices) example,
showing how to retrain the model automatically
when a particular condition is met,
using **triggers**.

>![pach_logo](../images/pach_logo.svg) As a reminder:
>
>   [Deferring processing](https://docs.pachyderm.com/latest/concepts/advanced-concepts/deferred_processing/) is a technique 
for **controlling when data is processed**
by Pachyderm, allowing you to commit data 
more often than it is processed. 
You can upload data to a staging branch and 
then submit accumulated changes **in one batch** 
by re-pointing the HEAD of your master branch 
to a commit in the staging branch.

>[Triggers](https://docs.pachyderm.com/latest/concepts/advanced-concepts/deferred_processing#automate-deferred-processing-with-branch-triggers) are **a tool
for automating deferred processing**.
You may automatically move a branch to a new commit
when a set of conditions is reached based on
a combination of time, size, number of commits.

Triggers can be created two ways:

 - **A**. _By creating the branch separately:_ `pachctl create branch <my_repo_name>@master --trigger <my_staging_branch_name> --trigger-size <1MB>`

    * the `--trigger` flag specifying the staging branch. 
    * `--trigger-size` the condition to meet to update the HEAD of master. *(see documentation for more options)*

   To use this triggger for deferred processing, 
   a pipeline must subscribe to the branch you create here. 
   Data to be processed is committed to the branch specified in the `--trigger` argument.

 - **B**. _In a pipeline specification:_ Adding a `trigger` attribute and parameters
   to a PFS input 
   in the pipeline's specification.

  Pachyderm will create the trigger and a branch
   for the pipeline to subscribe to,
   using the naming convention `<pipeline-name>-trigger-n`.


We will first showcase the creation of the trigger on the branch, then reproduce the same scenario by embedding the trigger in the pipeline specification's file.
## 1. Getting ready
***Key concepts***
- Familiarize yourself with [append file processing strategy](https://docs.pachyderm.com/latest/concepts/data-concepts/file/#file-processing-strategies), understand appending vs overwrite.
- [Deferred processing](https://docs.pachyderm.com/latest/concepts/advanced-concepts/deferred_processing/#automate-deferred-processing-with-branch-triggers), especially its automation with triggers.

You might also want to brush up your knowledge on [commit](https://docs.pachyderm.com/latest/concepts/data-concepts/commit/), [branch](https://docs.pachyderm.com/latest/concepts/data-concepts/branch/), and [provenance](https://docs.pachyderm.com/latest/concepts/data-concepts/provenance/). 

***Pre-requisite***
- Work through the [housing prices](../../housing-prices) example.
- A workspace on [Pachyderm Hub](https://docs.pachyderm.com/latest/pachhub/pachhub_getting_started/) (recommended) or Pachyderm running [locally](https://docs.pachyderm.com/latest/getting_started/local_installation/).
- [pachctl command-line ](https://docs.pachyderm.com/latest/getting_started/local_installation/#install-pachctl) installed, and your context created (i.e., you are logged in)

***Getting started***
- Clone this repo.
- Make sure Pachyderm is running. You should be able to connect to your Pachyderm cluster via the `pachctl` CLI. 
Run a quick:
```shell
$ pachctl version

COMPONENT           VERSION
pachctl             1.12.0
pachd               1.12.0
```
Ideally, have your pachctl and pachd versions match. At a minimum, you should always use the same major & minor versions of your pachctl and pachd. 

## 2. Using create branch to add the trigger

Every step in this example is available
in the file [create-branch-based-script.sh](./create-branch-based-script.sh)
in this repo.

***Step 1*** - Prepare your repository and pipeline:

   If you worked through the house prices example, 
   delete the repo and pipeline
   so this example starts fresh.
   
```shell
   $ pachctl delete pipeline regression
   $ pachctl delete repo housing_data
```
   
Create the housing_data repo.
   
``` shell
   $ pachctl create repo housing_data
```
   
and create the pipeline `regression`.

```shell
   $ pachctl create pipeline -f ../../housing-prices/regression.json
```
   
***Step 2*** - This is where we create the trigger:

>![pach_logo](../images/pach_logo.svg) Note that the `staging` branch doesn't need to be created, yet.

   
```shell
   $ pachctl create branch housing_data@master --trigger staging --trigger-size 3KB
   $ pachctl list branch housing_data

   BRANCH  HEAD  TRIGGER
   master  -     staging on Size(3KB) 
```
   
Inspect the `master` branch to see details on the trigger.
   
```shell
   $ pachctl inspect branch housing_data@master

   Name: housing_data@master
   Trigger: staging on Size(3KB) 
```

***Step 3*** - Let's start by putting less data in the `staging` branch than our trigger limit of 3KB:

```shell
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-aa.csv

   housing-simplified-aa.csv: 2.49 KiB / 2.49 KiB        [==============================================================================================] 100.00% ? p/s 0s
```

Note that the branch move has not been triggered.
   
```shell
   $ pachctl list branch housing_data 

   BRANCH  HEAD                             TRIGGER
   staging 3199d1d6a6c0499da198932fcb9c3bad -
   master  -                                staging on Size(3KB)
```
No job was triggered.
```shell
   $ pachctl list job

   ID PIPELINE STARTED DURATION RESTART PROGRESS DL UL STATE
```
Our .csv file was committed to the `staging` branch. 
```shell
   $ pachctl list file housing_data@staging

   NAME                    TYPE SIZE
   /housing-simplified.csv file 2.459KiB
```
And, our branch `master` has not received any commit yet.
```shell
   $ pachctl list file housing_data@master

   the branch "master" has no head (create one with 'start commit')
```

***Step 4*** - We will now add some more data to fire the trigger: 

```shell
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ab.csv

   housing-simplified-ab.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
```
>![pach_logo](../images/pach_logo.svg)   We **appended** the additional data to the original CSV file.

Check the branches and jobs again.
   Note that the branch pointer got moved 
   
```shell
   $ pachctl list branch housing_data

   BRANCH  HEAD                             TRIGGER              
   staging d15eadb6c277406b836c435fd40c07af -                    
   master  d15eadb6c277406b836c435fd40c07af staging on Size(3KB)
```
... and a job triggered.
```shell
   $ pachctl list job

   ID                               PIPELINE   STARTED       DURATION   RESTART PROGRESS  DL       UL       STATE   
   5808786945414be8aa7d8dd2add7cbef regression 2 seconds ago -          0       1 + 0 / 1 4.946KiB 1.754MiB success
   ```

   Next, we will add a commit
   and confirm that the branch doesn't move
   and a job doesn't get triggered,
   because we haven't added 3KB more data.
   
```shell
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ac.csv

   housing-simplified-ac.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
```
   Note that two branches have different head commits ...
```shell
   $ pachctl list branch housing_data

   BRANCH  HEAD                             TRIGGER              
   staging 61a636555ea74871941c92e429f808cf -                    
   master  d15eadb6c277406b836c435fd40c07af staging on Size(3KB)
```
... and the original job hasn't been joined by another.
```shell 
   $ pachctl list job

   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE   
   5808786945414be8aa7d8dd2add7cbef regression 14 seconds ago 11 seconds 0       1 + 0 / 1 4.946KiB 1.761MiB success 
```
   We'll need to commit .51K more bytes of data (3K - 2.49K = .51K)
   to trigger a commit. 
   
***Step 5*** - Let's see what happens in another case...
   
   Assume that our data was bad for some reason,
   and we need to delete the commit.
   That action will bring us back to 0KB on the trigger.
   We will need to add 3KB more of data,
   rather than .51K.


```shell
   $ pachctl delete commit housing_data@staging
```
   Note that both branches now point to the same commit.
```shell  
   $ pachct list branch housing_data

   BRANCH  HEAD                             TRIGGER              
   staging d15eadb6c277406b836c435fd40c07af -                    
   master  d15eadb6c277406b836c435fd40c07af staging on Size(3KB) 
```
   No job has been started.
```shell
   $ pachctl list job

   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE   
   5808786945414be8aa7d8dd2add7cbef regression 26 seconds ago 11 seconds 0       1 + 0 / 1 4.946KiB 1.761MiB success 
   ```

   Commit another file.

   Since the cumulative data committed will be 2.49K,
   the trigger will not fire.
   (2.49K in the first commit -
   2.49K deleted + 
   2.49K in this commit =
   2.49K total)
   
```shell
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ad.csv

   housing-simplified-ad.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
```
   Note that two branches have different head commits ...
```shell
   $ pachctl list branch housing_data

   BRANCH  HEAD                             TRIGGER              
   staging d15eadb6c277406b836c435fd40c07af -                    
   master  6602a67208494bccbf7d5654899ff43a staging on Size(3KB) 
```
   ... and the original job hasn't been joined by another.
```shell
   $ pachctl list job
   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE   
   5808786945414be8aa7d8dd2add7cbef regression 44 seconds ago 11 seconds 0       1 + 0 / 1 4.946KiB 1.761MiB success 
   ```
   
   Now commit another file that takes us beyond the trigger limit
   and confirm that the branch moves
   and a job gets triggered.
   
```shell
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ae.csv

   housing-simplified-ae.csv: 2.26 KiB / 2.26 KiB [==============================================================================================] 100.00% ? p/s 0s
```
   The two branches have the same head commits ...
```shell
   $ pachctl list branch housing_data

   BRANCH  HEAD                             TRIGGER              
   staging 6cbcc0a071bc49ee8968b660109dfea1 -                    
   master  6cbcc0a071bc49ee8968b660109dfea1 staging on Size(3KB) 
```
   ... and there are two jobs.
```shell
   $ pachctl list job

   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE   
   5ea5652d38714917941c276e3fb8b853 regression 10 seconds ago 12 seconds 0       1 + 0 / 1 9.697KiB 3.241MiB success 
   5808786945414be8aa7d8dd2add7cbef regression 2 minutes ago  11 seconds 0       1 + 0 / 1 4.946KiB 1.761MiB success 
```  
   
   If we delete the head commit in `staging` now,
   **after** the trigger has fired,
   the head commit in the `master` branch is also deleted,
   leading to a new job that processes the intermediate commit.
      
```shell
   $ pachctl delete commit housing_data@staging
```
   Note the different commit id
   and the different size of the uploaded (`UL`) and downloaded (`DL`) data
   in the top job in the list.
```shell 
   $ pachctl list job

   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE
   31c3477f33af4e9fad31e668e37e9606 regression 15 seconds ago 11 seconds 0       1 + 0 / 1 7.433KiB 2.534MiB success 
   5808786945414be8aa7d8dd2add7cbef regression 3 minutes ago  12 seconds 0       1 + 0 / 1 4.946KiB 1.758MiB success 
```
   
   It's important to realize that,
   once the trigger has fired, 
   and the branch pointer moved,
   the trigger doesn't get undone.
   Destructive operations on the commit history
   after the commit has triggered
   can process intermediate commits
   that would not have fired a trigger.
      
   Adding two more commits
   summing more than 3KB
   will cause the trigger to fire.

```shell
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ac.csv

   housing-simplified-ac.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
```
```shell
   $ pachctl list branch housing_data

   BRANCH  HEAD                             TRIGGER              
   staging 2b8680e4f856479da785e3115721417e -                    
   master  6cbcc0a071bc49ee8968b660109dfea1 staging on Size(3KB) 
```
```shell
   $ pachctl list job

   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE
   31c3477f33af4e9fad31e668e37e9606 regression 2 minutes ago  11 seconds 0       1 + 0 / 1 7.433KiB 2.534MiB success 
   5808786945414be8aa7d8dd2add7cbef regression 5 minutes ago  12 seconds 0       1 + 0 / 1 4.946KiB 1.758MiB success 
```
```shell
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ae.csv

   housing-simplified-ae.csv: 2.26 KiB / 2.26 KiB [==============================================================================================] 100.00% ? p/s 0s
```
```shell
   $ pachctl list branch housing_data

   BRANCH  HEAD                             TRIGGER              
   staging f8b033d4ef3c43d0993cdd73097943f4 -                    
   master  f8b033d4ef3c43d0993cdd73097943f4 staging on Size(3KB) 
```
```shell
   $ pachctl list job

   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE   
   6234d9a2e252495a9eaf0c5b5c6fa31f regression 16 seconds ago 11 seconds 0       1 + 0 / 1 12.37KiB 3.627MiB success 
   5ea5652d38714917941c276e3fb8b853 regression 3 minutes ago  12 seconds 0       1 + 0 / 1 9.697KiB 3.241MiB success 
   5808786945414be8aa7d8dd2add7cbef regression 6 minutes ago  11 seconds 0       1 + 0 / 1 4.946KiB 1.761MiB success 
```

## 3. Embedding the trigger in the pipeline specification

Every step in this example is available
in the file [embedded-pipeline-based-script.sh](./embedded-pipeline-based-script.sh)
in this repo.

***Step 1*** - Prepare your repository and pipeline:
   If you worked through the example, 
   delete the repo and pipeline
   so this example starts fresh.
   
```shell
   $ pachctl delete pipeline regression
   $ pachctl delete repo housing_data
```
   
   Create the housing_data repo.
   
```shell 
   $ pachctl create repo housing_data
```
   
   Create the pipeline `regression` with the embedded trigger.

```shell
   $ pachctl create pipeline -f regression-trigger.json
```
   
***Step 2*** - Add some data to the master branch:

```shell
   pachctl put file housing_data@master:housing-simplified.csv -f housing-simplified-aa.csv

   housing-simplified-aa.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
```
   - Check the branches on `housing_data`.
   - Look at the branch the pipeline is subscribed to,
   `housing_data@regression-trigger-1`,
   and check to see if it's triggered:
      - Does it have a head commit now?
      - Are there any files in the `housing_data@regression-trigger-1` branch?

```shell
   $ pachctl list branch housing_data 

   BRANCH               HEAD                             TRIGGER             
   master               e0ace165894f45b0bc863cf6f40798fb -                   
   regression-trigger-1 -                                master on Size(3KB) 
```

```shell
   $ pachctl list job

   ID PIPELINE STARTED DURATION RESTART PROGRESS DL UL STATE
```
```shell
   $ pachctl list file housing_data@regression-trigger-1

   the branch "regression-trigger-1" has no head (create one with 'start commit')
```
   
***Step 3*** - Now add some more data to the master branch,
   enough to fire the trigger.
   
```shell
   pachctl put file housing_data@master:housing-simplified.csv -f housing-simplified-ab.csv

   housing-simplified-ab.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
```

```shell
   $ pachctl list branch housing_data

   BRANCH               HEAD                             TRIGGER             
   master               cf325e2813af4331bc983619dd842392 -                   
   regression-trigger-1 cf325e2813af4331bc983619dd842392 master on Size(3KB)
```

```shell
   $ pachctl list job

   ID                               PIPELINE   STARTED       DURATION RESTART PROGRESS  DL UL STATE   
   511d63b3b78e4a53a634a1f01f5401f6 regression 3 seconds ago -        0       0 + 0 / 1 0B 0B running 
```
     
***Step 4*** - Add more data,
   but not enough to fire the trigger.
   
```shell
   $ pachctl put file housing_data@master:housing-simplified.csv -f housing-simplified-ac.csv

   housing-simplified-ac.csv: 2.45 KiB / 2.45 KiB [==============================================================================================] 100.00% ? p/s 0s
```

```shell
   $ pachctl list branch housing_data

   BRANCH               HEAD                             TRIGGER             
   master               2f62be8c3ea8437c9ccc57347a7f9914 -                   
   regression-trigger-1 cf325e2813af4331bc983619dd842392 master on Size(3KB)
```

```shell
   $ pachctl list job

   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE   
   511d63b3b78e4a53a634a1f01f5401f6 regression 18 seconds ago 11 seconds 0       1 + 0 / 1 4.946KiB 1.757MiB success 
```

We have shown you two ways to implement triggers:

 * using `pachctl create branch` with appropriate flags (run the command with `--help` to see an up-to-date list).

 and

 * embedding the trigger in the pipeline specification (see the [Pipeline Specification](https://docs.pachyderm.com/latest/reference/pipeline_spec/) for an exhaustive list of all your options).
 
 









