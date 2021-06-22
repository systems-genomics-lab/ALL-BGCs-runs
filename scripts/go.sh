
#!/scripts/bash

# set -e
set -u
set -x
# set -o pipefail

PROJECT=/projects/metaBGC/
cd $PROJECT

cat samples.tsv | sed '1d' | while read sample project ;
do
    cd $PROJECT/samples/
    if [ ! -f $sample.SUCCESS ] &&  [ ! -f $sample.FAIL ] ; then
	echo $sample
	# rm -fr $sample/
	# mkdir -p $sample/
	time $PROJECT/scripts/run.sh $sample > $sample.log 2>&1
	
	if [[ ! -f $sample.SUCCESS ]]; then
	    touch $sample.FAIL
	#    rm -fr $sample/
	fi
	
	git add --all
	git commit -am "Processed sample $sample"
	git push
	
	sleep 30
    fi
done
