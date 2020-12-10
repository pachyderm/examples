#  Automating Deferred Processing using Triggers

[Deferring processing](https://docs.pachyderm.com/latest/concepts/advanced-concepts/deferred_processing/) is a technique 
for controlling when data is processed
by Pachyderm.
It allows you to commit data 
more often than it is processed.

[Triggers](https://docs.pachyderm.com/latest/concepts/advanced-concepts/deferred_processing.md#automate-deferred-processing-with-branch-triggers) are a tool
for automating deferred processing.
You may automatically move a branch to a new commit
when a set of conditions is reached.

You can move a branch 
based on combinations of

* time
* size
* number of commits 

This example extends the basic [housing prices](../../housing-prices) example,
showing how to retrain the model
when a particular condition is met
using triggers.

Triggers can be created two ways:
1. _Using `pachctl create branch`_:  Using the `--trigger` flag to specify the branch
   which the named branch should use for its head,
   with appropriate parameters
   specified via other flags
   to specify when the branch should be created.
   To use this for deferred processing,
   a pipeline must subscribe to that named branch.
2. _In a pipeline specification_: Adding a `trigger` attribute with appopriate parameters
   to a pfs input 
   in the specification 
   for the pipeline
   embeds the trigger 
   in the pipeline.
   Pachyderm will create the trigger and a branch
   for the pipeline to subscribe to
   using a naming convention of `<pipeline-name>-trigger-n`.


## Prerequisites

1. Install Pachyderm 1.12.0 or newer.
1. Work through the [housing prices](../../housing-prices) example.
1. Understand the [append file processing strategy](https://docs.pachyderm.com/latest/concepts/data-concepts/file/#file-processing-strategies).

## Example run-throughs

We'll first create the trigger on the branch 
and then in the pipline specification

### Using create branch to add the trigger

Every step in this example is available
in the file [create-branch-based-script.sh](./create-branch-based-script.sh)
in this repo.

1. If you worked through the house prices example, 
   delete the repo and pipeline
   so this example starts fresh.
   
   ```
   $ pachctl delete pipeline regression
   $ pachctl delete repo housing_data
   ```
   
1. Create the housing_data repo.
   
   ``` 
   $ pachctl create repo housing_data
   ```
   
1. Create the pipeline `regression`.

   ```
   $ pachctl create pipeline -f ../../housing-prices/regression.json
   ```
   
1. This is where we create the trigger.
   Note that `staging` branch doesn't need to be created, yet.
   
   ```
   $ pachctl create branch housing_data@master --trigger staging --trigger-size 3KB
   $ pachctl list branch housing_data
   BRANCH  HEAD  TRIGGER
   master  -     staging on Size(3KB) 
   ```
   
1. Inspect the `master` branch to see details on the trigger.
   
   ```
   $ pachctl inspect branch housing_data@master
   Name: housing_data@master
   Trigger: staging on Size(3KB) 
   ```


1. Put less than 3KB of data in the `staging` branch.

   ```
   pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-aa.csv
   housing-simplified-aa.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
   ```

1. Note that the branch move has not been triggered.
   
   ```
   $ pachctl list branch housing_data 
   BRANCH  HEAD                             TRIGGER
   staging 3199d1d6a6c0499da198932fcb9c3bad -
   master  -                                staging on Size(3KB)
   $ pachctl list job
   ID PIPELINE STARTED DURATION RESTART PROGRESS DL UL STATE
   $ pachctl list file housing@staging
   NAME                    TYPE SIZE
   /housing-simplified.csv file 2.459KiB
   $ pachctl list file housing_data@master
   the branch "master" has no head (create one with 'start commit')
   ```

1. Add some more data. This appends the additional data to the original CSV file.

   ```
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ab.csv
   housing-simplified-ab.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
   ```
   
1. Check the branches and jobs again.
   Note that the branch pointer got moved and a job triggered.
   
   ```
   $ pachctl list branch housing_data
   BRANCH  HEAD                             TRIGGER              
   staging d15eadb6c277406b836c435fd40c07af -                    
   master  d15eadb6c277406b836c435fd40c07af staging on Size(3KB)
   $ pachctl list job
   ID                               PIPELINE   STARTED       DURATION   RESTART PROGRESS  DL       UL       STATE   
   5808786945414be8aa7d8dd2add7cbef regression 2 seconds ago -          0       1 + 0 / 1 4.946KiB 1.754MiB success
   ```

1. Next, we'll add a commit
   and confirm that the branch doesn't move
   and a job doesn't get triggered,
   because we haven't added 3KB more data.
   
   ```
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ac.csv
   housing-simplified-ac.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
   $ pachctl list branch housing_data
   BRANCH  HEAD                             TRIGGER              
   staging 61a636555ea74871941c92e429f808cf -                    
   master  d15eadb6c277406b836c435fd40c07af staging on Size(3KB) 
   $ pachctl list job
   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE   
   5808786945414be8aa7d8dd2add7cbef regression 14 seconds ago 11 seconds 0       1 + 0 / 1 4.946KiB 1.761MiB success 
   ```
   
   Note that two branches have different head commits
   and the original job hasn't been joined by another.
   We'll need to commit .51K more bytes of data (3K - 2.49K = .51K)
   to trigger a commit. 
   But let's see what happens
   in another case.
   
1. Assume that data was bad for some reason,
   so we need to delete the commit.
   That action will bring us back to 0 on the trigger.
   We'll need to add 3K more of data,
   rather than .51K.

   ```
   $ pachctl delete commit housing_data@staging
   $ pachct list branch housing_data
   BRANCH  HEAD                             TRIGGER              
   staging d15eadb6c277406b836c435fd40c07af -                    
   master  d15eadb6c277406b836c435fd40c07af staging on Size(3KB) 
   $ pachctl list job
   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE   
   5808786945414be8aa7d8dd2add7cbef regression 26 seconds ago 11 seconds 0       1 + 0 / 1 4.946KiB 1.761MiB success 
   ```

   Note that both branches now point to the same commit.
   No job has been started.

1. Commit another file.
   Since the cumulative data committed will be 2.49K,
   the trigger will not fire.
   (2.49K in the first commit -
   2.49K deleted + 
   2.49K in this commit =
   2.49K total)
   
   ```
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ad.csv
   housing-simplified-ad.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
   $ pachctl list branch housing_data
   BRANCH  HEAD                             TRIGGER              
   staging d15eadb6c277406b836c435fd40c07af -                    
   master  6602a67208494bccbf7d5654899ff43a staging on Size(3KB) 
   $ pachctl list job
   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE   
   5808786945414be8aa7d8dd2add7cbef regression 44 seconds ago 11 seconds 0       1 + 0 / 1 4.946KiB 1.761MiB success 
   ```
   
   Note that two branches have different head commits
   and the original job hasn't been joined by another.


1. Commit another file that takes us beyond the trigger limit
   and confirm that the branch moves
   and a job gets triggered.
   
   ```
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ae.csv
   housing-simplified-ae.csv: 2.26 KiB / 2.26 KiB [==============================================================================================] 100.00% ? p/s 0s
   $ pachctl list branch housing_data
   BRANCH  HEAD                             TRIGGER              
   staging 6cbcc0a071bc49ee8968b660109dfea1 -                    
   master  6cbcc0a071bc49ee8968b660109dfea1 staging on Size(3KB) 
   $ pachctl list job
   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE   
   5ea5652d38714917941c276e3fb8b853 regression 10 seconds ago 12 seconds 0       1 + 0 / 1 9.697KiB 3.241MiB success 
   5808786945414be8aa7d8dd2add7cbef regression 2 minutes ago  11 seconds 0       1 + 0 / 1 4.946KiB 1.761MiB success 
   ```
   
   Note that two branches have the same head commits
   and there are two jobs.
   
1. If we delete the head commit in `staging` now,
   after the trigger has fired,
   the head commit in the `master` branch is also deleted,
   leading to a new job that processes the intermediate commit.
   Note the different commit id
   and the different size of the uploaded (`UL`) and downloaded (`DL`) data
   in the top job in the list.
   
   ```
   $ pachctl delete commit housing_data@staging 
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
   
1. Adding two more commits
   summing more than 3KB
   will cause the trigger to fire.

   ```
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ac.csv
   housing-simplified-ac.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
   $ pachctl list branch housing_data
   BRANCH  HEAD                             TRIGGER              
   staging 2b8680e4f856479da785e3115721417e -                    
   master  6cbcc0a071bc49ee8968b660109dfea1 staging on Size(3KB) 
   $ pachctl list job
   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE
   31c3477f33af4e9fad31e668e37e9606 regression 2 minutes ago  11 seconds 0       1 + 0 / 1 7.433KiB 2.534MiB success 
   5808786945414be8aa7d8dd2add7cbef regression 5 minutes ago  12 seconds 0       1 + 0 / 1 4.946KiB 1.758MiB success 
   $ pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ae.csv
   housing-simplified-ae.csv: 2.26 KiB / 2.26 KiB [==============================================================================================] 100.00% ? p/s 0s
   $ pachctl list branch housing_data
   BRANCH  HEAD                             TRIGGER              
   staging f8b033d4ef3c43d0993cdd73097943f4 -                    
   master  f8b033d4ef3c43d0993cdd73097943f4 staging on Size(3KB) 
   $ pachctl list job
   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE   
   6234d9a2e252495a9eaf0c5b5c6fa31f regression 16 seconds ago 11 seconds 0       1 + 0 / 1 12.37KiB 3.627MiB success 
   5ea5652d38714917941c276e3fb8b853 regression 3 minutes ago  12 seconds 0       1 + 0 / 1 9.697KiB 3.241MiB success 
   5808786945414be8aa7d8dd2add7cbef regression 6 minutes ago  11 seconds 0       1 + 0 / 1 4.946KiB 1.761MiB success 
   ```

### Embedding the trigger in the pipeline specification

Every step in this example is available
in the file [embedded-pipeline-based-script.sh](./embedded-pipeline-based-script.sh)
in this repo.

1. If you worked through the example, 
   delete the repo and pipeline
   so this example starts fresh.
   
   ```
   $ pachctl delete pipeline regression
   $ pachctl delete repo housing_data
   ```
   
1. Create the housing_data repo
   
   ``` 
   $ pachctl create repo housing_data
   ```
   
1. Create the pipeline regression with the trigger

   ```
   $ pachctl create pipeline -f regression-trigger.json
   ```
   
1. Add some data to the master branch.
   Check the branches on `housing_data`.
   Look at the branch the pipeline is subscribed to,
   `housing_data@regression-trigger-1`,
   and check to see if it's triggered:
   Does it have a head commit now?
   Are there any files in the `housing_data@regression-trigger-1` branch?

   ```
   pachctl put file housing_data@master:housing-simplified.csv -f housing-simplified-aa.csv
   housing-simplified-aa.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
   $ pachctl list branch housing_data 
   BRANCH               HEAD                             TRIGGER             
   master               e0ace165894f45b0bc863cf6f40798fb -                   
   regression-trigger-1 -                                master on Size(3KB) 
   $ pachctl list job
   ID PIPELINE STARTED DURATION RESTART PROGRESS DL UL STATE
   $ pachctl list file housing_data@regression-trigger-1
   the branch "regression-trigger-1" has no head (create one with 'start commit')
   ```
   
1. Now add some more data to the master branch,
   enough to fire the trigger.
   
   ```
   pachctl put file housing_data@master:housing-simplified.csv -f housing-simplified-ab.csv
   housing-simplified-ab.csv: 2.49 KiB / 2.49 KiB [==============================================================================================] 100.00% ? p/s 0s
   $ pachctl list branch housing_data 
   BRANCH               HEAD                             TRIGGER             
   master               cf325e2813af4331bc983619dd842392 -                   
   regression-trigger-1 cf325e2813af4331bc983619dd842392 master on Size(3KB) 
   $ pachctl list job
   ID                               PIPELINE   STARTED       DURATION RESTART PROGRESS  DL UL STATE   
   511d63b3b78e4a53a634a1f01f5401f6 regression 3 seconds ago -        0       0 + 0 / 1 0B 0B running 
   $ pachctl list file housing_data@regression-trigger-1
   NAME                    TYPE SIZE
   /housing-simplified.csv file 2.459KiB
   $ pachctl list file housing_data@regression-trigger-1
   the branch "regression-trigger-1" has no head (create one with 'start commit')
   ```
     
1. Add more data,
   but not enough to fire the trigger.
   
   ```
   $ pachctl put file housing_data@master:housing-simplified.csv -f housing-simplified-ac.csv
   housing-simplified-ac.csv: 2.45 KiB / 2.45 KiB [==============================================================================================] 100.00% ? p/s 0s
   $ pachctl list branch housing_data
   BRANCH               HEAD                             TRIGGER             
   master               2f62be8c3ea8437c9ccc57347a7f9914 -                   
   regression-trigger-1 cf325e2813af4331bc983619dd842392 master on Size(3KB) 
   $ pachctl list job
   ID                               PIPELINE   STARTED        DURATION   RESTART PROGRESS  DL       UL       STATE   
   511d63b3b78e4a53a634a1f01f5401f6 regression 18 seconds ago 11 seconds 0       1 + 0 / 1 4.946KiB 1.757MiB success 


We've shown two ways to implement triggers:

 * using `pachctl create branch` with appropriate flags (run the command with `--help` to see an up-to-date list) and
 * embedding the trigger in the pipeline specification (see the Pipeline Specification for an up-to-date list)
 
 









