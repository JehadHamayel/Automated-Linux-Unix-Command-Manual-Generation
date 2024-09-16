#Jehad Hamayel 1200348

#Variables in order to give an advantage to the text
BOLD="\e[1m"
NORMAL="\e[0m"


GeneratCellName(){ 
#Name title with BOLD feature
Keyword=$(echo -e "${BOLD}$1${NORMAL}")

local specificData=$2 #The name of the file in which the name of the command is stored

tr -s ' ' ' ' < $specificData > t #Reducing space to space alone
mv t $specificData

sed -n "2p" $specificData > tempFile
name=$(cat tempFile)
echo "$Keyword               	$name" >> $3

#Delete files that are no longer useful for use
rm tempFile
rm $2
}

#A special function to create the DESCRIPTION cell for the commands according to the required template
GeneratCellDESCRIPTION(){ 
#DESCRIPTION title with BOLD feature
Keyword=$(echo -e "${BOLD}$1${NORMAL}")

local specificData=$2 #The name of the file in which the command DESCRIPTION is stored
sed -i '/^$/d' $specificData #Clear spaces
tr -s ' ' ' ' < $specificData > t #Reducing space to space alone
mv t $specificData
#Dividing the content of the DESCRIPTION commands into a specific number of words to arrange them in print
local i=1 
ip="$i""p" 
sed -n "$ip" $specificData > tempFile
local firstPart=$(cut -d' ' -f1-30 tempFile)
local secondPart=$(cut -d' ' -f31- tempFile)

#Create the lines that will be displayed in the command file using the DESCRIPTION section
while [ -n "$firstPart" ] 
do 
	#Create the first line in it, then take a new line from the DESCRIPTION
	if [ $i -eq 1 ]
	then
		echo "$Keyword	       $firstPart" >> $3
		i=$((i + 1))
		ip="$i""p"
		sed -n "$ip" $specificData > tempFile
		firstPart=$(cut -d' ' -f1-30 tempFile)
		secondPart=$(cut -d' ' -f31- tempFile)
		continue
	fi
	if [ $i -ne 1 ]
	then
		echo "		       $firstPart" >> $3	
	fi 
	echo "		        $secondPart" >> $3
	i=$((i + 1))
	ip="$i""p"
	sed -n "$ip" $specificData > tempFile
	firstPart=$(cut -d' ' -f1-30 tempFile)
	secondPart=$(cut -d' ' -f31- tempFile)
done
#Delete files that are no longer useful for use
rm tempFile
rm $2
}
#A special function to create the Version cell for the commands according to the required template
GeneratCellVersion(){	
echo "________________	_________________________________________________________________________________________________________________________________________________________________________________________________" >> $1
#Version title with BOLD feature
local Keyword=$(echo -e "${BOLD}$2${NORMAL}")
local VersionData=$(cut -d',' -f1 $3)
#Store the version of the command
echo "$Keyword			$VersionData" >> $1
#Delete files that are no longer useful for use
rm $3
}
#A special function to create the Examples cell for the commands according to the required template
GeneratCellExamples(){ 
echo "________________	_________________________________________________________________________________________________________________________________________________________________________________________________" >> $1
#Examples title with BOLD feature
local Keyword=$(echo -e "${BOLD}$3${NORMAL}")
#Segment the results for printing in the desired manner
local ExamplesPart1=$(cut -d'!' -f1 $2)

echo "$Keyword			$ExamplesPart1" >> $1
local output=$4
local x=2

local ExamplesParts2=$(cut -d'!' -f$x $2)
while [ -n "$ExamplesParts2" -a "$ExamplesPart1" != "$ExamplesParts2" ] 
do
	echo "			$ExamplesParts2" >> $1
	x=$((x + 1))
	ExamplesParts2=$(cut -d'!' -f$x $2)
	
done

echo "________________	_________________________________________________________________________________________________________________________________________________________________________________________________" >> $1	
#OUTPUT title with BOLD feature
local Keyword2=$(echo -e "${BOLD}OUTPUT${NORMAL}")
#Segment the results for printing in the desired manner
outputPart1=$(sed -n "1p" $output)
echo "$Keyword2			$outputPart1" >> $1
x=2
ip="$x""p"

outputParts2=$(sed -n "$ip" $output)
while [ -n "$outputParts2" -a "$outputPart1" != "$outputParts2" ] 
do
	echo "			$outputParts2" >> $1
	x=$((x + 1))
	ip="$x""p"
	outputParts2=$(sed -n "$ip" $output)
	
done
#Delete files that are no longer useful for use
rm $4
rm $2
}
#A special function to create the Related Commands cell for the commands according to the required template
GeneratCellRelatedCommands(){
local command=$1
local specificData=$4
#Extract the Related Commands from the manual for each command
if [ $command == "grep"  ]
then	
	man $command | awk '/^SEE ALSO$/,/^GNU$/' |  grep -v '^SEE ALSO$' | sed -n '2p' > $specificData
else
	man $command | awk '/^SEE ALSO$/,/^GNU$/' |  grep -v '^SEE ALSO$' | sed -n '1p' > $specificData
fi
sed -i 's/[()0-9]//g' $specificData 
echo "________________	_________________________________________________________________________________________________________________________________________________________________________________________________" >> $2
sed -i '/^$/d' $specificData #Get rid of some details to display Related Commands in a better way
tr -s ' ' ' ' < $specificData > tempFile  ##Reducing the number of repeated spaces
mv tempFile $specificData
#Related Commands title with BOLD feature
local Keyword=$(echo -e "${BOLD}$3${NORMAL}")
#Split the result for better printing
local relatedCommandsPart1=$(cut -d' ' -f1-10 $specificData)
local relatedCommandsPart2=$(cut -d' ' -f11- $specificData)
echo "$Keyword       $relatedCommandsPart1" >> $2
echo "	                $relatedCommandsPart2" >> $2
#Delete files that are no longer useful for use
rm $4
}

#Special function in Generation Of Command Manual
Generater_Of_Command_Manual(){
#Store commands as a variable to create a separate file for each command
local commands=$(cat $1)
#Create a directory for each command group for Verification and commands and enter it to store it.
if [ $2 == "command"  ]
then
	if [ ! -d "commands" ]
	then
		mkdir "commands"
	fi
	cd "commands"
	
elif [ $2 == "Verification"  ]
then
	if [ ! -d "Verifications" ]
	then
		mkdir "Verifications"
	fi
	cd "Verifications"
		
fi

#Start work for each command separately
for i in $commands
do 
	#Title storage for each command
	title="$i"
	if [ ! -e $i"_""$2.txt" ]
	then
		touch $i"_""$2.txt"	
	fi
 	#Unpack the file if it contains old data
	echo > $i"_""$2.txt"
	echo -e "${BOLD}$title Command:${NORMAL}" >> $i"_""$2.txt"
	#NAME Command title with BOLD feature
	echo "________________	_________________________________________________________________________________________________________________________________________________________________________________________________" >> $i"_""$2.txt"
	#Extract the command name in man
	man $i | awk '/^NAME$/,/^DESCRIPTION$/'  > tempData
	GeneratCellName "NAME" "tempData" $i"_""$2.txt"
	
	echo >> $i"_""$2.txt"
	
	echo "________________	_________________________________________________________________________________________________________________________________________________________________________________________________" >> $i"_""$2.txt"
	#Storing data in a Data file in order to apply Commands to it
	echo -e "Israel:\nThe Israeli occupation is a brutal occupation\nIsrael is a war criminal\nPalestine:\nJerusalem is Palestines capital" > Data1.txt
	#For each command, a file is created
	case $i
	in
		grep)   
			#Extract the DESCRIPTION of the command in question
			man "grep" | awk '/^DESCRIPTION$/,/^OPTIONS$/' | grep -v '^OPTIONS$' | grep -v '^DESCRIPTION$' > tempData
			#Extract the version of the command in question
			grep --version | sed -n '1p' > verFile 
			
			#Prepare an example of using Command
			echo 'echo -e "The Israeli occupation is a brutal occupation\\nJerusalem is Palestines capital\\nIsrael is a war criminal" > Data1.txt !grep "Israel" Data1.txt' > Example
			#Apply the example and store the result
			grep "Israel" Data1.txt > result
			;;
			
		awk)    
			#Extract the DESCRIPTION of the command in question
			man "awk" | awk '/^DESCRIPTION$/,/^OPTIONS$/' | sed -n '1,4p' | grep -v '^DESCRIPTION$' > tempData
			#Extract the version of the command in question
			awk -W versio 2>&1 | sed -n '1p'  > verFile			
			#Prepare an example of using Command
			echo 'echo -e "Israel:\\nThe Israeli occupation is a brutal occupation\\nIsrael is a war criminal\\nPalestine:\\nJerusalem is Palestines capital" > Data1.txt !awk '/^Israel:$/,/^Palestine:$/' Data1.txt' > Example
			#Apply the example and store the result
			awk '/^Israel:$/,/^Palestine:$/' Data1.txt > result
			;;
		
		sed) 
			#Extract the DESCRIPTION of the command in question
			man sed | awk '/^DESCRIPTION$/,/SEE/' | sed -n '1,4p' | grep -v '^DESCRIPTION$' > tempData 
			#Extract the version of the command in question
			sed --version | sed -n '1p' > verFile		
			#Prepare an example of using Command
			echo 'echo -e "Israel:\\nThe Israeli occupation is a brutal occupation\\nIsrael is a war criminal\\nPalestine:\\nJerusalem is Palestines capital" > Data1.txt !sed -n "2,3p" Data1.txt' > Example
			#Apply the example and store the result
			sed -n "2,3p" Data1.txt > result
				;;

		mv) 
			#Extract the DESCRIPTION of the command in question
			man mv | awk '/^DESCRIPTION$/,/SEE/' | sed -n '1,4p'| grep -v '^DESCRIPTION$' > tempData 
			#Extract the version of the command in question
			mv --version | sed -n '1p' > verFile
			#Prepare an example of using Command
			echo 'touch File1.txt!ls File1.txt > /dev/null 2>&1!echo $?!mv File1.txt File2.txt!ls File1.txt > /dev/null 2>&1!echo $?' > Example
			#Apply the example and store the result
			touch File1.txt
			ls File1.txt > /dev/null 2>&1
			echo $? > echo
			res1=$(cat echo)
			mv File1.txt File2.txt
			ls File1.txt > /dev/null 2>&1
			echo $? > echo
			res2=$(cat echo)
			ls File2.txt > /dev/null 2>&1
			echo $? > echo
			res3=$(cat echo)
			if [ $res1 -eq 0 -a $res3 -eq 0 ]
			then 
				res1="Zero"
				res3="Zero"			
			fi
			if [ $res2 -ne 0 ]
			then 
				res2="Positive"			
			fi
			res="output1(echo \$?):"$res1", output2(echo \$?):"$res2", output3(echo \$?):"$res3
			echo $res > result
			rm File2.txt
			rm echo
			;;

		rename) 
			#Extract the DESCRIPTION of the command in question
			man rename | awk '/^DESCRIPTION$/,/SEE/' | sed -n '1,5p' | grep -v '^DESCRIPTION$' > tempData   
			#Extract the version of the command in question
			rename --version | cut -d" " -f3-8 > verFile
			#Prepare an example of using Command
			echo 'touch File1.csv!touch File2.csv!ls File1.csv > /dev/null 2>&1!echo $?!ls File2.csv > /dev/null 2>&1!echo $?!rename 's/\.csv$/.txt/' *.csv!ls File1.csv > /dev/null 2>&1!echo $?!ls File2.csv > /dev/null 2>&1!echo $?!ls File1.txt > /dev/null 2>&1!echo $?!ls File2.txt > /dev/null 2>&1!echo $?' > Example
			#Apply the example and store the result
			touch File1.csv
			touch File2.csv
			ls File1.csv > /dev/null 2>&1
			echo $? > echo
			res1=$(cat echo)
			ls File2.csv > /dev/null 2>&1
			echo $? > echo
			res2=$(cat echo)
			rename 's/\.csv$/.txt/' *.csv
			ls File1.csv > /dev/null 2>&1
			echo $? > echo
			res3=$(cat echo)
			ls File2.csv > /dev/null 2>&1
			echo $? > echo
			res4=$(cat echo)
			ls File1.txt > /dev/null 2>&1
			echo $? > echo
			res5=$(cat echo)
			ls File2.txt > /dev/null 2>&1
			echo $? > echo
			res6=$(cat echo)
			if [ $res1 -eq 0 -a $res3 -eq 0 ]
			then 
				res1="Zero"
				res2="Zero"
				res5="Zero"
				res6="Zero"			
			fi
			if [ $res2 -ne 0 ]
			then 
				res3="Positive"	
				res4="Positive"		
			fi
			res="output1,2(echo \$?):""$res1,$res2"", output3,4(echo \$?):""$res3,$res4"", output5,6(echo \$?):""$res5,$res6"
			echo $res > result
			rm File1.txt
			rm File2.txt
			rm echo
			;;    	

		touch) 
			#Extract the DESCRIPTION of the command in question
			man touch | awk '/^DESCRIPTION$/,/SEE/' | sed -n '1,2p' | grep -v '^DESCRIPTION$' > tempData 
			#Extract the version of the command in question
			touch --version | sed -n '1p' > verFile
			#Prepare an example of using Command
			echo 'rm File.txt > /dev/null 2>&1!ls File.txt > /dev/null 2>&1!echo $?!touch File.txt!File.txt > /dev/null 2>&1!echo $?' > Example
			#Apply the example and store the result
			rm File.txt > /dev/null 2>&1
			ls File.txt > /dev/null 2>&1
			echo $? > echo
			res1=$(cat echo)
			touch File.txt
			ls File.txt > /dev/null 2>&1
			echo $? > echo
			res2=$(cat echo)
			if [ $res2 -eq 0 ]
			then 
				res2="Zero"			
			fi
			if [ $res1 -ne 0 ]
			then 
				res1="Positive"			
			fi
			res="output1(echo \$?):"$res1", output2(echo \$?):"$res2
			echo $res > result
			
			rm echo
			rm File.txt
			;;

		chmod)  
			#Extract the DESCRIPTION of the command in question	
			man chmod | awk '/^DESCRIPTION$/,/^SEE$/' | sed -n '1,3p' | grep -v '^DESCRIPTION$' > tempData
			#Extract the version of the command in question
			chmod --version | sed -n '1p' > verFile
			#Prepare an example of using Command
			echo 'rm file > /dev/null 2>&1!touch file!echo $?!ls -l file | cut -d" " -f1!chmod +x file!ls -l file | cut -d" " -f1' > Example
			#Apply the example and store the result
			rm file > /dev/null 2>&1
			touch file
			ls -l file | cut -d" " -f1 > touch
			res1=$(cat touch)
			chmod +x file
			ls -l file | cut -d" " -f1 > touch
			res2=$(cat touch)
			res="output1:"$res1", output2:"$res2
			echo $res > result
			
			
			rm touch 
			rm file
			;;

		find) 
			#Extract the DESCRIPTION of the command in question
			man find | awk '/^DESCRIPTION$/,/^SEE$/' | sed -n '1,4p' | grep -v '^DESCRIPTION$' > tempData
			#Extract the version of the command in question
			find --version | sed -n '1p' > verFile 
			#Prepare an example of using Command
			echo 'mkdir dirictore!touch dirictore/file1.csv!touch dirictore/file2.csv!find . -type f -name "dirictore/*.csv"' > Example
			#Apply the example and store the result
			mkdir dirictore
			touch dirictore/file1.csv
			touch dirictore/file2.csv
			find ./dirictore -type f -name "*.csv" > result 
	
			rm -r dirictore
			;;

		cat)  
			#Extract the DESCRIPTION of the command in question
			man cat | awk '/^DESCRIPTION$/,/^SEE$/' | sed -n '1,4p' | grep -v '^DESCRIPTION$' > tempData
			#Extract the version of the command in question
			cat --version | sed -n '1p' > verFile
			#Prepare an example of using Command
			echo 'echo "Hello World" > test.txt!cat test.txt' > Example
			#Apply the example and store the result
			echo "Hello World" > test.txt
			cat test.txt > result
			
			rm test.txt
			;;

		rev)  
			#Extract the DESCRIPTION of the command in question
			man rev | awk '/^DESCRIPTION$/,/^OPTIONS$/' | grep -v '^DESCRIPTION$' | grep -v '^OPTIONS$' > tempData 
			#Extract the version of the command in question
			rev --version > verFile
			#Prepare an example of using Command
			echo 'echo -e "Hello World\\nGood Job" > test.txt!rev test.txt' > Example
			#Apply the example and store the result
			echo -e "Hello World\nGood Job" > test.txt
			rev test.txt > result
			
			rm test.txt
			;;

		tac) 
			#Extract the DESCRIPTION of the command in question
			man tac | awk '/^DESCRIPTION$/,/^SEE$/' | sed -n '1,2p' | grep -v '^DESCRIPTION$' > tempData
			#Extract the version of the command in question
			tac --version | sed -n '1p' > verFile 
			#Prepare an example of using Command
			echo 'echo -e "Hello World\\nGood Job" > test.txt!rev test.txt' > Example
			#Apply the example and store the result
			echo -e "Hello World\nGood Job" > test.txt
			tac test.txt > result
			rm test.txt
			;;

		echo)  	
			#Extract the DESCRIPTION of the command in question
			man echo | awk '/^DESCRIPTION$/,/^SEE$/' | sed -n '1,2p' | grep -v '^DESCRIPTION$' > tempData
			#Extract the version of the command in question
			echo=$(which echo)
		    $echo --version | sed -n '1p' > verFile 
		    #Prepare an example of using Command
		    echo 'echo -e "Hello World\\nGood Job"' > Example
		    #Apply the example and store the result
		    echo -e "Hello World\nGood Job" > result
		        
		        ;;

		printf)  
			 #Extract the DESCRIPTION of the command in question
			 man printf | awk '/^DESCRIPTION$/,/^SEE$/' | sed -n '1,2p' | grep -v '^DESCRIPTION$' > tempData
			 #Extract the version of the command in question
			 printf=$(which printf)
		         $printf --version | sed -n '1p' > verFile
		         #Prepare an example of using Command
		         echo 'printf "The hexadecimal value for %d is %x" 30 30' > Example
		         #Apply the example and store the result
		         printf "The hexadecimal value for %d is %x" 30 30 > result
		        
		         ;; 

		column)  
			#Extract the DESCRIPTION of the command in question
			man column | awk '/^DESCRIPTION$/,/^OPTIONS$/' | grep -v '^DESCRIPTION$' | grep -v '^OPTIONS$' > tempData 
			#Extract the version of the command in question
			column --version > verFile
			#Prepare an example of using Command
			echo 'echo -e "NAME: ID:\\nJehadHamayel 1200348\\nBasheerArouri 1201141" > data.txt!column -t data.txt' > Example
			#Apply the example and store the result
			echo -e "NAME: ID:\nJehadHamayel 1200348\nBasheerArouri 1201141" > data.txt
			column -t data.txt > result
			rm data.txt
			;;
	
		sort)  
			#Extract the DESCRIPTION of the command in question
			man sort | awk '/^DESCRIPTION$/,/^SEE$/' | sed -n '1,2p' | grep -v '^DESCRIPTION$' > tempData 
			#Extract the version of the command in question
			sort --version | sed -n '1p' > verFile 
			#Prepare an example of using Command
			echo 'echo -e "JehadHamayel 1200348\\nBasheerArouri 1201141\\nAhmadNasser 1235556" > data.txt!sort data.txt' > Example
			echo -e "JehadHamayel 1200348\nBasheerArouri 1201141\nAhmadNasser 1235556" > data.txt
			#Apply the example and store the result
			sort data.txt > result 
			
			rm data.txt
			;;

	esac	
#Create the file using the function that was created to store the cells
GeneratCellDESCRIPTION "DESCRIPTION" "tempData" $i"_""$2.txt"
GeneratCellVersion $i"_""$2.txt" "VERSION" "verFile"	
GeneratCellExamples $i"_""$2.txt" "Example" "EXAMPLE" "result"		
GeneratCellRelatedCommands $i $i"_""$2.txt" "Related Commands" "Rtemp"
rm Data1.txt 
if [ "$2" == "command" ]
then
	echo "************************************************************************************************"
	cat $i"_""$2.txt"
	echo "************************************************************************************************"
fi

done
cd ..		
}

#Function creates a file from the man with the latest password information
Verification(){
if [  -d "$1" ]
then
	#Extract file names
	ls -l ./$1/*.txt | cut -d" " -f10 > Commands
	ls -l ./$2/*.txt | cut -d" " -f10 > Verification
	#Take the command command and compare it with each other
	local i=1
	ip=$i"p"
	C=$(sed -n "$ip" Commands)
	V=$(sed -n "$ip" Verification)
	
	while [ -n "$C" ]
	do 
		#Get file content
		c=$(cat $C)
		v=$(cat $V)
		#Compare matches file content
		if [ "$c" == "$v" ] 
		then
			echo "_____________________________________________________________________________________________________________________________________________________________________________________________________________________"  
			echo -e "\nVerified $C with $V\n"
			echo "_____________________________________________________________________________________________________________________________________________________________________________________________________________________"  
			
		else  
			echo "_____________________________________________________________________________________________________________________________________________________________________________________________________________________"  

			echo -e "\nNot Verified $C with $V in:"
			sections=("NAME" "DESCRIPTION" "VERSION" "OUTPUT" "Related Commands")
			#Know the location of the difference and print the clip where the difference is located
			for S in "${sections[@]}"
			do
				#Take part by part to examine
				x=$(awk "/$S/,/_/" $C | grep -v "_")
				y=$(awk "/$S/,/_/" $V | grep -v "_")

				if [ "$x" != "$y" ]
				then
					if [ "$S" != "OUTPUT" ] 
					then
					echo "__________________________________________________________________________________________"
						echo "Not verified in $S:"
						echo -e "\nThe $S Before: "
						printf "$x\n\n"
						echo "The $S After: "
						printf "$y\n\n"
						echo "__________________________________________________________________________________________"
					else
						echo "__________________________________________________________________________________________"
						echo "Not verified in $S:"
						x=$(awk "/EXAMPLE/,/_/" $C | grep -v "_")
						echo -e "\nThe EXAMPLE: "
						printf "$x\n"
						x=$(awk "/OUTPUT/,/_/" $C | grep -v "_")
						echo -e "The OUTPUT Before: "
						printf "$x\n"
						
						y=$(awk "/OUTPUT/,/_/" $V | grep -v "_")
						echo -e "\nThe OUTPUT After: "
						printf "$y\n\n"
						echo "__________________________________________________________________________________________"
					fi
				fi
			done
		fi
		i=$((i + 1))
		ip=$i"p"
		C=$(sed -n "$ip" Commands)
		V=$(sed -n "$ip" Verification)
	done
	rm Commands
	rm Verification
	
fi
}

#Create commands classification groups
rename_Array=()
Filtering_Search_Scanning_Array=()
Change_Modifay_Array=()
Sort_In_spicificWay=()
Print_Standard=()

#A function specialized in preparing the Recommendation when calling a specific command
GeneratTheRecommendation(){
rename_Array=()
Filtering_Search_Scanning_Array=()
Change_Modifay_Array=()
Sort_In_spicificWay=()
Print_Standard=()
#Storing common command names in specific properties
res=$(grep "rename" ./commands/*.txt | cut -d":" -f1 | uniq | cut -d"/" -f3 | cut -d"." -f1)
for i in $res
do
	rename_Array+=("$i")
done
res=$(grep -E "scan|search|filter" ./commands/*.txt | cut -d":" -f1 | uniq | cut -d"/" -f3 | cut -d"." -f1)
for i in $res
do
	Filtering_Search_Scanning_Array+=("$i")
done
res=$(grep "change" ./commands/*.txt | cut -d":" -f1 | uniq | cut -d"/" -f3 | cut -d"." -f1)
for i in $res
do
	Change_Modifay_Array+=("$i")
done
res=$(grep "sort" ./commands/*.txt | cut -d":" -f1 | uniq | cut -d"/" -f3 | cut -d"." -f1)
for i in $res
do
	Sort_In_spicificWay+=("$i")
done

res=$(grep -E "print|display|standard output" ./commands/*.txt | cut -d":" -f1 | uniq | cut -d"/" -f3 | cut -d"." -f1)
for i in $res
do
	Print_Standard+=("$i")
done
}

#Function to print the index arranged on the basis of functionality
Commands_index(){
echo "__________________________________________________________________________________________"
echo -e "${BOLD}(Commands Index)${NORMAL}"
echo  "----------------"
echo "--> Special commands for printing, display, and standard output:" 
local num=1
for index in "${Print_Standard[@]}" 
do
    echo "$num) $index"
    num=$((num+1))
done 
echo
echo "--> Special commands in sorting and printing in specific way:"
num=1
for index in "${Sort_In_spicificWay[@]}" 
do
    echo "$num) $index"
    num=$((num+1))
done
echo
echo "--> Special commands for creating files and changing the file mode:"
num=1
for index in "${Change_Modifay_Array[@]}" 
do
    echo "$num) $index"
    num=$((num+1))
done

echo
echo "--> Special commands in filtering, searching, and scanning:"
num=1
for index in "${Filtering_Search_Scanning_Array[@]}" 
do
    echo "$num) $index"
    num=$((num+1))
done

echo
echo "--> Special commands in renaming and moving the file location:"
num=1
for index in "${rename_Array[@]}" 
do
    echo "$num) $index"
    num=$((num+1))
done
echo "__________________________________________________________________________________________"
}

#Action to search for a command among the created files and give the Recommendation to the command if it exists
SearchForCommand(){
echo "Enter The name of the command that you want to find:"
read SearchCommand
#Search created files by name command calling
find ./commands/ -name "$SearchCommand"_command.txt | cut -d"/" -f3 | cut -d"." -f1  > res
res=$(cat res)
if [ -n "$res" ]
then
	#Search each group, and if found, the group will be printed
	echo "_________________________________________________________________________________________________________________________________________________________________________________________________"
	cat ./commands/$res".txt"
	echo "_________________________________________________________________________________________________________________________________________________________________________________________________"
	
	echo -e "The  Recommended Command:\n------------------------"
	found="false"
	recomanded=""
	for i in "${rename_Array[@]}"
	do
	
		if [ "$i" == "$res" ]
		then	
			found="true"	
		fi
		recomanded="$recomanded\n$i"
	done
	if [ "$found" == "true" ]
	then 
		echo "From the Special commands in renaming and moving the file location:"
					
		echo -e "$recomanded\n"
	fi
	found="false"
	recomanded=""
	for i in "${Filtering_Search_Scanning_Array[@]}"
	do
		if [ "$i" == "$res" ]
		then	
			found="true"	
		fi
		recomanded="$recomanded\n$i"
	done
	if [ "$found" == "true" ]
	then 
		echo "Special commands in filtering, searching, and scanning:"
		echo -e "$recomanded\n"
	fi
	found="false"
	recomanded=""
	for i in "${Change_Modifay_Array[@]}"
	do
		if [ "$i" == "$res" ]
		then	
			found="true"	
		fi
		recomanded="$recomanded\n$i"
	done
	if [ "$found" == "true" ]
	then 
		echo "From the Special commands for creating files and changing the file mode:"
		echo -e "$recomanded\n"
	fi
	found="false"
	recomanded=""
	for i in "${Sort_In_spicificWay[@]}"
	do
		if [ "$i" == "$res" ]
		then	
			found="true"	
		fi
		recomanded="$recomanded\n$i"
	done
	if [ "$found" == "true" ]
	then 
		echo "From the Special commands in sorting and printing in specific way:"
		echo -e "$recomanded\n"
	fi
	found="false"
	recomanded=""
	for i in "${Print_Standard[@]}"
	do
		if [ "$i" == "$res" ]
		then	
			found="true"	
		fi
		recomanded="$recomanded\n$i"
	done
	if [ "$found" == "true" ]
	then 
		echo "From the Special commands for printing, display, and standard output:"
		echo -e "$recomanded\n"
	fi
	echo "_________________________________________________________________________________________________________________________________________________________________________________________________"
	else 
		echo "__________________________________________________________________________________________"
		echo "The File NOT exist"
		echo "__________________________________________________________________________________________"
		grep "Related Commands" ./commands/*.txt | grep "\<$SearchCommand\>" | cut -d" " -f1 | cut -d"/" -f3 | cut -d":" -f1 | cut -d"." -f1 > res
		res=$(cat res)
		
		if [ -n "$res" ]
		then
			echo "But This some Related Commands to the Searched Command:" 
			echo -e "$res\n"
			echo "__________________________________________________________________________________________"
		fi		
fi
		
rm res

}

fileName=''
#Flags to ensure that Create a manual for the files and create the Recommendation
flagGenerat=0
flagRec=0
while true
do
	echo "Enter the name of an input file"
	read fileName
	content=$(cat $fileName)
        #Check statement to check if the file exists and that it is a ordinary file
        if [ ! -e "$fileName" -o ! -f "$fileName" ]
        then 
                echo
                echo "file is not exist Enter the name of an input file"
                continue
                echo
                echo "-----------------------------------------------------------"
        #check the file is empty or not
        elif [ "$content" = "" ]
        then
                echo
                echo "file is empty"
                echo
                echo ----------------------------------------------------------- 
        else
        #the main menu
		echo "Choose what you want from the following list by choosing the number of it:"
		echo "1)Generate Linux/Unix Command Manual For some commands."
		echo "2)Verification The Commands."
		echo "3)Print the Commands index."
		echo "4)Search for Command."
		echo "5)exit"
		read choice
		while true
		do
		if [ -d commands -a $flagRec -eq 0 ]
		then
			#create the Recommendation
			flagRec=1
			flagGenerat=1
			GeneratTheRecommendation
		
		fi
			if [ $choice -eq "1" ]
			then	
				echo "Please wait for the files of the Commands Manual to be created"
				Generater_Of_Command_Manual $fileName "command"
				flagGenerat=1
				flagRec=0
				echo "__________________________________________________________________________________________"
				echo "The Generation of the Command Manual Done"
				echo "__________________________________________________________________________________________"
				
			elif [ $choice -eq "2" ]
			then
				if [ $flagGenerat -ne 1 ]
				then
					echo "Please Generate Linux/Unix Command Manual First"	
				else
					echo "Please wait for the files of the Verification Commands Manual to be created"
					Generater_Of_Command_Manual $fileName "Verification"
					
					echo "__________________________________________________________________________________________"
					echo "The Generation of the Verification Command Manual Done"
					echo "__________________________________________________________________________________________"
					
					echo  "The Verification results:"
					
					Verification "commands" "Verifications"	
				fi
				
			elif [ $choice -eq "3" ]
			then	
				if [ $flagGenerat -ne 1 ]
				then
					echo "Please Generate Linux/Unix Command Manual First"	
				else
					Commands_index	
				fi
				
			elif [ $choice -eq "4" ]
			then
				if [ $flagGenerat -ne 1 ]
				then
					echo "Please Generate Linux/Unix Command Manual First"	
				else
					SearchForCommand
				fi
			elif [ $choice -eq "5" ]
			then
				break 2
			else
				echo "Please choose one of the choices"
					
			fi
		echo "Choose what you want from the following list by choosing the number of it:"
		echo "1)Generate Linux/Unix Command Manual For some commands."
		echo "2)Verification The Commands."
		echo "3)Print the Commands index."
		echo "4)Search for Command by Name."
		echo "5)exit"
		read choice	
		
		done
	
	fi	

done

