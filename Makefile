# Author: Amar Gill
# date: 2024-03-07

all: data/raw_data.csv \
data/share_summary.csv \
data/clean_data.csv \
data/training_data.csv \
data/testing_data.csv \
docs/figs/images.png \
docs/figs/links.png \
docs/figs/shares.png \
docs/figs/videos.png \
data/num_obs_training.csv \
src/objects/knn_fit.rds \
src/objects/conf_mat.rds \
data/model_accuracy.csv \
docs/prediction_report.html



# Runs the data.R script that reads the data from the data source and saves it to the data folder under raw_Data.csv
data/raw_data.csv	:	src/data.R
	Rscript src/data.R --url=https://archive.ics.uci.edu/static/public/332/online+news+popularity.zip \
		--output=data/

#generate csv for shares summary
data/share_summary.csv	:	data/raw_data.csv

# Runs the preprocessing.R script that cleans the data and splits the dataset into training and testing sets
# Saves data to clean_Data.csv, training_Data.csv, and testing_Data.csv in the data folder.
data/clean_data.csv data/training_data.csv data/testing_data.csv	:	src/preprocessing.R	data/raw_data.csv
	Rscript src/preprocessing.R --data=data/raw_data.csv \
		--output=data/


# Runs the EDA.R script to create the figures (boxplot and histograms) and saves them in the figs folder
docs/figs/images.png docs/figs/links.png docs/figs/shares.png docs/figs/videos.png data/num_obs_training.csv	:	src/EDA.R data/training_data.csv
	Rscript src/EDA.R --data=data/training_data.csv \
		--output=docs/figs/

# Runs the workflow.R script to define the recipe, specification, perform cross-validation, choose best k value after
# looking at the best k plot, re-defining the specification based on the best k value and fitting the training data.
src/objects/knn_fit.rds :	src/workflow.R data/training_data.csv
	Rscript src/workflow.R --data=data/training_data.csv --output=src/

# Runs the knn.R script to test the workflow on testing data and the confusion matrix and model accuracy are considered.
src/objects/conf_mat.rds data/model_accuracy.csv	:	src/knn.R src/objects/knn_fit.rds
	Rscript src/knn.R --workflow=src/objects/knn_fit.rds --output=src/

# Saves the prediction report to the docs folder after rendering it from the prediction_report.qmd file
# generated from its dependencies
docs/prediction_report.html : data/training_data.csv data/testing_data.csv \
docs/figs/images.png docs/figs/links.png docs/figs/shares.png data/num_obs_training.csv \
docs/figs/videos.png src/objects/conf_mat.rds data/model_accuracy.csv data/share_summary.csv data/conf_mat_summary.csv
	mv docs/prediction_report.qmd ./
	quarto render prediction_report.qmd --to html;
	mv prediction_report.qmd docs/



# clean
clean:
	rm -rf data;
	rm -rf src/objects;
	ln docs/prediction_report.qmd ./
	rm -rf docs
	mkdir -p docs
	mv prediction_report.qmd docs/