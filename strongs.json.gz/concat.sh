#! /bin/bash

echo '{' >>strongs_all.json
for i in $(find .); do
    if [ $i == './concat.sh' ]; then
        continue
    fi

    if [ $i == '.' ]; then
        continue
    fi

    if [ $i == './strongs_all.json' ]; then
        continue
    fi

    FILE=${i#./}
    FILE=${FILE%.json.gz}
    echo "\"${FILE}\"": >>strongs_all.json
    zcat $i >>strongs_all.json
    echo ',' >>strongs_all.json
done

# delete last comma and new line add in closing curly brace
truncate -s-2 strongs_all.json
echo '}' >> strongs_all.json
gzip -c strongs_all.json > strongs_all.json.gz

