category_num=0
for d in 101_ObjectCategories/*
do
	if [ ! -d $d ]
	then
		echo "$d is not directory" 1>&2
		continue
	fi
	
	count=$(( `ls -1 $d | wc -l` ))
	if [ $1 = test ]
	then
		max=$count
		min=30
	else
		max=30
		min=0
	fi
	#echo $count
	#echo $max
	#echo $min
	for f in "$d"/*
	do
		if [ $count -eq $min ]
		then
			break
		elif [ $count -gt $max ] 
		then
			count=$(( count - 1 ))
			continue
		fi
		# echo $count
		count=$(( count - 1 ))
		if [ ${f##*.} != jpg ]
		then
			echo "$f is not jpg" 1>&2
			continue
		fi
		echo -n "$category_num"" "
		# echo "$f"
		python caffe_script/feature.py ${f} 2> /dev/null
		#python caffe_script/feature.py ${f}
	done
	category_num=$(( category_num + 1 ))
done
