# Author: Amar Gill
# date: 2024-03-07

all: docs/prediction_report.qmd



# Runs the data.R script that reads the data from the data source and saves it to the data folder under raw_Data.csv
data/raw_data.csv	:	src/data.R
	Rscript src/data.R --url=https://archive.ics.uci.edu/static/public/332/online+news+popularity.zip \
		--output=data/

# Runs the preprocessing.R script that cleans the data and splits the dataset into training and testing sets
# Saves data to clean_Data.csv, training_Data.csv, and testing_Data.csv in the data folder.
data/clean_data.csv data/training_data.csv data/testing_data.csv	:	src/preprocessing.R	data/raw_data.csv
	Rscript src/preprocessing.R --data=data/raw_data.csv \
		--output=data/

# Runs the EDA.R script to create the figures (boxplot and histograms) and saves them in the figs folder
figs/images.png figs/links.png figs/shares.png figs/videos.png data/num_obs_training.csv	:	src/EDA.R	data/training_data.csv
	Rscript src/EDA.R --data=data/training_data.csv \
		--output=figs/

# Runs the knn.R script to define the recipe, specification, perform cross-validation, choose best k value after
# looking at the best k plot, re-defining the specification based on the best k value and fitting the training data.
# Finally, the workflow is tested on the testing data and the confusion matrix and accuracy are considered.
src/objects/conf_mat.rds data/model_accuracy.csv	:	src/knn.R data/training_data.csv
	Rscript src/knn.R --data=data/training_data.csv \
		--output=src/

# Saves the prediction report to the docs folder after rendering it from the prediction_report.qmd file
# generated from its dependencies
docs/prediction_report.qmd	: data/training_data.csv data/testing_data.csv \
figs/images.png figs/links.png figs/shares.png data/num_obs_training.csv \
figs/videos.png src/objects/conf_mat.rds data/model_accuracy.csv
	quarto render prediction_report.qmd --to html



# clean
clean:
	rm -rf figs
	rm -rf data
	rm -rf src/objects
	rm -rf docs