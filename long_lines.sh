
para_end=0
pre_text_tag=0
pretty_text=0

fileconvert () 
{
while IFS= read -r line
do
        if [[ "$line" == *'<pre class="prettyprint'* ]] || [[ $pretty_text == "1" ]]; then
                echo "${line}"
                pretty_text=1
        fi
        if [[ $pretty_text == "1" ]]; then
                if [[ "$line" == *'</pre>'* ]]; then
                        pretty_text=0
                fi
        fi
        if [[ $pretty_text == "0" ]]; then
                if [[ -z $line ]]; then
                        echo -ne "\n"
                elif [[ "$line" == [[:blank:]][[:blank:]]* ]]; then
                        if [[ $para_end == "1" ]] && [[ $extra_line == "1" ]]; then
                                echo -ne "\n"
                                extra_line=0
                        fi
                        echo -e "${line}"
                elif [[ "$line" == $* ]]; then
                        echo -ne "\n"
                        if [[ $para_end == "1" ]]
                                then echo -ne "\n"
                                para_end=0
                         fi
                else
                        echo -n "${line} "
                        para_end=1
                        extra_line=1
                fi

        fi
done < ${conf_file}.2 >> ${conf_file}

}

for conf_file in ./docs/*/configuration.html
do
	if [[ ! -e ${DIR}/full_line ]]; then 
		echo "Working on ${conf_file}"
		mv ${conf_file} ${conf_file}.2
		echo "Moved file, starting conversion"
		fileconvert 
		sed -i 's/col-lg-12//g' ${conf_file}
		echo "Conversion Complete"
		rm ${conf_file}.2
		DIR="$(dirname "${conf_file}")"
		touch ${DIR}/full_line
		echo "Removed backup"
	else
		echo "Found ${DIR}/full_line skipping"
	fi
done
