library(reshape2)
zipUrl <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

file <- 'zipDataset.zip'
download.file(zipUrl, file, method='curl')

dataset <- unzip(file)

# Load activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Select features
selectedFeatures <- grep(".*mean.*|.*std.*", features[,2])
selectedFeatures.names <- features[selectedFeatures,2]
selectedFeatures.names = gsub('-mean', 'Mean', selectedFeatures.names)
selectedFeatures.names = gsub('-std', 'Std', selectedFeatures.names)
selectedFeatures.names <- gsub('[-()]', '', selectedFeatures.names)


# Load the train and test datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[selectedFeatures]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Merge Datasets
data <- rbind(train, test)
colnames(data) <- c("subject", "activity", selectedFeatures.names)

# turn activities & subjects into factors
data$activity <- factor(data$activity, levels = activityLabels[,1], labels = activityLabels[,2])
data$subject <- as.factor(data$subject)

data.melted <- melt(data, id = c("subject", "activity"))
data.mean <- dcast(data.melted, subject + activity ~ variable, mean)

write.table(data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)