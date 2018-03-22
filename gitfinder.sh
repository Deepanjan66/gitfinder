#!/bin/sh

commit='';
folder=0;
curr_dir=`pwd`;


show_errors()
{
   if [ $? -ne 0 ];
   then
      echo "$1"; 
      continue;
   fi
}


while [[ $# -gt 0 ]];
do
   if [ "$1" = "-f" ];
   then
      folder=1;
      shift 1;
   elif [ "$1" = "-c" ]
   then
      commit="$2";
      shift 2;
   else
      echo "Usage: gitfinder <flags> <values>"
      echo "Flags:"
      echo "   -h : This will show all the available commands"
      echo "   -f : Show results by folder name"
      echo "   -c  \"string\" : Search repositories by string in commit messages"
      exit
   fi
done

results=();

repos=( $(find . 2> /dev/null | egrep -E "\.git$") );

for ((i=0; i<${#repos[@]}; i++ ));
do
   dirname="${repos[$i]}";
   dirname=`echo "$dirname" | sed s/\.git$//g 2> /dev/null`;
   show_errors "Encountered an error while looking at ${repos[$i]}";
   if [ ! -d "$dirname" ];
   then
      continue;
   fi
   if [[ $commit ]];
   then
      cd $dirname;
      show_errors "Encountered an error while looking at ${repos[$i]}";
      all_logs=`git log --pretty=format:"%s"`;
      show_errors "Encountered an error while looking at ${repos[$i]}";
      all_logs=`echo "$all_logs" | sed 's/\n/ /g' 2> /dev/null`;
      show_errors "Encountered an error while looking at ${repos[$i]}";
   
      if echo "$all_logs" | grep -Eiq $commit ;
      then
         results+=(${repos[i]}); 
      fi
      cd $curr_dir;
   else
      results+=(${repos[i]}); 
   fi
done

for ((i=0; i<${#results[@]}; i++ ));
do
   dirname="${results[$i]}";
   if [[ $folder -eq 1 ]];
   then
      dirname=`echo "$dirname" | sed 's/\.git//g' | grep -o "[^\/]+"`
   fi
   echo "$dirname";
done
