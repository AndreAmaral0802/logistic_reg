# Logistic Regression Project

# In this project we will be working with the UCI adult dataset. 
# We will be attempting to predict if people in the data set belong in a certain class by salary, either making <=50k or >50k per year.

# Typically most of your time is spent cleaning data, not running the few lines of code that build your model, 
# this project will try to reflect that by showing different issues that may arise when cleaning data.

df <- read.csv('adult_sal.csv')
head(df)

# drop X from the dataset
library(dplyr)
df <- select(df,-X)
head(df)

# some stats
str(df)
summary(df)
head(df)

# Visualizing NA
library(Amelia)
print(missmap(df,main = 'Imputation check', col = c('yellow','black'), legend = FALSE))
sum(is.na(df))

# CLEANING 

# checking details of type of employer variable
table(df$type_employer)
# How many Null values are there for type_employer? What are the two smallest groups?

# there are no Nulls but there are 1836 -> without-pay 14 + Never-worked 7 = combine these two 
# let's combine these these values as Unemployed 
# convert the column to character the use sapply
unemp <- function(job){
  job <- as.character(job)
  if (job == 'Never-worked' | job == 'Without-pay'){
    return('Unemployed')
  }else{
    return(job)
  }
}
# the function seem to have worked. Let's apply on the datadset
df$type_employer <- sapply(df$type_employer,unemp)
table(df$type_employer)

# there are two more to concatenate state and local gov employees as SL-gov and self-emp-inc and self-emp-not-inc as self-employed

SL_gov <- function(job_1){
  job_1 <- as.character(job_1)
  if (job_1 == 'State-gov' | job_1 == 'Local-gov'){
    return('sl_gov')
  }else{
    return(job_1)
  }
}
# apply the function
df$type_employer <- sapply(df$type_employer,SL_gov)
table(df$type_employer)

# self employed 

Self_emp <- function(job_2){
  job_2 <- as.character(job_2)
  if (job_2 == 'Self-emp-inc' | job_2 == 'Self-emp-not-inc'){
    return('self_employed')
  }else{
    return(job_2)
  }
}
# apply the function
df$type_employer <- sapply(df$type_employer,Self_emp)
table(df$type_employer)

# Marital Status
table(df$marital)
# reduce to 3 categories = Married, Not-Married, Never-Married
mar_stat <- function(m_stat){
  m_stat <- as.character(m_stat)
  if (m_stat == 'Married-AF-spouse' | m_stat == 'Married-civ-spouse' | m_stat == 'Married-spouse-absent'){
    return('Married')
  }else if (m_stat == 'Divorced' | m_stat == 'Separated' | m_stat == 'Widowed'){
    return('Not-Married')
  }else{
    return(m_stat)
  }
}
# apply the function
df$marital <- sapply(df$marital,mar_stat)
table(df$marital)

# Country
table(df$country)
# group this by continent 
levels(df$country)

Asia <- c('Japan', 'Taiwan', 'Iran', 'Vietnam', 'Cambodia', 'Hong', 'Laos', 'Thailand', 'Philippines', 'China', 'India')
North_America <- c('Canada', 'United-States', 'Puerto-Rico')
Europe <- c('England' ,'France', 'Germany' ,'Greece','Holand-Netherlands','Hungary',
            'Ireland','Italy','Poland','Portugal','Scotland','Yugoslavia')
Latin_America <- c('Columbia','Cuba','Dominican-Republic','Ecuador',
                   'El-Salvador','Guatemala','Haiti','Honduras',
                   'Mexico','Nicaragua','Outlying-US(Guam-USVI-etc)','Peru',
                   'Jamaica','Trinadad&Tobago')
Other <- c('South')

# function t group by
group_country <- function(ctry){
  if (ctry %in% Asia){
    return('Asia')
  }else if(ctry %in% North_America){
    return('North_America')
  }else if(ctry %in% Europe){
    return('Europe')
  }else if(ctry %in% Latin_America){
    return('Latin_America')
  }else{
    return('Other')
  }
}
# apply the function
df$country <- sapply(df$country,group_country)
table(df$country)

# check if columns changed are factor
str(df)
# to change = type_employer, martial, country
df$type_employer <- sapply(df$type_employer,factor)
df$marital <- sapply(df$marital,factor)
df$country <- sapply(df$country,factor)
str(df)

# convert a few more, education, occupation, relationship, race, sex, income
df$education <- sapply(df$education,factor)
df$occupation <- sapply(df$occupation,factor)
df$relationship <- sapply(df$relationship,factor)
df$race <- sapply(df$race,factor)
df$sex <- sapply(df$sex,factor)
df$income <- sapply(df$income,factor)
str(df)
# check if we can group more
df$education
str(df$education)
summary(df$education)
# group education into elementary, middle, high_school, higher_education and other
# create a function to group by
Educ <- function(edu){
  if(edu == '1st-4th' | edu == '5th-6th'){
    return('elementary')
  }else if(edu == '7th-8th'){
    return('middle')
  }else if(edu == '9th' | edu == '10th' | edu == '11th' | edu == '12th' | edu == 'HS-grad'){
    return('high')
  }else if(edu == 'Bachelors' | edu == 'Masters' | edu == 'Doctorate'){
    return('higher_eductaion')
  }else if(edu == 'Some-college' | edu == 'Assoc-acdm' | edu == 'Assoc-voc' | edu == 'Prof-school' | edu == 'Preschool'){
    return('Other')
  }else{
    return(edu)
  }
}
# apply the function 
df$education <- sapply(df$education,Educ)
table(df$education)
df$education

df$education <- sapply(df$education,factor)

# Find missing data
# convert ? to NA
df[df == '?'] <- NA
head(df)
sum(is.na(df))
str(df)
# calculate % of missing 
Miss <- 3679
total <- 32561
Miss/total * 100
# it's around 11.3% 
print(missmap(df,main = 'Imputation check', col = c('yellow','black'), legend = FALSE))
table(df$type_employer)
# considering that 11.3% is not a big deal we can drop them 
df <- na.omit(df) 
sum(is.na(df)) # worked
str(df)
# check with the map once again
print(missmap(df,main = 'Imputation check', col = c('yellow','black'), legend = FALSE)) # no NA values left!

# VIZUALISATION 
library(ggplot2)
ggplot(df,aes(age)) + geom_histogram(aes(fill=income),color='black',binwidth=1) + theme_bw()

# hours per week 
ggplot(df,aes(hr_per_week)) + geom_histogram() + theme_bw()
summary(df$hr_per_week)
mean(df$hr_per_week) # working average is around 40h per week

# check the region
str(df$country) # change the name for region instead of country

# df <- rename(df,region = country) = this is another way of doing it
names(df)[names(df) == "country"] <- "region"
str(df)

# bar plot
ggplot(df,aes(region)) + geom_bar(aes(fill=income), color = 'black') + theme_bw() +
theme(axis.text.x = element_text(angle = 90, hjust = 1))

# BUILD THE MODEL = Logist Regression
library(caTools)

head(df)

# set a seed
set.seed(101)

# train and test split
# Split up the sample, basically randomly assigns a Boolean to a new column "sample"
sample <- sample.split(df$income, SplitRatio = 0.7)

# training data
train = subset(df, sample == TRUE)
# test data
test = subset(df, sample == FALSE)

# TRAINING THE MODEL 
help(glm)

# applying 
model = glm(income ~ ., family = binomial(link = 'logit'), data = train)
summary(model)

# The step() function iteratively tries to remove predictor variables 
# from the model in an attempt to delete variables that do not significantly add to the fit

help(AIC)

# Choose a model by AIC in a Stepwise Algorithm

new.step.model <- step(model)

# You should get a bunch of messages informing you of the process. Check the new.model by using summary()

summary(new.step.model)

# Create a confusion matrix using the predict function with type='response' as an argument inside of that function.

test$predicted.income = predict(model, newdata=test, type="response")

table(test$income, test$predicted.income > 0.5)
(6368+1431)/(6368+1431+552+864) # this is the accuracy of the model

#recall calculation
6368/(6368+552)

#precision
6368/(6368+864)

# to know whether or not this is a good model we need to know the cost associated with accuracy vs recall vs precision