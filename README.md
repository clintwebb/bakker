# bakker
Tool for backups

The main purpose is for a simplified backups solution with almost no backup service other than storage, the majority of everything is done on the server itself with an agent which can be triggered.

Main Goals:
* a simplified backups solution with almost no backup service other than storage
* the majority of everything is done on the server itself with an agent which can be triggered.
* configuration for the agent can be on the storage location (or a controlling service), but doesn't have to be.
* reverse incremental (the latest backup is a full backup, and can be restored in a single go).
   * on the target device, hardlinks will be used for files that haven't changed
   * new copies stored for files that have changed.
* encryption (before delivered to storage)
* isolation
   * even though the storage service might have content from multiple servers, each different server cannot see the content from the other servers.
   * in this case, a seperate access account will be setup for each server, and each different account will not have access to the content from other accounts.
   * (this is what would be done by default)
* merging... if we have daily backups, over a year that would result in 365 incrementals.  If we want to keep the last 14 days incrementals, and then keep one combined incremental each month, and then one yearly for 4 years.   Each incremental deleted would be fine.  The `impl` file will contain some history (if requested), but most of it will only be the information about the file system at that current moment.  THe incremental folder actually has ALL the files for that run, it just has LOTS that are hardlinked in other incrementals.

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
13. on the backup server, it might have some configuration that it knows how much to retain and delete automatically.   It could mean, keep content at least 14 days, and at least 7 instances.  Which means if it was intented to be done daily, it would keep 14 days.  But it it only ran randomly, it would keep at least 7 incrementals.
