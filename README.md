# Gutenhash Challenge
Find the hashed-string needle in the haystack of text from Project Gutenberg

## Datasets
* Big Dataset - 12 GB Gzip archive containing most English TXT files from Project Gutenberg
  * [Magnet Link](magnet:?xt=urn:btih:992f2d347a182e48a6aa9c5a2bfc39b665b2c469&dn=books.tar.gz)
* Small Dataset - 680MB ISO containing a smaller subset of eBooks from Project Gutenberg
  * [Magnet Link](magnet:?xt=urn:btih:35476861704f8088828dd1a0918cc6fee714ac3b&dn=smolbooks.iso)
Problem Statement {#problem_statement}
-----------------

Find the substring in the set of books from Project Gutenberg that md5
hashes to the given hash.

Acquiring and Cleaning the Dataset {#acquiring_and_cleaning_the_dataset}
----------------------------------

### Download the Files from Project Gutenberg {#download_the_files_from_project_gutenberg}

We typically use the PG2003-08.ISO 700MB dataset for searching located
at <https://www.gutenberg.org/ebooks/11220>

`$ wget `[`https://www.gutenberg.org/files/11220/PG2003-08.ISO`](https://www.gutenberg.org/files/11220/PG2003-08.ISO)

### Flatten the Directory Structure {#flatten_the_directory_structure}

These next commands will pull all the text files out of their
directories and place them in the root, and then delete the empty
directories.

`$ find /local/directory -type f -iname "*.txt" -exec mv '{}' /local/directory ';'`

`$ find /local/directory -type d -empty -delete`

### Compress the Files Into a Tarball {#compress_the_files_into_a_tarball}

`$ tar --remove-files -cvzf archive.tar.gz /local/directory/*.txt`

or if you have [`pigz`](https://zlib.net/pigz/) (Parallel Implementation
of GZip) and `pv` installed:

`$ tar --remove-files --use-compress-program="pigz --best --recursive | pv" -cf archive.tar.gz /local/directory/*.txt`

How to Solve {#how_to_solve}
------------

### Hash Generator {#hash_generator}

Choose a 19-character substring from one of the .txt files

` $ function generateMD5() {`\
`     offset=$[$RANDOM$RANDOM$RANDOM%$(cat $1|wc -c)];`\
`     substr=$(dd if="$1" bs=1 skip=$offset count=$2 2>/dev/null)`\
`     echo -ne "file: $1\noffset: $offset\nsubstring: '$substr'\nhash: "`\
`     echo -n $substr|md5`\
`   }`\
` $ generateMD5 /home/pi/data/01/etext02.txt 19`\
` file: /home/pi/data/01/etext02.txt`\
` offset: 72`\
` substring: 'blah blah blah blah'`\
` hash: d41d8cd98f00b204e9800998ecf8427e`

### Trivial Solution {#trivial_solution}

File: gutenhash\_streamer.py

` import md5`\
` import sys`\
` `\
` target = sys.argv[1]`\
` strlen = int(sys.argv[2])`\
` file_handle = sys.stdin`\
` `\
` file_contents = file_handle.read()`\
` last_possible_index = len(file_contents) - (strlen - 1)`\
` for i in range(0, last_possible_index):`\
`   substr = file_contents[i:i+strlen-1]`\
`   md5sum = md5.md5(unicode(substr)).hexdigest()`\
`   if md5sum == target:`\
`     print("found!: '{}'".format( substr ))`\
`     sys.exit(0)`

Print some text file out using \`cat\` and bind cat\'s STDOUT pipe to
gutenhash\_streamer.py\'s STDIN pipe:

` $ cat u/etext09/somefile.txt | python gutenhash_streamer.py c29c193a59d27ed00448b204579a0874 8`\
` found!: '34567890'`

Use the \`find\` command to print all text files to STDOUT and bind the
pipe to gutenhash\_streamer.py\'s STDIN pipe:

` $ find u/ -iname "*.txt" -exec cat {} \; | python gutenhash_streamer.py c29c193a59d27ed00448b204579a0874 8`\
` found!: '34567890'`

This trivial streaming python solution: 1. imports the \*md5\* and
\*sys\* libraries, we use \*sys\* for command line arguments, the file
handle for \*stdin\*, and exiting the process. 2. parses the target hash
(as a string) and substring length (as an int) 3. reads all of \*stdin\*
into the \*file\_contents\* variable in memory 4. loops over all
possible starting indexes for substrings and uses \*md5()\* to get the
hash, then tests it against the \*target\* hash, and exits if it
matches. (we use \*unicode()\* here because \*md5.md5()\* requires
unicode).

Your challenge is to make this performant and parallelizable!

During Competition {#during_competition}
------------------

The substring length and file will change during competition.

The hashing algorithm will always be md5sum, and the dataset will always
be the PG2003-08.ISO file.
