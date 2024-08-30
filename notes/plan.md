## Local
Local Backup. although not very likely to be commonly used (as backups should be stored somewhere else), it is something that is used in some circumstances.  It also is the first phase to test some initial functionality.
```mermaid
flowchart TD;
    %% To mark an item as completed (green)
    %% style EXAMPLE fill:#afa

    %% To provide a link
    %% A[<a href='https://google.com'>works</a>]

    FEAT_LOCAL_CLEAN[Clean old backups on Local] --> TARG_LOCAL
    FEAT_LOCAL_RECOVER[Local Recovery] --> TARG_LOCAL
    FEAT_MERGE[Merge] --> TARG_LOCAL
    TARG_LOCAL[["`**Local**`"]]

```
## Diff
```mermaid
flowchart TD;
    %% To mark an item as completed (green)
    %% style EXAMPLE fill:#afa

    %% To provide a link
    %% A[<a href='https://google.com'>works</a>]

    FEAT_DIFF_RECOVER[Diff Recovery] --> TARG_DIFF
    TARG_DIFF[["`**Diff**`"]]
```
## Compress
```mermaid
flowchart TD;
    %% To mark an item as completed (green)
    %% style EXAMPLE fill:#afa

    %% To provide a link
    %% A[<a href='https://google.com'>works</a>]

    FEAT_COMP_RECOVER[Compress Recovery] --> TARG_COMPRESS
    TARG_COMPRESS[["`**Compress**`"]]
```
## Remote
```mermaid
flowchart TD;
    %% To mark an item as completed (green)
    %% style EXAMPLE fill:#afa

    %% To provide a link
    %% A[<a href='https://google.com'>works</a>]

    FEAT_LV_EACH[Storage LV for each device] --> TARG_REMOTE
    FEAT_REMOTE_CLEAN[Clean old backups on Remote] --> TARG_REMOTE
    FEAT_REMOTE_RECOVER[REmote REcovery] --> TARG_REMOTE
    FEAT_ISOLATION[Isolation] --> TARG_REMOTE
    TARG_REMOTE[["`**Store Remote**`"]]
```
## Cloud
```mermaid
flowchart TD;
    %% To mark an item as completed (green)
    %% style EXAMPLE fill:#afa

    %% To provide a link
    %% A[<a href='https://google.com'>works</a>]

    FEAT_CLOUD_RECOVER[Cloud Recovery] --> TARG_CLOUD
    FEAT_PERIODIC[Periodic] --> TARG_CLOUD
    TARG_CLOUD[["`**Store in Cloud**`"]]
```
## Final
```mermaid
flowchart TD;
    %% To mark an item as completed (green)
    %% style EXAMPLE fill:#afa

    %% To provide a link
    %% A[<a href='https://google.com'>works</a>]

    FUNC_MAINT(Services in Maint. Mode) -->
    FUNC_LVM_SNAP(LVM Snapshots) -->
    FUNC_DB_BAK(DB Backup) -->
    FUNC_UNMAINT(Out of Maint. Mode) -->
    FUNC_LVM_BAK(Incremental backup of Snapshot Volume) -->
    FUNC_UN_SNAP(Remove Snapshot) -->
    FEAT_LVM_SNAP[<a href='https://github.com/clintwebb/bakker/blob/main/notes/lvm_snapshots.md'>LVM Snapshots</a>] --> TARG_FINAL

    FEAT_ENCRYPT[Encryption] --> TARG_FINAL
    TARG_FINAL[["`**Final**`"]]
    
```
