INSTRUCTIONS

Save the script shared_task.R somewhere on your computer, let's call it X_folder. Unzipped versions of the three zip files should be subfolders of X_folder.

If not already on your computer, download R. Set the working directory to X_folder (click File > Change dir...).

Load the script by writing

source("shared_task.R") 

You can now enter a query as follows:

shared_task("hae","118A Predicative Adjectives","Owens-1985")

It may take around 30 secs per item to get the answer.

Or, assuming an input file of the structure

hae\t118A Predicative Adjectives\tOwens-1985\n
bla\t117A Bla feature\tBlasource-2013\n
...

you can use a wrapper like the following:

x <- read.table(file="myinput.txt", sep="\t", stringsAsfactors=FALSE, comment.char="", quote="")
for (i in 1:length(x[,1])) {
	iso <- x[i,1]
	fea <- x[i,2]
	sou <- x[i,3]
	val <- shared_task(iso, fea, val)
	cat(val, "\n", file="myoutput.txt", append=TRUE)
}

This will give you one value per line in the output file.

If you insist on working through Python you can download the pyper package and do the following:

>>> from pyper import *
>>> r('setwd("D:\Wichmann\Current\DReaM\Shared task\grammar-data-mining")')  # or whereever you put the shared_task.R script
>>> r('source("shared_task.R")')
>>> r('shared_task("hae", "118A Predicative Adjectives", "Owens-1985")')

The output should be something like

'try({shared_task("hae", "118A Predicative Adjectives", "Owens-1985")})\r\n[1] "Nonverbal encoding"\r\nThere were 50 or more warnings (use warnings() to see the first 50)\r\n'

So the answer is "Nonverbal encoding".