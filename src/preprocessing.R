# documentation comments
"This script processes the data for EDA and the KNN model.

Usage: src/preprocessing.R --data=<data> --output=<output>

Options:
--data=<data> path to .csv
--output=<output> Destination folder Ex: data/
" -> doc

# import libraries/packages
suppressMessages(library(tidyverse))
suppressWarnings(library(docopt))
suppressMessages(suppressWarnings(library(tidymodels)))

# parse/define command line arguments here
opt <- docopt(doc)

# define main function

main <- function(data, output){
    data1 <- toString(data)
    output1 <- toString(output)
    fullData <- suppressMessages(read_csv(data1))
    clean_Data <- fullData |>
      select(shares, num_hrefs, num_imgs, num_videos) |>
      mutate(is_popular = ifelse(shares < 1400, 0, 1)) |>
      mutate(is_popular = as.factor(is_popular))
    write_csv(clean_Data, paste(output1, 'clean_Data.csv', sep = ''))
    set.seed(2024)
    data_split <- initial_split(clean_Data, prop = 0.6, strata = is_popular)
    training_Data <- training(data_split)
    testing_Data <- testing(data_split)
    write_csv(training_Data, paste(output1, 'training_Data.csv', sep = ''))
    write_csv(testing_Data, paste(output1, 'testing_Data.csv', sep = ''))
}

# code for other functions & tests goes here

# call main function
main(opt$data, opt$output) # pass any command line args to main here