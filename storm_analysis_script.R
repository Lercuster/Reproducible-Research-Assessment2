
library(data.table)
library(ggplot2)

file_url = "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
dest_file = ".\\data\\storm_data.csv.bz2"
if(!file.exists(dest_file)){
    download.file(file_url, dest_file)
}

st_data = as.data.table(read.csv(dest_file))