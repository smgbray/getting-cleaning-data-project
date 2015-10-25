#The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  
# 
# One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 
#   
#   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
# 
# Here are the data for the project: 
#   
#   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# 
# You should create one R script called run_analysis.R that does the following. 
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement. 
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names. 
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

filename <- "Dataset.zip"

#Download the data file into the data folder
if(!file.exists(filename)){
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL,filename,method="curl")
}

#Unzips the downloaded file
if(!file.exists("UCI HAR Dataset")) {
unzip(filename)
}

#Unzips files into the Dataset folder; gets the list of files
path_rf <- file.path("UCI HAR Dataset")
files <- list.files(path_rf, recursive = TRUE)

#Read activity data from files into variables
activityTest <- read.table(file.path(path_rf, "test", "Y_test.txt"),header = FALSE)
activityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

#Read subject data from files into variables
subjectTest <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
subjectTrain <- read.table(file.path(path_rf, "test", "subject_test.txt"),header = FALSE)

#Read Features data from files into variables
featuresTest <- read.table(file.path(path_rf,"test","X_test.txt"),header = FALSE)
featuresTrain <- read.table(file.path(path_rf,"train","X_train.txt"),header = FALSE)

#Concatenate the data tables by rows
subjectData <- rbind(subjectTrain, subjectTest)
activityData <- rbind(activityTrain, activityTest)
featuresData <- rbind(featuresTrain, featuresTest)

#Set names to variables
names(subjectData) <- c("subject")
names(activityData) <- c("activity")
namesFeaturesData <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(featuresData) <- namesFeaturesData$V2

#Merge columns to create data frame for all data
combineData <- cbind(subjectData, activityData)
data <- cbind(featuresData,combineData)

#Subset name of features by measurements on the mean and standard deviation
namesSubDataFeatures <- namesFeaturesData$V2[grep("mean\\(\\)"),namesFeaturesData$V2]

#Subset the data frame by selected names of Features
selectedNames <- c(as.character(namesSubDataFeatures),"subject","activity")
data <- subset(data,select=selectedNames)

#Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.tale(file.path(path_rf, "activity_labels.txt"),header=FALSE)

#Labels the data set with appropriate descriptive variable names
names(data)<-gsub("^t", "time", names(data))
names(data)<-gsub("^f", "frequency", names(data))
names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))

#Creates a second, independent tidy data set
library(plyr)
data2 <- aggregate(. ~subject + activity, data, mean)
data2 <- data2[order(data2$subject,data2$activity),]
write.table(data2, file = "tidydata.txt",row.name=FALSE)

#Produce codebook
library(knitr)
knit2html("codebook.MD")

