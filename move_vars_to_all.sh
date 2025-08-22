#!/bin/bash

# Move all variable files from group_vars/vars/ to group_vars/all/
mkdir -p group_vars/all
mv group_vars/vars/*.yaml group_vars/all/
echo "All variable files moved to group_vars/all/"
