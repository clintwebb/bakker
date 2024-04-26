# bakker
Tool for backups

The main purpose is for a simplified backups solution with almost no backup service other than storage, the majority of everything is done on the server itself with an agent which can be triggered.

Main Goals:
* a simplified backups solution with almost no backup service other than storage (but can provide additional functionality)
* the majority of everything is done on the server itself with an agent which can be triggered.
* configuration for the agent can be on the storage location (or a controlling service), but doesn't have to be.
* reverse incremental (the latest backup is a full backup, and can be restored in a single go).
   * on the target device, hardlinks will be used for files that haven't changed
   * new copies stored for files that have changed.
* lvm snapshots
   * Will put service in maintenance mode
   * do database backup
   * do local lvm snapshot
   * take it out of maintenance
   * Then do incremental backup of the snapshot volume
   * and when completed, remove the snapshot.
   * _as an example, This means nextcloud does not need to be in maintenance mode for long._
* local hard-link backups.  In addition to sending backups to remote server for storage, it can also do hard-link backups locally (on the same volume) which can assist with lock backup copies, which can be retained at different levels.  Therefore it can be a local backup copy, as well as a remote backup copy.
* Remote backup can be compressed to reduce space (but is recommended at the 3rd level).
* THe local and remote backups can contain the full filesystem with hard-links so that it can be recovered pretty much instantly.. but can also have a diff folder which only contains hardlinks to versions of te files that have changed.  This can also be used for other incremental backups.  ie, when zipping up and sending to another external source, dont need to include the bits that have not changed.
* storage server can allocate specific space (LV's) for each device.  ie, the source server might have 10GB space allocated, and once filled will not increase.  Some other options could be implemented to make this flexible (like the source can request an increase)...
* encryption (before delivered to storage)
* isolation
   * even though the storage service might have content from multiple servers, each different server cannot see the content from the other servers.
   * in this case, a seperate access account will be setup for each server, and each different account will not have access to the content from other accounts.
   * (this is what would be done by default)
* merging... if we have daily backups, over a year that would result in 365 incrementals.  If we want to keep the last 14 days incrementals, and then keep one combined incremental each month, and then one yearly for 4 years.   Each incremental deleted would be fine.  The `impl` file will contain some history (if requested), but most of it will only be the information about the file system at that current moment.  THe incremental folder actually has ALL the files for that run, it just has LOTS that are hardlinked in other incrementals.
* Include functionality to also deliver (and maintain) backups in cloud resources (like AWS S3 Glacier)
   * should have functionality to not include every backup, but monthly backups, etc... 

Example.
1. We have a server that is just for storage of the backup data.  Lets call it `storage1`.
2. We have a server with data on it, lets call it `server1`.
3. There is nothing special on `storage1`, other than it stores the data.  Lets say it has a folder called `/backups`.   eg, `storage1:/backups`
4. `server1` has a bunch of data in `/data`.
5. The bakker agent is installed on `server1`, and initialized.
   * It is configured (with a systemd timer) to run once a day at 1am.
   * (in this case, there is no encryption setup, but there can be)
   * for isolation in this case, when initialised, an account is setup on the target storage in /backups for this server.  So it would actually be `server1@storage1:/backups/server1/`
      * In cases where restoring content from a previous server to a new server, it can be setup to use the same account, or two different accounts given access.  Also groups can be setup.
6. When the bakker runs the first time, there is nothing on the storage server, so it is a full backup the first time.
7. Each backup will contain date, and an incremental number.  Used as the folder name  eg `2024_04_18_01`
8. The latest backup will also have a symbolic link `latest` pointing to it.
9. A implementation file will also be stored on the target server.  for the first run mentioned above it would be `2024_04_18_01.impl`
   * The impl will contain all the information about each file backed up, along with extra information like md5sum(optional),owner,group,mode,facls,se's... etc. 
11. The next incremental backup the next day, will create `2024_04_19_01`.
12. Each file in the new directory will be a hard-link to the previous file (if it hadn't changed), or a new copy of a file (if it did change).
    * This means that if we only want to keep 14 days of backups, we can simply delete the directory (and impl file) for the directory with the date older than 14 days.  It would have no impact on the latest (or other incremental) folders.
13. on the backup server, it might have some configuration that causes it to:
    * know how much to retain and delete automatically.   It could mean, keep content at least 14 days, and at least 7 instances.  Which means if it was intented to be done daily, it would keep 14 days.  But it it only ran randomly, it would keep at least 7 incrementals.
    * Keep a certain number of recent daily backups, but also keep monthly backups, and yearly backups.   


