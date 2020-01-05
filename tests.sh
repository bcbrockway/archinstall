assert ()                 #  If condition false,
{                         #+ exit from script
                          #+ with appropriate error message.
  E_PARAM_ERR=98
  E_ASSERT_FAILED=99


  if [ -z "$2" ]          #  Not enough parameters passed
  then                    #+ to assert() function.
    return $E_PARAM_ERR   #  No damage done.
  fi

  lineno=$2

  if [ ! $1 ] 
  then
    echo "Assertion failed:  \"$1\""
    echo "File \"$0\", line $lineno"    # Give name of file and line number.
    exit $E_ASSERT_FAILED
  # else
  #   return
  #   and continue executing the script.
  fi  
}

source ./common.sh

# Try to copy from parent folder
touch ../DELETE_ME
copy ../DELETE_ME
rc=$?
assert "$rc -eq 10" $LINENO
rm ../DELETE_ME

# Try to copy from home folder
touch ~/DELETE_ME
copy ~/DELETE_ME
rc=$?
assert "$rc -eq 10" $LINENO
rm ~/DELETE_ME

# Try to copy from root folder
touch /tmp/DELETE_ME
copy /tmp/DELETE_ME
rc=$?
assert "$rc -eq 10" $LINENO
rm /tmp/DELETE_ME

# Try to copy non-existent file
copy FAKE_FILE
rc=$?
assert "$rc -eq 11"

# Copy real file
copy tmp/test1

# Copy existing file
copy tmp/test1
