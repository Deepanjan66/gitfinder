#!/bin/sh

# Variables that hold values obtained from the
# arg flags
commit='';
folder=0;

# Store current directory
curr_dir=`pwd`;

# Function used for printing error statements
show_errors()
{
   if [ $? -ne 0 ];
   then
      echo "$1"; 
      continue;
   fi
}

# For all arguments in the arg list
while [[ $# -gt 0 ]];
do
   # Update variable values depending on the flags
   if [ "$1" = "-f" ];
   then
      folder=1;
      shift 1;
   elif [ "$1" = "-c" ]
   then
      commit="$2";
      shift 2;
   # Show -h output for any other flags provided
   else
      echo "Usage: gitfinder <flags> <values>"
      echo "Flags:"
      echo "   -h : This will show all the available commands"
      echo "   -f : Show results by folder name"
      echo "   -c  \"string\" : Search repositories by string in commit messages"
      exit
   fi
done

# Array that will store all the repositories that are found
results=();
# Find all the folders that have a .git file or folder
repos=( $(find . 2> /dev/null | egrep -E "\.git$") );

# For every folder that has .git
for ((i=0; i<${#repos[@]}; i++ ));
do
   # Remove the .git at the end
   dirname="${repos[$i]}";
   dirname=`echo "$dirname" | sed s/\.git$//g 2> /dev/null`;
   show_errors "Encountered an error while looking at ${repos[$i]}";
   # If dirname is not a directory, move to the next repository dir
   if [ ! -d "$dirname" ];
   then
      continue;
   fi
   # If commit flag is provided, look for required commit message
   # from the commit log
   if [[ $commit ]];
   then
      cd $dirname;
      show_errors "Encountered an error while looking at ${repos[$i]}";
      all_logs=`git log --pretty=format:"%s" 2> /dev/null`;
      show_errors "Encountered an error while looking at ${repos[$i]}";
      all_logs=`echo "$all_logs" | sed 's/\n/ /g' 2> /dev/null`;
      show_errors "Encountered an error while looking at ${repos[$i]}";
   
      if echo "$all_logs" | grep -Eiq $commit ;
      then
         results+=(${repos[i]}); 
      fi
      cd $curr_dir;
   else
      # Add all results if no filters are required
      results+=(${repos[i]}); 
   fi
done

# Print all the results
echo "===================== RESULTS ========================"
for ((i=0; i<${#results[@]}; i++ ));
do
   dirname="${results[$i]}";
   if [[ $folder -eq 1 ]];
   then
      dirname=`echo "$dirname" | sed 's/\/\.git//g' | grep -o "[^/]*$"`
   fi
   echo "$dirname";
done
echo "======================================================"
