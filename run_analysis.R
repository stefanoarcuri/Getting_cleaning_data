
require(plyr)
# Directories and files
uci_dir <- "UCI\ HAR\ Dataset"
feat_file <- paste(uci_dir, "/features.txt", sep = "")
activity_lab <- paste(uci_dir, "/activity_labels.txt", sep = "")
x_train <- paste(uci_dir, "/train/X_train.txt", sep = "")
y_train <- paste(uci_dir, "/train/y_train.txt", sep = "")
subject_train <- paste(uci_dir, "/train/subject_train.txt", sep = "")
x_test  <- paste(uci_dir, "/test/X_test.txt", sep = "")
y_test  <- paste(uci_dir, "/test/y_test.txt", sep = "")
subject_test <- paste(uci_dir, "/test/subject_test.txt", sep = "")
# Load raw data
features <- read.table(feat_file, colClasses = c("character"))
activity_labels <- read.table(activity_lab, col.names = c("ActivityId", "Activity"))
x_train <- read.table(x_train)
y_train <- read.table(y_train)
subject_train <- read.table(subject_train)
x_test <- read.table(x_test)
y_test <- read.table(y_test)
subject_test <- read.table(subject_test)
# Bind sensor data
training_sensor_data <- cbind(cbind(x_train, subject_train), y_train)
test_sensor_data <- cbind(cbind(x_test, subject_test), y_test)
sensor_data <- rbind(training_sensor_data, test_sensor_data)
# Label columns
sensor_labels <- rbind(rbind(features, c(1000, "Subject")), c(1001, "ActivityId"))[,2]
names(sensor_data) <- sensor_labels
# mean and stdev
sensor_dm <- sensor_data[,grepl("mean|std|Subject|ActivityId", names(sensor_data))]
sensor_dm <- join(sensor_dm, activity_labels, by = "ActivityId", match = "first")
sensor_dm <- sensor_dm[,-1]


names(sensor_dm) <- gsub('\\(|\\)',"",names(sensor_dm), perl = TRUE)
names(sensor_dm) <- make.names(names(sensor_dm))
# Changing names
names(sensor_dm) <- gsub('Acc',"Acceleration",names(sensor_dm))
names(sensor_dm) <- gsub('GyroJerk',"AngularAcceleration",names(sensor_dm))
names(sensor_dm) <- gsub('Gyro',"AngularSpeed",names(sensor_dm))
names(sensor_dm) <- gsub('Mag',"Magnitude",names(sensor_dm))
names(sensor_dm) <- gsub('^t',"TimeDomain.",names(sensor_dm))
names(sensor_dm) <- gsub('^f',"FrequencyDomain.",names(sensor_dm))
names(sensor_dm) <- gsub('\\.mean',".Mean",names(sensor_dm))
names(sensor_dm) <- gsub('\\.std',".StandardDeviation",names(sensor_dm))
names(sensor_dm) <- gsub('Freq\\.',"Frequency.",names(sensor_dm))
names(sensor_dm) <- gsub('Freq$',"Frequency",names(sensor_dm))

# write data set
sensor = ddply(sensor_dm, c("Subject","Activity"), numcolwise(mean))
write.table(sensor, file = "sens.txt")
