# GettingAndCleaningData


### Data Obtained

Welcome.  The purpose of this github respository is to generate two tidy data sets from the data obtained from [this UCI Machine Learning Data Repository](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>).

The R analysis file required by the assignment is run_analysis.R, the data set is tidydata.txt  and the codebook is CodeBook.MD in this repository.

As described at the link, the dataset includes certain smartphone measurements from 30 subjects performing six sample activities.  The following files from the original dataset were incorporated into the analysis, as follows:

  - train/X_train.txt and test/X_test.txt - a time domain sample of 561 measurements taken on the 30 subjects performing 6  activities, broken into test and training sets
  - train/y_train.txt and test/Y_test.txt - a one column data set of each of the activity codes in the X sets, above
  - train/subject_train.txt and test/subject_test.txt - a one column data set of each the subjects in the X sets, above
  - features.txt - this is a list of variable names/measurement types for the 561 measurements in the X data sets above.
  - activity_labels.txt - a two column text file with the activity codes and their associated names

### Assumptions
- It was assumed from the assignment that the inertial signals were irrelevant.
- It was asssumed that assignment requirement "Extracts only the measurements on the mean and standard deviation for each measurement." limited the factor fields to mean() and std() and exlcuded addtional added vectors:
--  gravityMean
--tBodyAccMean
--tBodyAccJerkMean
--tBodyGyroMean
--tBodyGyroJerkMean
as these were already themselves computations.

### Why I Believe the Submitted Data Set is Tidy

The components of tidy data as defined in the course and by Hadley Wickham in his paper ["Tidy Data"](https://www.jstatsoft.org/article/view/v059i10) are:
1.  Each variable is in one column
2.  Each observation is in one row
3.  Each type of observational unit is in one table.


#### Decision One: Should mean() and std() columns be melted into separate rows?

I decided not to do this, as per #2 above, each observation should be in its own row.  Each observation I believe in this case is the behavior of the sensor during the subject's activity, and therefore putting mean and std on separate rows would have more than one row for each observation.  As support for this position, [this website](http://garrettgman.github.io/tidying/) indicatse that putting cases and populations in separate rows in the dataset leaves the data to be untidy.

#### Decision Two: Should the variable names (i.e."tBodyAcc-mean()-Y) be separated (i.e. into t or f, BodyAcc, mean() or Std(), X,Y, orZ)?
It seems that all the analysis tools covered in this course point me to believe that I should be separating these columns. However, the data in the column is a single number, not separated into the numerous categories of the column label.  For this reason, becuase these are individual variables observed for the row determinant, i.e. subject/activty, I decided not to separate out these columns.  The ulimate point of tidy data is that is useful for further analysis, and I were using it in a machine learning environment, I would want it grouped by subject/activity, and not have to recombine various aspects from various rows, as mentioned above in Decision one.

### R Process

This section will walk through the R code provided.  Comments are also located within the R file itself for ease of reference.



1. The features.txt file was read in through the read.table function, and the second column extracted as a character vector to use as column names.
```
    # read in table of labels for features
     featureLabels <-read.table("features.txt",sep =" ",stringsAsFactors=FALSE)
    # create character vector of column names for data table
    dataColumnNames <-featureLabels[,2]
```
2.  The X_train and X_test data sets were read in as fixed with files with 561 columns of 16 characters wide.
```
    # read in table of training data X, which has 561 fixed width fields of 16
    trainX<-read.fwf("train/X_train.txt", rep(16,561))
    # read in table of test data X, which hs 561 fixed width fields of 16
    testX<-read.fwf("test/X_test.txt", rep(16,561))
```
3.  The Y_train and Y_test data sets were read in as fixed with files with 1 column of 1 character
```
    # read in table of activity codes for training data Y, which has 1 column of length 1
    trainY <-read.fwf("train/Y_train.txt",1)
    # read in table of activity codes for test data Y, which has 1 column of length 1
    testY <-read.fwf("test/Y_test.txt",1)
 ```
4.  The train and test subject text files were rad in as fixed with files with 1 column of 2 charcters
```
    #read in table of test subjects for training data, which has 1 colunn of length 2
    trainSubject <-read.fwf("train/subject_train.txt",2)
    #read in table of test subjects for test data, which has 1 colunn of length 2
    testSubject <-read.fwf("test/subject_test.txt",2)
```
5.  The activiity labels were read in using the read.table function with a separator of " ".
```
    #read in table of activity labels
    activityLabels <-read.table("activity_labels.txt",sep=  " ")
```
6.  The test sets were appended to the training sets using rbind for X, Y, and subject data.
```
    #append testX to end of trainX
    Xdata <- rbind(trainX, testX)
    #append testY to end of testY
    Ydata <- rbind(trainY, testY)
    #append Subject Data
    subjects <-rbind(trainSubject, testSubject)
```
7.  The grep function was used to determine which column names had mean() or std() in their name.
```
    #determine which columns have mean or std in the title, assuming assignment wants straight mean() or std()
    column_selection <-sort(append(grep("mean\\(\\)",dataColumnNames),grep("std\\(\\)",dataColumnNames)))
```
8.  The Xdata table and column names were limited to those columns having mean() or std() in their name, then assigned column names
```
    #limit Xdata to selected columns
    Xdata<-Xdata[,column_selection]
    #limit column names to selected columns
    newDataColumnNames <-dataColumnNames[column_selection]
    #assign names to XData
    colnames(Xdata)<-newDataColumnNames
```
9.  A name of activity code was assigned the Ydata table.
```
    #assign names to Ydata
    colnames(Ydata)<-c("activitycode")
```
10.  Names of activitycode and activityname were asigned to the activityLabels table.
   
```
    #assign names to activityLabels
    colnames(activityLabels)<-c("activitycode","activityname")
```
   
11.  A name of subjectnumber was assigned to the subjects table.
```    
    #assign names to subjects
    colnames(subjects)<-"subjectnumber"
   ```
12.  Subjects, activities, and X data wre combined into one table.
```
    #combine subjects, activities, and Xdata into one table
    Xdata<-cbind(subjects,Ydata,Xdata)
````
13.  Activity names were assigned by ID.
```
    #assign activity names by ID
    mergedXdata<-merge(Xdata,activityLabels,by.x="activitycode",by.y="activitycode",all=TRUE)
```
14.  The dyplr libarary was loaded and the table formated in dyplr format.
```
    #load dplyr library
    library(dplyr)
    #convert to dplyr format
    xPlrData<- tbl_df(mergedXdata)
```
15.  The table was grouped, redundant information removed, and means calculated.
```
    #establish dplyr grouping
    xPlrData<-group_by(xPlrData,subjectnumber,activityname)
    #remove redundant information
    xPlrData<-select(xPlrData,-activitycode)
    #summarize to arrive at mean of each item by subject number and activity name
    summaryData<-summarise_each(xPlrData,funs(mean))
```
16.  The table was written to file.
```
    #write tabel to file
    write.table(summaryData,"tidydata.txt", row.name=FALSE)
```
