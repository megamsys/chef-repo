#!/bin/bash
#Copyright (c) 2014 Megam Systems.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
###############################################################################
# A log shipper script that uses heka to transfer the logs. 
###############################################################################

#--------------------------------------------------------------------------
#parse the input parameters.
# Pattern in case statement is explained below.
# a*)  The letter a followed by zero or more of any
# *a)  The letter a preceded by zero or more of any
#--------------------------------------------------------------------------
parseParameters()   {
  #integer index=0
  COMPID_PAIRS=()

  if [ $# -lt 1 ]
    then
    show_help
    exitScript 1
  fi
  
  for i in "$@"
    do
    case $i in
      -h|--help)
      show_help
      ;;
      -c=*|--collect=*)
      COMPID_PAIRS+=("${i#*=}")
 #     COMPID_PAIRS="${i#*=}"
      shift
      ;;
      *)
      # unknown option
      echo "Unknown option : $item - refer help."
      help
      ;;
    esac
  done
  
  if [ ${#COMPID_PAIRS[@]} -gt 0 ]
    then
    logcollect "${COMPID_PAIRS[@]}" 
 fi
  
}
#--------------------------------------------------------------------------
#prints the help to out file.
#--------------------------------------------------------------------------
show_help() {
  echo  "Usage    : logheka.sh [Options]"
  echo  "-h       : prints the help message. eg: ./logheka.sh -c=\"queuuuuu\",\"/var/log/megam/heka.log\""
  echo  "-c       : setup collection of logs to queues to logfileid"  
}
#--------------------------------------------------------------------------
# Insert the logcollector 
#--------------------------------------------------------------------------
logcollect() {
    compid_pairs=("$@")   
    
    for i in "${compid_pairs[@]}" ; do          
        logfile_ids=(${i//,/ })
        printf -- 'setup logging for  %s %s\n' "${logfile_ids[0]}"  "${logfile_ids[1]}"

        queue="${logfile_ids[0]}"
        fullfile="${logfile_ids[1]}"
dir=$(dirname "$fullfile")
        filename=$(basename "$fullfile")
extension="${filename##*.}"
file="${filename%.*}"
echo "DirNAME ==> $dir"
echo "FILENAME ==> $filename"
echo "extension ==> $extension"
echo "file ==> $file"




echo "[$queue-$file]
type = \"LogstreamerInput\"
log_directory = \"$dir\"
file_match = '$filename'
differentiator = [\"$queue\"]
        
"|cat - testt > /tmp/out && mv /tmp/out testt


    done
}

#--------------------------------------------------------------------------
#This function will exit out of the script.
#--------------------------------------------------------------------------
exitScript(){
  exit $@
}

#parse parameters
parseParameters "$@"

echo "Good bye."
exitScript 0
