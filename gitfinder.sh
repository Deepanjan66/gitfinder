#!/bin/sh

# Variables that hold values obtained from the
# arg flags
commit='';
start_date='';
end_date='';
folder=0;
report=0;

ret_val=0;
echo '' > /tmp/gitfinder_error

check_commit(){
   if [[ $commit ]];
   then
      all_logs=`git log --pretty=format:"%s" 2> /tmp/gitfinder_error`;
      show_errors "Error at ${repos[$i]}";
      all_logs=`echo "$all_logs" | sed 's/\n/ /g' 2> /tmp/gitfinder_error`;
      show_errors "Error at ${repos[$i]}";
   
      if echo "$all_logs" | grep -Eiq $commit ;
      then
         ret_val=1;
         #results+=(${repos[i]}); 
      else
         ret_val=0;
      fi
   else
      ret_val=1;
   fi
}

check_end_date(){
   if [[ $end_date ]];
   then
      repo_last_edit_date=`git log --pretty=format:"%ai" 2> /tmp/gitfinder_error | head -n 1 | cut -d" " -f1`;
      show_errors "Error at ${repos[$i]}";
      compare_dates $repo_last_edit_date $end_date;
   else
      ret_val=1;
   fi
}

check_start_date(){
   if [[ $start_date ]];
   then
      repo_last_edit_date=`git log --pretty=format:"%ai" 2> /tmp/gitfinder_error | tail -n 1 | cut -d" " -f1`;
      show_errors "Error at ${repos[$i]}";
      compare_dates $start_date $repo_last_edit_date;
   else
      ret_val=1;
   fi
}

compare_dates() {
   if [ -z "$1" ];
   then
      ret_val=-2;
      return;
   elif [ -z "$2" ];
   then
      ret_val=-2;
      return;
   fi
   date1_year=`echo $1 | cut -d"-" -f1`;
   date1_month=`echo $1 | cut -d"-" -f2`;
   date1_day=`echo $1 | cut -d"-" -f3`;

   date2_year=`echo $2 | cut -d"-" -f1`;
   date2_month=`echo $2 | cut -d"-" -f2`;
   date2_day=`echo $2 | cut -d"-" -f3`;

   if [ $date1_year -gt $date2_year ];
   then
      ret_val=1;
   elif [ $date1_year -lt $date2_year ];
   then
     ret_val=-1;
   else
      if [ $date1_month -gt $date2_month ];
      then
         ret_val=1;
      elif [ $date1_month -lt $date2_month ];
      then
         ret_val=-1;
      else
         if [ $date1_day -gt $date2_day ];
         then
            ret_val=1;
         elif [ $date1_day -lt $date2_day ];
         then
            ret_val=-1;
         else
            ret_val=0;
         fi
      fi
   fi
}

# Store current directory
curr_dir=`pwd`;


# Function used for printing error statements
show_errors() {

   if [ $? -ne 0 ];
   then
      echo "$1"; 
      continue;
   else
      err=`cat /tmp/gitfinder_error`;
      if [ ! -z "$err" ];
      then
         echo "$1 : $err";
         echo '' > /tmp/gitfinder_error;
         continue;
      fi
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
   elif [ "$1" = "-e" ]
   then
      end_date="$2";

      # Assign values to start date types
      end_year=`echo $end_date | cut -d"-" -f1`;
      end_month=`echo $end_date | cut -d"-" -f2`;
      end_day=`echo $end_date | cut -d"-" -f3`;
      shift 2;
   elif [ "$1" = "-s" ]
   then
      start_date="$2";

      start_year=`echo $start_date | cut -d"-" -f1`
      start_month=`echo $start_date | cut -d"-" -f2`
      start_day=`echo $start_date | cut -d"-" -f3`

      shift 2;
   elif [ "$1" = "--report" ];
   then
      report=1;
   else
      echo "Usage: gitfinder <flags> <values>"
      echo "Flags:"
      echo "   -h : This will show all the available commands"
      echo "   -f : Show results by folder name"
      echo "   -c \"string\" : Search repositories by string in commit messages"
      echo "   -s \"%Year-%Month-%Day\" : Finds repositories with first commit before or on that day"
      echo "   -e \"%Year-%Month-%Day\" : Finds repositories with last commit after or on that day"
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
   dirname=`echo "$dirname" | sed s/\.git$//g 2> /tmp/gitfinder_error`;
   show_errors "Error at ${repos[$i]}";
   # If dirname is not a directory, move to the next repository dir
   if [ ! -d "$dirname" ];
   then
      continue;
   fi
   cd $dirname;
   add=1;
   # If commit flag is provided, look for required commit message
   # from the commit log
   check_commit;
   add=`expr $add \* $ret_val`;

   check_end_date;
   if [[ $ret_val -lt 0 ]];
   then
      add=`expr $add \* 0`;
   else
      add=`expr $add \* 1`;
   fi

   check_start_date;
   if [[ $ret_val -lt 0 ]];
   then
      add=`expr $add \* 0`;
   else
      add=`expr $add \* 1`;
   fi

   if [ $add -gt 0 ];
   then
      results+=(${repos[i]}); 
   fi
   cd $cur_dir;
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
