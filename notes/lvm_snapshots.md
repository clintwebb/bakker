# lvm snapshots
1. Will put service in maintenance mode
2. do database backup
3. do local lvm snapshot
4. take it out of maintenance
5. Then do incremental backup of the snapshot volume
6. and when completed, remove the snapshot.

----
_as an example, This means nextcloud does not need to be in maintenance mode for long._
