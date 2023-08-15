#!/bin/bash

COUNT=10

while(( COUNT > 0 )); do
    echo "Count: ${COUNT}"
    (( COUNT -- ))             # es toxi vra moracel ei (( )) dnel
done

