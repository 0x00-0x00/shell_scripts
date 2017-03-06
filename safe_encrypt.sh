#!/bin/bash

file=$1

if [ "$file" == "" ]; then
    echo "Usage: $0 <FILE>"
    exit
fi

original_md5=$(md5sum $file | awk {'print $1'})

function report
{
    if [[ $1 != 0 ]]; then
        echo "\033[33mFAIL\033[0m";
    else
        echo "\033[32mOK\033[0m";
    fi

}

#  Encrypt data
echo -n "[*] Encrypting data ... "
crypt --encrypt --file $file -k > /dev/null 2>&1
report $?
sleep 1

# Copy encrypted data to temporary folder
cp $file.enc /tmp
cd /tmp

# Decrypt the data and generate md5sum of decryption product.
crypt --decrypt --file $file.enc -k > /dev/null 2>&1
report $?
sleep 1
dec_md5=$(md5sum $file | awk {'print $1'})


echo -n "[*] Integrity checkage ... "
if [[ $original_md5 == $dec_md5 ]]; then
    echo "\033[32mOK\033[0m";


    echo -n "[*] Deleting data traces ..."
    #  Delete all traces of the data from temporary folder
    shred -uz /tmp/$file*

    cd - > /dev/null 2>&1
    #  Delete the original data
    shred -uz $file

    if [[ -e "/tmp/$file" ]]; then
        echo " \033[33mFAIL\033[0m";
    else
        echo " \033[32mOK\033[0m";
    fi


else
    echo "\033[33mFAIL\033[0m";
fi

exit

