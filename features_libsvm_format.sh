category_num=0
for d in 101_ObjectCategories/*
do
	if [ ! -d $d ]
	then
		echo "$d is not directory" 1>&2
		continue
	fi
		
	for f in "$d"/*
	do
		echo -n "$category_num"" "
		if [ ${f##*.} != jpg ]
		then
			# echo "$f is not jpg" 1>&2
			continue
		fi
		# echo "$f"
		python feature.py ${f} 2> /dev/null
	done
	category_num=`expr $category_num + 1`
done
