#!/usr/bin/env bash
while getopts a:n:u:t: flag
do
    case "${flag}" in
        a) author=${OPTARG};;
        n) name=${OPTARG};;
        u) urlname=${OPTARG};;
        t) title=${OPTARG};;
    esac
done

echo "Author: $author";
echo "Project Name: $name";
echo "Project URL name: $urlname";
echo "Title: $title";

echo "Renaming app note..."

original_author="author_name"
original_name="AN0xxxx" # Note, we ignore case
original_urlname="project_urlname"
original_title="app_note_title"

# for filename in $(find . -name "*.*")
for filename in $(git ls-files)
do
    sed -i "s/$original_author/$author/g" $filename
    sed -i "s/$original_name/$name/gI" $filename
    sed -i "s/$original_urlname/$urlname/g" $filename
    sed -i "s/$original_title/$title/g" $filename

    # Clean up readme (probably should only run on that file...)
    sed -i '/HOW TO USE THIS TEMPLATE/,/THIS MESSAGE WILL SELF DESTRUCT/d' $filename
    echo "Renamed $filename"
done

mv app_an0xxxx "app_$name"
mv doc/rst/an0xxxx.rst "doc/rst/$name.rst"

# This command runs only once on GHA!
rm -rf .github/template.yml

# Remove all the rename files
rm -rf .github/rename_project.sh
rm -rf .github/workflows/rename_project.yml
