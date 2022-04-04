#!/bin/bash

set -e

printf "Found files in workspace:\n"
ls

printf "Input abidiff: ${INPUT_ABIDIFF}\n"
printf "Input allow fail: ${INPUT_ALLOW_FAIL}\n"
printf "Looking for Libabigail abidiff install...\n"
which abidiff

COMMAND="abidiff ${INPUT_ABIDIFF}"
echo "${COMMAND}"

# Capture error code and respond appropriately
${COMMAND} || (
   retval=$?
   printf "Return value: $retval\n"  
   echo "::set-output name=retval::${retval}"

   # Failure, but we are allowing it
   if [[ ${retval} -ne 0 ]] && [[ "${INPUT_ALLOW_FAIL}" == "true" ]]; then
       printf "abidiff returned error code, but we are allowing failure. 😅️\n"
       exit 0
   fi       

   # Failure and don't allow it
   if [[ ${retval} -ne 0 ]] && [[ "${INPUT_ALLOW_FAIL}" == "false" ]]; then
       printf "abidiff returned returned error code, there are detected ABI changes. 😭️\n"
       exit $retval
   fi       

   if [[ ${retval} -eq 0 ]]; then
       printf "abidiff returned exit code 0, there are no detected ABI changes. 😁️\n"
       exit $retval
   fi       
)
printf "Return value: $?\n"
