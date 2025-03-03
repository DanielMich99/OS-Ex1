#!/bin/bash
#Daniel Michaelshvili 207795030

#check if the number of arguments is below 2
if [ $# -lt 2 ]
then
echo "Not enough parameters"
exit 1
fi

# simple check if $1 is a valid path
if [ ! -d $1 ]
then
exit 1
fi

#cd $1

# remove all the ".out" files in the $1 not recursive with rm
find $1 -maxdepth 1 -type f -name "*.out" -exec rm {} \;

# # # for loop that goes through all the .c files in the directory without subdirectories and compiles them if they have the $2 word in them with no sense of case, with the name of the file.out
for file in $(find $1 -maxdepth 1 -type f -name "*.c" -exec grep -qwi "\b$2\b" {} \; -print )
do
# not include the last 2 characters of the file name (the .c extension)
gcc -w -o ${file%.c}.out $file
#echo "Compiled $file"
done


#!/bin/bash
#Daniel Michaelshvili 207795030

#check if the number of arguments is below 2
if [ $# -lt 2 ]
then
echo "Not enough parameters"
exit 1
fi

# simple check if $1 is a valid path
if [ ! -d $1 ]
then
exit 1
fi

#cd $1

# remove all the ".out" files in the $1 not recursive with rm
find $1 -maxdepth 1 -type f -name "*.out" -exec rm {} \;

# # # for loop that goes through all the .c files in the directory without subdirectories and compiles them if they have the $2 word in them with no sense of case, with the name of the file.out
for file in $(find $1 -maxdepth 1 -type f -name "*.c" -exec grep -qwi "\b$2\b" {} \; -print )
do
# not include the last 2 characters of the file name (the .c extension)
gcc -w -o ${file%.c}.out $file
done

if [[ "$3" == "-r" ]]
then
  for dir in "$1"/*/
  do
    if [ -d "$dir" ]; then
      $0 $dir $2 "-r"
    fi
  done
fi







