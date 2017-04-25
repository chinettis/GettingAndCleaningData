# Get data:
getwd()

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="/Users/chinettis/Desktop/BackToMEF/DataScience/Getting_Cleaning_data/Dataset.zip",method="curl")

unzip(zipfile="/Users/chinettis/Desktop/BackToMEF/DataScience/Getting_Cleaning_data/Dataset.zip",exdir="/Users/chinettis/Desktop/BackToMEF/DataScience/Getting_Cleaning_data")

path_sc <- file.path("/Users/chinettis/Desktop/BackToMEF/DataScience/Getting_Cleaning_data" , "UCI HAR Dataset")
files<-list.files(path_sc, recursive=TRUE)
files

# Read data from the files into the variables:
dataActivityTest  <- read.table(file.path(path_sc, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_sc, "train", "Y_train.txt"),header = FALSE)
dataSubjectTrain <- read.table(file.path(path_sc, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_sc, "test" , "subject_test.txt"),header = FALSE)
dataFeaturesTest  <- read.table(file.path(path_sc, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_sc, "train", "X_train.txt"),header = FALSE)

str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

# Merges the training and the test sets to create one data set:
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_sc, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

# Extracts only the measurements on the mean and standard deviation for each measurement:
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
str(Data)

# Uses descriptive activity names to name the activities in the data set:
activityLabels <- read.table(file.path(path_sc, "activity_labels.txt"),header = FALSE)
head(Data$activity,30)

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
names(Data)

# Creates a second,independent tidy data set and ouput it
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

library(knitr)
knit2html("codebook.Rmd")