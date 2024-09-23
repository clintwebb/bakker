## Local
Local Backup. although not very likely to be commonly used (as backups should be stored somewhere else), it is something that is used in some circumstances.  It also is the first phase to test some initial functionality.
```mermaid
flowchart TD;
    %% To mark an item as completed (afa=green, faf=purple, aaf=blue)
    %% style EXAMPLE fill:#afa

    %% To provide a link
    %% A[<a href='https://google.com'>works</a>]
    %%--------------

    %% Completed (#afa)
    style FEAT_INIT fill:#afa
    style FUNC_HASH fill:#afa
    style FUNC_PROCESS fill:#afa
    style FEAT_CONFIG fill:#afa
    style FEAT_CONF_DIRLIST fill:#afa

    %% Active (#aaf)
    style FEAT_TRIGGER fill:#aaf

    FUNC_HASH(Get Hash,Info of file to process) -->
    FUNC_PROCESS(Initial Process) -->

    %% Init Script that can handle the basics of local backups.
    FEAT_INIT[Initial Script] --> FEAT_CONFIG

    FEAT_CONF_DIRLIST(Config Dir List) --> FEAT_CONFIG
    FEAT_ID_HARDLINKS[Identify Hardlinks] --> TARGET

    FEAT_CONFIG[Config File] -->
    FEAT_LOCAL_CLEAN[Clean old backups on Local] --> TARGET
    FEAT_CONFIG --> FEAT_LOCAL_RECOVER[Local Recovery] --> TARGET
    FEAT_CONFIG --> FEAT_MERGE[Merge] --> TARGET

    %% Trigger is the ability to perform some actions when triggering the backup.
    FEAT_CONFIG --> FEAT_TRIGGER[Trigger] --> TARGET

    FEAT_PUSHD[Pushd start dir] --> FEAT_CONFIG
    FEAT_FOLLOW[Follow] --> TARGET


    TARGET[["`**Local**`"]]
    style TARGET fill:#faf
```
## Diff
```mermaid
flowchart TD;
    %% To mark an item as completed (afa=green, faf=purple, aaf=blue)
    %% style EXAMPLE fill:#afa

    %% To provide a link
    %% A[<a href='https://google.com'>works</a>]
    %%--------------

    %% Completed (#afa)

    %% Active (#aaf)

    FEAT_DIFF[Diff Implement] -->
    FEAT_DIFF_RECOVER[Diff Recovery] -->
    TARGET[["`**Diff**`"]]
    style TARGET fill:#faf
```
## Compress
```mermaid
flowchart TD;
    %% To mark an item as completed (afa=green, faf=purple, aaf=blue)
    %% style EXAMPLE fill:#afa

    %% To provide a link
    %% A[<a href='https://google.com'>works</a>]
    %%--------------

    %% Completed (#afa)

    %% Active (#aaf)

    FEAT_COMPRESS[Compress] -->
    FEAT_COMP_RECOVER[Compress Recovery] -->
    TARGET[["`**Compress**`"]]
    style TARGET fill:#faf
```
## Remote
```mermaid
flowchart TD;
    %% To mark an item as completed (afa=green, faf=purple, aaf=blue)
    %% style EXAMPLE fill:#afa

    %% To provide a link
    %% A[<a href='https://google.com'>works</a>]
    %%--------------

    %% Completed (#afa)

    %% Active (#aaf)

    FUNC_LV_EACH(Storage LV for each device) -->

    FEAT_ACCOUNT_SETUP[Account Setup on Remote Storage] -->
    FEAT_ACCOUNT_SRC[Account setup in config on source] -->
    FEAT_TRANSFER_REMOTE[Transfer Remote]  -->
    FEAT_REMOTE_CLEAN[Clean old backups on Remote] --> TARGET

    FEAT_REMOTE_RECOVER[Remote Recovery] --> TARGET
    FEAT_TRANSFER_REMOTE --> FEAT_REMOTE_RECOVER

    %% Ensure different accounts have no ability to access resources from other accounts.
    FUNC_ISOLATION(Isolation) --> TARGET

    TARGET[["`**Store Remote**`"]]
    style TARGET fill:#faf

```
## Cloud
```mermaid
flowchart TD;
    %% To mark an item as completed (afa=green, faf=purple, aaf=blue)
    %% style EXAMPLE fill:#afa

    %% To provide a link
    %% A[<a href='https://google.com'>works</a>]
    %%--------------

    %% Completed (#afa)

    %% Active (#aaf)

    FEAT_CLOUD_TRANSFER[Cloud Transfer] -->
    FEAT_CLOUD_RECOVER[Cloud Recovery] --> TARGET

    %% merging... if we have daily backups, over a year that would result in 365 incrementals.  If we want to keep the last 14 days incrementals, and then keep one combined incremental each month, and then one yearly for 4 years.   Each incremental deleted would be fine.  The `impl` file will contain some history (if requested), but most of it will only be the information about the file system at that current moment.  THe incremental folder actually has ALL the files for that run, it just has LOTS that are hardlinked in other incrementals.
    FEAT_PERIODIC[Periodic Merge and Clean] -->

    TARGET[["`**Store in Cloud**`"]]
    style TARGET fill:#faf
```
## Final
```mermaid
flowchart TD;
    %% To mark an item as completed (afa=green, faf=purple, aaf=blue)
    %% style EXAMPLE fill:#afa

    %% To provide a link
    %% A[<a href='https://google.com'>works</a>]
    %%--------------

    %% Completed (#afa)

    %% Active (#aaf)

    subgraph LVM_SNAPSHOT["`**LVM SNAPSHOT**`"]
        FUNC_MAINT(Services in Maint. Mode) -->
        FUNC_LVM_SNAP(LVM Snapshots) -->
        FUNC_DB_BAK(DB Backup) -->
        FUNC_UNMAINT(Out of Maint. Mode) -->
        FUNC_LVM_BAK(Incremental backup of Snapshot Volume) -->
        FUNC_UN_SNAP(Remove Snapshot)
    end
    FEAT_TRIGGER{Trigger} --> LVM_SNAPSHOT --> TARGET

    FEAT_ENCRYPT[Encryption] --> TARGET

    TARGET[["`**Final**`"]]
    style TARGET fill:#faf
```
