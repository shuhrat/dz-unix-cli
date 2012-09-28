#!/usr/bin/env bash

Help() {
cat << EOF
Usage: shiroq.sh [OPTIONS]
Copy|Move untracked files from GIT|SVN

OPTIONS:
-g | --git   ) GIT is using as VCS [Selected by default]
-s | --svn   ) SVN is using as VCS
-c | --copy  ) Copy untracked files to output directory [Selected by default]
-m | --move  ) Move untracked files to output directory

-d | --directory  ) Working directory, where repository is located [default: your current working directory]
-o | --output     ) Output directory, where untracked files are copied [Default folder is ~/.Trash]

-v | --version  ) Version of the script
-h | --help     ) Simple help message


Examples:
shiroq.sh -s -c -d ~/Projects/dz-unix-cli -o ~/untracked
Copy all untracked files from "~/Projects/dz-unix-cli" to "~/SHRI/untracked" where VCS system is SVN

shiroq.sh -m -d ~/Projects/dz-unix-cli
Move all untracked files from "~/Projects/dz-unix-cli" to the trash

shiroq.sh -v
shiroq.sh -h

EOF
}

VERSION='0.0.5'

VCS_NAME_DEFAULT='SVN'                # default VCS
COMMAND_DEFAULT='cp'                  # default command
WORKING_DIR_DEFAULT=$PWD              # default working directory       
OUTPUT_DIR_DEFAULT="$HOME/.Trash"     # default output path

while [ "$#" -gt "0" ]
do
  case $1 in
    -g|--git)
              VCS_NAME='GIT'
              ;;
    -s|--svn)
              VCS_NAME='SVN'
              ;;
    -c|--copy)
              COMMAND='cp'
              ;;
    -m|--move)
              COMMAND='mv'
              ;;
    -d|--directory)
              shift
              WORKING_DIR=$1
              ;;
    -o|--output)
              shift
              OUTPUT_DIR=$1
              ;;
    -v|--version)
              echo $VERSION
              exit 1
              ;;
    -h|--help)
              Help
              exit  1
              ;;
    *)
              echo "Syntax Error"
              Help
              exit 1
              ;;
  esac
  shift
done

#Assign default values if it was not assigned
: ${VCS_NAME=$VCS_NAME_DEFAULT}
: ${COMMAND=$COMMAND_DEFAULT}
: ${OUTPUT_DIR=$OUTPUT_DIR_DEFAULT}
: ${WORKING_DIR=$WORKING_DIR_DEFAULT}

#Validate working directory
if [[ ! -d $WORKING_DIR ]]; then
  print_error "$WORKING_DIR does not exists or it's not a directory"
  exit 1
else
  #get absolute path
  WORKING_DIR=$(cd $(dirname $WORKING_DIR) && pwd)/$(basename $WORKING_DIR) 
  cd $WORKING_DIR
fi


#Check if working directory is tracking by VCS
#If WORKING_DIR is repository root directory then copy|move files
case $VCS_NAME in
  GIT )
    if [[ $WORKING_DIR != $(git rev-parse --show-toplevel) ]]; then
      echo "$WORKING_DIR has not GIT repository"
      exit 1
    fi

    #Hence we need to keep file structure use cpio
    git ls-files --others --exclude-standard -z | cpio -pmdu0 "$OUTPUT_DIR"

    #on move command just cleanup the repository
    if [[ $COMMAND == 'mv' ]]; then
      git clean -d
    fi
    ;;

  SVN )

    if ! svn info "$WORKING_DIR" &>/dev/null ; then
      echo "$WORKING_DIR has not SVN repository"
      exit 1
    fi

    if [[ $COMMAND == 'cp' ]]; then
      COMMAND='cp -R' #@fixme
    fi

    svn status | awk '{print $2}' | xargs -I {} -t $COMMAND "$WORKING_DIR$1"/{} "$OUTPUT_DIR"
    ;;
esac

exit 0