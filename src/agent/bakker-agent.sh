#!/bin/bash
# ------------------------------------------------------------------------------------------------------------------
# Bakker
# (c) Copyright, Clinton Webb, 2024.
#
#
# ------------------------------------------------------------------------------------------------------------------

# It is expected that this script will be run from a systemd timer, or manually triggered.
# It can be provided the parameters it needs, or can obtain them from a config file.
# If run as root, it will look for the config files in system level locations, if run as a non-root account, will look for the config under that account.

# It will need to validate the config options, including connectivity to the endpoint (if one is specified).

# rsync -az -H --delete --progress backup/2024-07-22 backup/2024-07-23 torr1:backups/


# ------------------------------------------------------------------------------------------------------------------


# Verify that the variable provided matches the format (or more accurately, checking if second parameter isn't missing).
function nextvar() {
  if [[ -n $2 ]] && [[ ${2:0:1} != '-' ]]; then
    echo "$2"
    return 0
  else
    >&2 echo "Invalid Parameter: $1"
    sleep 1
    return 1
  fi
}

function nextbool() {
  if [[ -n $2 ]] && [[ ${2:0:1} != '-' ]]; then
    if [[ "${2,,}" =~ ^(1|true|yes|y)$ ]]; then
      echo "true"
    else
      echo "false"
    fi
    return 0
  else
    >&2 echo "Invalid Parameter: $1"
    sleep 1
    return 1
  fi
}



# ------------------------------------------------------------------------------------------------------------------

if [[ $1 == "process" ]]; then
  xFILE=$2
  echo "Processing File: $xFILE"
#  echo "BAKKER_NEW: $BAKKER_NEW"

  xNameHash=$(echo "${xFILE}"|sha256sum|awk '{print $1}')
  xDirMode=0
  [[ -d $2 ]] && xDirMode=1 || xDirMode=0

  XX=$(stat -c '%i %f %a %g %u %h %s %W %Y %Z %n' "${xFILE}")
  echo "${xNameHash} ${XX}" >> $BAKKER_NEW/.bakker_t
  xNEW=(${xNameHash} ${XX})


  if [[ -L $xFILE ]]; then
    cp -d "$xFILE" "$BAKKER_NEW/$xFILE"
  elif [[ -d $xFILE ]]; then
    mkdir -p $BAKKER_NEW/$xFILE
  else

    if [[ -n $BAKKER_CURRENT ]]; then
#     echo "Current Exists: $BAKKER_CURRENT"
      xOLD=($(grep -E "^${xNameHash} " $BAKKER_CURRENT/.bakker_t))
#       echo "NEW: ${xNEW[@]}"
#       echo "OLD: ${xOLD[@]}"

      if [[ ${xOLD[9]} -ne ${xNEW[9]} ]] || [[ ${xOLD[7]} -ne ${xNEW[7]} ]]; then
        # The file has changed
#         echo "File Changed: $xFILE"
        cp -v "$xFILE" "$BAKKER_NEW/$xFILE"
      else
#         echo "NOT CHANGED: $xFILE"
        cp -l "$BAKKER_CURRENT/$xFILE" "$BAKKER_NEW/$xFILE"
      fi

    else
#       echo "No Current"
      cp "$xFILE" "$BAKKER_NEW/$xFILE"
    fi
  fi
  # local xFileHash=$(sha256sum "${xFILE}"|awk '{print $1}')


#   if [ $(( var1 & 0x3 )) -eq $(( 0x2 )) ]; then
#   if (( (var1 & 0x3) == 0x2 )); then

# Binary Diff.
# https://unix.stackexchange.com/questions/616282/what-command-will-give-me-a-binary-delta-between-two-files-and-let-me-apply-it
# rsync -av --only-write-batch=JJ A2.txt A1.txt

# S_IFMT     0170000   bit mask for the file type bit fields
# S_IFSOCK   0140000   socket
# S_IFLNK    0120000   symbolic link
# S_IFREG    0100000   regular file
# S_IFBLK    0060000   block device
# S_IFDIR    0040000   directory
# S_IFCHR    0020000   character device
# S_IFIFO    0010000   FIFO
# S_ISUID    0004000   set UID bit
# S_ISGID    0002000   set-group-ID bit (see below)
# S_ISVTX    0001000   sticky bit (see below)
# S_IRWXU    00700     mask for file owner permissions
# S_IRUSR    00400     owner has read permission
# S_IWUSR    00200     owner has write permission
# S_IXUSR    00100     owner has execute permission
# S_IRWXG    00070     mask for group permissions
# S_IRGRP    00040     group has read permission
# S_IWGRP    00020     group has write permission
# S_IXGRP    00010     group has execute permission
# S_IRWXO    00007     mask for permissions for others (not in group)
# S_IROTH    00004     others have read permission
# S_IWOTH    00002     others have write permission
# S_IXOTH    00001     others have execute permission



  exit 0
fi




# ------------------------------------------------------------------------------------------------------------------
# Variables (mostly arrays/lists).  Note that these variables can be set with parameters or config files.

declare -a BAKKER_DIRS


# ------------------------------------------------------------------------------------------------------------------

  while [[ -n $1 ]]; do

    # If the paramters are done like --hostname="fred" then we want to handle that.
    # We also want to handle it if they done like --hostname fred.
    if [[ $1 == *=* ]]; then
      IFS='='; TT=($1); unset IFS;
      ONE=${TT[0]}
      TWO=${TT[1]}
    else
      ONE=$1
      TWO=$2
      shift
    fi

    case $ONE in
      --env|--config)    BAKKER_CONFIG=$(nextvar $ONE $TWO)  || exit $? ;;

      --follow)          BAKKER_FOLLOW=$(nextbool $ONE $TWO) || exit $? ;;
      --diff)            BAKKER_DIFF=$(nextbool $ONE $TWO)   || exit $? ;;

      --local)           BAKKER_LOCAL=$(nextvar $ONE $TWO)   || exit $? ;;
      --remote)          BAKKER_REMOTE=$(nextvar $ONE $TWO)  || exit $? ;;

      --dir|--directory) BAKKER_DIRS+=($(nextvar $ONE $TWO)) || exit $? ;;

      *)
        >&2 echo "Unknown Parameter: $1"
        >&2 echo "Exiting."
        sleep 1
        exit 1
        ;;
    esac
    shift
  done

  # If this is run as 'root' account, we look for a config file at the root level.
  # If a regular user account, look for a config file in their home folder.
  # If it a service account, look for config in /etc/bakker.d/
  if [[ -n $BAKKER_CONFIG ]]; then
    if [[ -e $BAKKER_CONFIG ]]; then
      source $BAKKER_CONFIG
    else
      >&2 echo "Unable to load specified config file: $BAKKER_CONFIG"
      sleep 1
      exit 1
    fi
  else
    if [[ $UID -eq 0 ]]; then
      test -e /etc/bakker.conf && source $_
    else
      test -e /home/$USER/.bakker/bakker.conf && source $_
      test -e /etc/bakker.d/$USER.conf && source $_
    fi
  fi

  if [[ -z $BAKKER_DIRS ]] || [[ ${#BAKKER_DIRS[@]} -le 0 ]]; then
    >&2 echo "No Source Directories specified"
    sleep 1
    exit 1
  fi


  # Check the local target directory
  if [[ -n $BAKKER_LOCAL ]]; then
    test -d $BAKKER_LOCAL || mkdir -vp $BAKKER_LOCAL
    export BAKKER_LOCAL

    # need to find the appropriate location to store the backups
    CC=0
    DD=$(date +%F)
    FF="${DD}.`printf '%04d\n' ${CC}`"
    while [[ -d $BAKKER_LOCAL/$FF ]]; do
      ((CC++))
      FF="${DD}.`printf '%04d\n' ${CC}`"
    done
    export BAKKER_NEW="$BAKKER_LOCAL/$FF"
    echo "NEW: $BAKKER_NEW"
    mkdir $BAKKER_NEW

    # Check previous backup (current)
    if [[ -L $BAKKER_LOCAL/current ]]; then
      export BAKKER_CURRENT=$BAKKER_LOCAL/current
    fi
  fi

  for DD in ${BAKKER_DIRS[@]}; do
    find -L $DD -exec $0 process '{}' \;
  done

#   echo "  ln -sf \"${FF}\" $BAKKER_LOCAL/current"
  ln -sfn "${FF}" $BAKKER_LOCAL/current
